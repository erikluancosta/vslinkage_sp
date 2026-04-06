source('global.R')
source('funcoes/namestand2.R')
source('funcoes/ajuste_txt2.R')

# base completa
esus <- dbGetQuery(
  con,
  "
  SELECT * FROM original_esus_aps_completa
  "
)

# Tratamento
esus <- esus |> 
  vitallinkage::padroniza_variaveis(namestand2,'ESUS_APS') |> 
  vitallinkage::upper_case_char() |>
  vitallinkage::ajuste_data(tipo_data=2) |> 
  mutate(
    id_registro_linkage = -1,
    nu_cns = as.character(nu_cns),
    across(starts_with("ds"), ~ ifelse(. == "", NA, .)),
    recem_nasc = ifelse(
      grepl("^(RN |RECEM NASCIDO|RN NASCIDO|NATIMORTO|NATIMORTI|FETO MORTO|FETO|MORTO|NASCIDO VIVO|VIVO|NASCIDO|SEM DOC|CADAVER|NATIMORTE|RECEM|IGNORADO|RECEM NASCIDO DE )", ds_nome_pac), 
      1, 
      NA
    )) |> 
  vitallinkage::copia_nomes() |> 
  ajuste_txt2() |> 
  vitallinkage::soundex_linkage('ds_nome_pac') |> 
  vitallinkage::soundex_linkage('ds_nome_mae') |> 
  vitallinkage::soundex_linkage('ds_nome_pai') |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "0000", NA, .))) |> 
  vitallinkage::ajuste_res() |>
  vitallinkage::soundex_linkage("ds_bairro_res") |> 
  vitallinkage::soundex_linkage("ds_rua_res") |> 
  mutate(across(ends_with("_res2"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(ends_with("_res2_sound"), ~ ifelse(. == "0000", NA, .)))


esus <- esus |> 
  mutate(
    ds_sexo = case_when(
      ds_sexo == "MASCULINO" ~ "M",
      ds_sexo == "FEMININO" ~ "F",
      TRUE ~ "I"
    )
    #    ds_sexo = factor(ds_sexo, levels = c("M", "F"))
  )

esus <- esus |> select(id_esus_aps, id_registro_linkage, id_unico, everything())


# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("tratado_esus_aps"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = esus[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_esus_aps = "BIGINT",
                  id_registro_linkage = "BIGINT")
)

# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE tratado_esus_aps 
    ADD PRIMARY KEY (id_esus_aps)
")

# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "tratado_esus_aps", esus)
tictoc::toc()
