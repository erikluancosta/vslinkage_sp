source('global.R')
source('funcoes/namestand2.R')
source('funcoes/ajuste_txt2.R')


# Carregar os dados do SINAN
sinan_viol <- dbGetQuery(con, "SELECT * FROM original_sinan_viol")

# Normalizando os nomes das variáveis
sinan_viol <- sinan_viol |>
  vitallinkage::drop_duplicados_sinan_1() |>  # Dropa as colunas duplicadas inicialmente
  vitallinkage::padroniza_variaveis(namestand2,"SINAN_VIOL") |> 
  vitallinkage::ajuste_data(tipo_data=2) |> 
  vitallinkage::ano_sinan() |> 
  mutate(
    id_registro_linkage = -1,
    recem_nasc = ifelse(
      grepl("^(RN |RECEM NASCIDO|RN NASCIDO|NATIMORTO|NATIMORTI|FETO MORTO|FETO|MORTO|NASCIDO VIVO|VIVO|NASCIDO|SEM DOC|CADAVER|NATIMORTE|RECEM|IGNORADO|RECEM NASCIDO DE )", ds_nome_pac), 
      1, 
      NA
    )) |> 
  vitallinkage::copia_nomes() |> 
  # Ajusta as variáveis que contem "ds_nome" na composição
  ajuste_txt2() |> 
  vitallinkage::soundex_linkage("ds_nome_pac") |>
  vitallinkage::soundex_linkage("ds_nome_mae") |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "0000", NA, .))) |> 
  # Ajusta as variáveis que contem "_res" na composição
  vitallinkage::ajuste_res() |> 
  vitallinkage::soundex_linkage("ds_bairro_res") |>
  vitallinkage::soundex_linkage("ds_rua_res") |>
  vitallinkage::soundex_linkage("ds_comple_res") |>
  vitallinkage::soundex_linkage("ds_ref_res") |> 
  mutate(across(ends_with("_res2"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(ends_with("_res2_sound"), ~ ifelse(. == "0000", NA, .))) |> 
  # NOVAS VARIÁVEIS
  # Raça/cor
  vitallinkage::ds_raca_sinan() |> 
  mutate(
    ds_raca = stringr::str_to_title(ds_raca),
    ds_raca = case_when(
      ds_raca == "Ignorado" ~ "Ignorada",
      ds_raca == "Indigena" ~ "Indígena",
      TRUE ~ ds_raca)
  ) |> 
  # Sexo
  vitallinkage::corrige_sg_sexo() |> # Corrige os registros de sexo Ignorado
  vitallinkage::nu_idade_anos_sinan() |>  # Discutir a ideia de calcular com a idade antes do código
  select(id_sinan_viol, id_registro_linkage, id_unico, everything()) |>
  arrange(id_sinan_viol)

# função auxiliar: tenta converter para inteiro só se for seguro
safe_as_int <- function(x) {
  # já é inteiro → devolve
  if (is.integer(x)) return(x)
  
  # se for numérico (double), só muda a classe
  if (is.numeric(x)) return(as.integer(x))
  
  # se for character, verifica se todos os valores (não-NA) são dígitos puros
  all_digits <- str_detect(x, "^\\d+$")          # TRUE onde só tem 0-9
  if (all(is.na(x) | all_digits)) {
    return(as.integer(x))                        # seguro → converte
  } else {
    return(x)                                    # mantém como está
  }
}

sinan_viol <- sinan_viol |>  
  mutate(
    across(
      .cols = matches("^(id_|cd_|def_|tran_|rel_|enc_|proc_|viol_)"),   # pega id_* e cd_*
      .fns  = safe_as_int              # aplica regra “tenta, mas só se der”
    )
  )

# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("tratado_sinan_viol"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = sinan_viol[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_sinan_viol = "BIGINT",
                  id_registro_linkage = "BIGINT")
)


# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE tratado_sinan_viol 
    ADD PRIMARY KEY (id_sinan_viol)
")


# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "tratado_sinan_viol", sinan_viol)
tictoc::toc()
