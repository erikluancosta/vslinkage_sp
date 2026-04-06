library(lubridate)
source('global.R')
source('funcoes/funcoes_iexo.R')
source('funcoes/ajuste_txt2.R')

# Carregar os dados do SINAN
sinan_iexo <- dbGetQuery(con, "SELECT * FROM original_sinan_iexo;")

# Ano de nascimento
sinan_iexo <- sinan_iexo |> 
  mutate(
    ANO_NASC = year(as.Date(DT_NASC, format = "%Y-%m-%d"))
  )

df_clean <- sinan_iexo

# Repetições no número da notificação
df_clean <- df_clean |> 
  start_linkage(
    c("NU_NOTIFIC", "SOUNDEX"), 
    "NU_NOTIFIC"
  )


# Primeiro, defina a ordem para a variável "CS_SEXO"
df_clean$CS_SEXO <- factor(df_clean$CS_SEXO, levels = c("I", "M", "F"), ordered = TRUE)

# Liste as variáveis a serem modificadas, excluindo "par_1" e "CS_SEXO"
vars_to_mutate <- names(df_clean)[!(names(df_clean) %in% c("par_1", "CS_SEXO"))]

# Aplique as transformações usando group_by e mutate
df_clean <- df_clean %>%
  group_by(par_1) %>%
  mutate(
    across(
      all_of(vars_to_mutate),
      ~ if (!is.na(par_1[1])) {
        if (all(is.na(.))) {
          NA
        } else {
          max(., na.rm = TRUE)
        }
      } else {
        .
      }
    ),
    CS_SEXO = if (!is.na(par_1[1])) {
      if (all(is.na(CS_SEXO))) {
        NA
      } else {
        as.character(max(CS_SEXO, na.rm = TRUE))
      }
    } else {
      CS_SEXO
    }
  ) |>
  ungroup() |>
  unique() |> 
  select(
    -par_1,
    -par_c1,
    -regra1
  )

## PADRONIZAR OS NOMES DAS VARIÁVEIS
names_sinan_iexo <- readxl::read_xlsx("tratamento/auxiliar/nm_stand_sinan_intox_exogena.xlsx")

df_clean <- df_clean |>
  mutate(id_registro_linkage = -1) |> 
  vitallinkage::padroniza_variaveis(names_sinan_iexo,nome_base = "SINAN_IEXO") |> 
  vitallinkage::copia_nomes() |> 
  #vitallinkage::ano_sinan() |> 
  mutate(
    recem_nasc = ifelse(
      grepl("^(RN |RECEM NASCIDO|RN NASCIDO|NATIMORTO|NATIMORTI|FETO MORTO|FETO|MORTO|NASCIDO VIVO|VIVO|NASCIDO|SEM DOC|CADAVER|NATIMORTE|RECEM|IGNORADO|RECEM NASCIDO DE )", ds_nome_pac), 
      1, 
      NA
    )) |> 
  # Ajusta as variáveis que contem "ds_nome" na composição
  ajuste_txt2() |> 
  vitallinkage::soundex_linkage("ds_nome_pac") |>
  vitallinkage::soundex_linkage("ds_nome_mae") |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(starts_with("ds_nome_"), ~ ifelse(. == "0000", NA, .))) |> 
  vitallinkage::ajuste_res() |> 
  vitallinkage::soundex_linkage("ds_bairro_res") |>
  vitallinkage::soundex_linkage("ds_rua_res") |>
  vitallinkage::soundex_linkage("ds_comple_res") |>
  vitallinkage::soundex_linkage("ds_ref_res") |> 
  mutate(across(ends_with("_res2"), ~ ifelse(. == "", NA, .))) |> 
  mutate(across(ends_with("_res2_sound"), ~ ifelse(. == "0000", NA, .)))

# Decodificando a variável de Evolução do caso
df_clean <- df_clean |> 
  ds_raca() |> 
  ds_agente_tox() |> 
  ds_loc_expo() |> 
  ds_via_1() |> 
  ds_via_2() |> 
  ds_circunstan() |> 
  ds_tpexp() |> 
  ds_tpatend() |> 
  ds_hospital() |> 
  ds_classi_fin() |> 
  ds_evolucao() |> 
  vitallinkage::nu_idade_anos_sinan()


sinan_iexo <- df_clean
rm(df_clean, names_sinan_iexo)


# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("tratado_sinan_iexo"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = sinan_iexo[0, ],              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE,
  field.types = c(id_sinan_iexo = "BIGINT",
                  id_registro_linkage = "BIGINT")
)

# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE tratado_sinan_iexo 
    ADD PRIMARY KEY (id_sinan_iexo)
")


# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "tratado_sinan_iexo", sinan_iexo)
tictoc::toc()
