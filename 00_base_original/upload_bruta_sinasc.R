source('global.R')
source('conectar/conecatar.R')

# conectando ao banco de dados local
con <- conectar('linkage2')

# carregando a base bruta
sinasc <- readxl::read_excel("00_base_original/dados/recife_novo_linkage_2024/sinasc_2010_2023/DN 2010_2023.xlsx")

# Criando Ids únicos
sinasc <- sinasc |> 
  mutate(
    id_sinasc = row_number(),
    id_unico = paste0("SINASC_", row_number(), "_", NUMERODN),
    banco = "SINASC"
  ) |> 
  select(id_unico, id_sinasc, everything()) |>  
  vitallinkage::ajuste_data()

# Salvando a base bruta no banco de dados
# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("original_sinasc"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = sinasc[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_sinasc = "BIGINT")
)

# 2. ‑‑ Cria indices ----------------------------------------------------
dbExecute(con, "
  ALTER TABLE original_sinasc 
    ADD PRIMARY KEY (id_sinasc)
")

# 2. ‑‑ Insere os dados na tabela ---------------------------------------
dbAppendTable(con, "original_sinasc", sinasc)
