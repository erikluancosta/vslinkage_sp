source('global.R')

# base antiga
esus_antigo <- dbGetQuery(
  con,
  "
  SELECT * FROM original_esus_aps
  WHERE tbap_dt_inicio::date < DATE '2023-01-01'
  "
)
esus_antigo <- esus_antigo %>% 
  mutate(tbc_dt_naturalizacao=as.character(tbc_dt_naturalizacao),
         tbc_dt_entrada_brasil=as.character(tbc_dt_entrada_brasil),
         nu_cnes = as.numeric(nu_cnes)
  )

# base nova
esus_novo <- dbGetQuery(
  con,
  "
  SELECT * FROM original_esus_aps_view
  "
)

esus_novo <- esus_novo %>% 
  mutate(
    tbc_dt_naturalizacao=as.character(tbc_dt_naturalizacao),
    tbc_dt_entrada_brasil=as.character(tbc_dt_entrada_brasil),
    tbc_nu_cpf = as.character(tbc_nu_cpf),
    tbc_nu_cns = as.character(tbc_nu_cns),
    tbc_nu_documento_obito = as.character(tbc_nu_documento_obito),
    tbc_ds_cep = as.character(tbc_ds_cep),
    tbc_nu_telefone_residencial = as.character(tbc_nu_telefone_residencial),
    tbc_nu_telefone_celular = as.character(tbc_nu_telefone_celular),
    tbc_nu_telefone_contato = as.character(tbc_nu_telefone_contato),
    nu_cnes = as.numeric(nu_cnes))

esus_novo <- esus_novo %>% 
  mutate(
    tbc_nu_area = as.character(tbc_nu_area),
    tbc_nu_nis_pis_pasep = as.character(tbc_nu_nis_pis_pasep),
    tbc_dt_ultima_ficha = ymd(tbc_dt_ultima_ficha),
    tbc_dt_atualizado_cadsus = ymd(tbc_dt_atualizado_cadsus)
  )

esus <- bind_rows(esus_antigo, esus_novo)

class(esus_antigo$tbc_dt_naturalizacao)


rm(esus_antigo, esus_novo)

esus <- esus |> 
  mutate(
    id_unico = paste0("ESUS_APS_", row_number(), "_", tba_co_unico_atend),
    banco = "ESUS_APS",
    id_esus_aps = row_number()
  ) |> 
  select(id_esus_aps, id_unico, everything())


# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("original_esus_aps_completa"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = esus[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_esus_aps = "BIGINT")
)


# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE original_esus_aps_completa
    ADD PRIMARY KEY (id_esus_aps)
")
# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "original_esus_aps_completa", esus)
tictoc::toc()
