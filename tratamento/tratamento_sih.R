library(lubridate)
source('global.R')
source('funcoes/namestand2.R')
source('funcoes/ajuste_txt2.R')

# Carregar os dados do SINAN
sih <- dbGetQuery(con, "SELECT * FROM original_sih")

tictoc::tic()
sih2 <- sih |> 
  vitallinkage::upper_case_char() |> # As colunas com texto passam a ficar com letra maiuscula
  vitallinkage::padroniza_variaveis(namestand2,'SIH') |> 
  mutate(
    id_registro_linkage = -1,
    nu_cns = str_trim(case_when(
      nu_cns == "000000000000000" ~ NA_character_,
      nu_cns == "00000000000" ~ NA_character_,
      nu_cns == "000000000" ~ NA_character_,
      nu_cns == "" ~ NA_character_,
      TRUE ~ nu_cns
    )),
    nu_doc = str_trim(case_when(
      nu_doc == "00000000000000000000000000000000" ~ NA_character_,
      nu_doc == "00000000000000000000000000" ~ NA_character_,
      nu_doc == "00000000000" ~ NA_character_,
      nu_doc == "000000000" ~ NA_character_,
      nu_doc == "" ~ NA_character_,
      nu_doc == "                                " ~ NA_character_,
      nu_doc == "NT"~ NA_character_,
      nu_doc == "SEMDOCUMENTO" ~ NA_character_,
      nu_doc == "ESTUDANTE"~ NA_character_,
      TRUE ~ nu_doc
    )),
    across(starts_with("cd_diag_"), ~ ifelse(. == "    ", NA, .)),
    across(starts_with("cd_diag_"), ~ ifelse(. == "0000", NA, .)),
    diag_obito = ifelse(diag_obito == "    ", NA, diag_obito),
    diag_obito = ifelse(diag_obito == "0000", NA, diag_obito)
  ) |> 
  vitallinkage::ajuste_data(tipo_data = 2) |> 
  vitallinkage::copia_nomes() |> 
  mutate(
    across(starts_with("ds_"), str_trim),
    recem_nasc = ifelse(
      grepl("^(RN |RECEM NASCIDO|RN NASCIDO|NATIMORTO|NATIMORTI|FETO MORTO|FETO|MORTO|NASCIDO VIVO|VIVO|NASCIDO|SEM DOC|CADAVER|NATIMORTE|RECEM|RECEM NASCIDO DE )", ds_nome_pac, ignore.case = TRUE), 
      1, 
      NA
    ),
    ano = year(dt_internacao),
    ano_nasc = year(dt_nasc)
  ) |> 
  ajuste_txt2() |> 
  vitallinkage::soundex_linkage("ds_nome_pac") |>
  vitallinkage::soundex_linkage("ds_nome_mae") |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "0000", NA, .))) |> 
  # Ajusta as variáveis que contem "_res" na composição
  vitallinkage::ajuste_res() |> 
  mutate(
    across(ends_with("_res"), str_trim),
    across(ends_with("_res"), ~ ifelse(. == "", NA, .))
  ) |> 
  vitallinkage::soundex_linkage("ds_bairro_res") |>
  vitallinkage::soundex_linkage("ds_comple_res") |>
  vitallinkage::soundex_linkage("ds_nome_pac_res") |>
  vitallinkage::soundex_linkage("ds_rua_res")|> 
  mutate(across(ends_with("_res2"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(ends_with("_res2_sound"), ~ ifelse(. == "0000", NA, .))) |> 
  vitallinkage::ds_raca_sih() |> 
  vitallinkage::corrige_sg_sexo() |>
  vitallinkage::nu_idade_anos_sih() |> 
  mutate(ds_raca = stringr::str_to_title(ds_raca),
         ds_raca = case_when(
           ds_raca == "Ignorado" ~ "Ignorada",
           ds_raca == "Indigena" ~ "Indígena",
           TRUE ~ ds_raca))
tictoc::toc()

sih <- sih2 |> 
  select(id_sih, id_registro_linkage, id_unico, everything()) |> 
  arrange(id_sih)


# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("tratado_sih"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = sih[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_sih = "BIGINT",
                  id_registro_linkage = "BIGINT")
)

# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE tratado_sih 
    ADD PRIMARY KEY (id_sih)
")


# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "tratado_sih", sih)
tictoc::toc()
