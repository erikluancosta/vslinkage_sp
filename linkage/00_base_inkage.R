source('global.R')

query_esus <- "
SELECT
    id_unico,
    id_esus_aps,
    ds_nome_pac,
    ds_nome_pac_sound,
    ds_nome_pac1,
    ds_nome_pac1_sound,
    ds_nome_pac2,
    ds_nome_pac2_sound,
    ds_nome_pac3_sound,
    ds_nome_pac3,
    ds_nome_mae,
    ds_nome_mae_sound,
    ds_nome_mae1,
    ds_nome_mae1_sound,
    ds_nome_mae2,
    ds_nome_mae2_sound,
    ds_nome_mae3,
    ds_nome_mae3_sound,
    ds_nome_pai,
    ds_nome_pai_sound,
    ds_nome_pai1,
    ds_nome_pai1_sound,
    ds_nome_pai2,
    ds_nome_pai2_sound,
    ds_nome_pai3,
    ds_nome_pai3_sound,
    dt_nasc,
    dt_obito,
    dt_inicio_ap,
    dt_fim_ap,
    CAST(nu_cns AS VARCHAR) AS nu_cns,
    ds_end_comp,
    ds_rua_res,
    nu_end,
    nu_doc,
    ds_bairro_res,
    nu_tel,
    nu_tel_cel,
    nu_tel_contato,
    ds_sexo AS sg_sexo,
    ds_email,
    banco,
    recem_nasc
FROM tratado_esus_aps
"

query_viol <- "
SELECT
    id_unico,
    ds_nome_pac,
    ds_nome_pac_sound,
    ds_nome_pac1,
    ds_nome_pac1_sound,
    ds_nome_pac2,
    ds_nome_pac2_sound,
    ds_nome_pac3_sound,
    ds_nome_pac3,
    ds_nome_mae,
    ds_nome_mae_sound,
    ds_nome_mae1,
    ds_nome_mae1_sound,
    ds_nome_mae2,
    ds_nome_mae2_sound,
    ds_nome_mae3,
    ds_nome_mae3_sound,
    nu_idade_anos,
    dt_nasc,
    dt_notific,
    dt_ocor,
    cd_mun_res,
    dt_obito,
    CAST(nu_cns AS VARCHAR) AS nu_cns,
    ds_rua_res,
    ds_bairro_res,
    nu_tel,
    sg_sexo,
    banco,
    ano,
    recem_nasc
FROM tratado_sinan_viol
"

query_sim <- "
SELECT
    id_unico,
    ds_nome_pac,
    ds_nome_pac_sound,
    ds_nome_pac1,
    ds_nome_pac1_sound,
    ds_nome_pac2,
    ds_nome_pac2_sound,
    ds_nome_pac3_sound,
    ds_nome_pac3,
    ds_nome_mae,
    ds_nome_mae_sound,
    ds_nome_mae1,
    ds_nome_mae1_sound,
    ds_nome_mae2,
    ds_nome_mae2_sound,
    ds_nome_mae3,
    ds_nome_mae3_sound,
    ds_nome_pai,
    ds_nome_pai_sound,
    ds_nome_pai1,
    ds_nome_pai1_sound,
    ds_nome_pai2,
    ds_nome_pai2_sound,
    ds_nome_pai3,
    ds_nome_pai3_sound,
    nu_idade_anos,
    dt_nasc,
    dt_obito,
    cd_mun_res,
    cd_cep_res,
    CAST(nu_cns AS VARCHAR) AS nu_cns,
    ds_rua_res,
    ds_bairro_res,
    sg_sexo,
    banco,
    ano,
    dt_atestado,
    recem_nasc
FROM tratado_sim
"
query_sih <-"
SELECT
    id_unico,
    ds_nome_pac,
    ds_nome_pac_sound,
    ds_nome_pac1,
    ds_nome_pac1_sound,
    ds_nome_pac2,
    ds_nome_pac2_sound,
    ds_nome_pac3_sound,
    ds_nome_pac3,
    ds_nome_mae,
    ds_nome_mae_sound,
    ds_nome_mae1,
    ds_nome_mae1_sound,
    ds_nome_mae2,
    ds_nome_mae2_sound,
    ds_nome_mae3,
    ds_nome_mae3_sound,
    nu_idade_anos,
    dt_nasc,
    dt_internacao,
    dt_emissao,
    dt_saida,
    cd_cep_res,
    CAST(nu_cns AS VARCHAR) AS nu_cns,
    ds_rua_res,
    ds_bairro_res,
    cd_mun_res,
    nu_tel,
    sg_sexo,
    banco,
    ano,
    recem_nasc
FROM tratado_sih
"

query_intox <-"
SELECT
    id_unico,
    ds_nome_pac,
    ds_nome_pac_sound,
    ds_nome_pac1,
    ds_nome_pac1_sound,
    ds_nome_pac2,
    ds_nome_pac2_sound,
    ds_nome_pac3_sound,
    ds_nome_pac3,
    ds_nome_mae,
    ds_nome_mae_sound,
    ds_nome_mae1,
    ds_nome_mae1_sound,
    ds_nome_mae2,
    ds_nome_mae2_sound,
    ds_nome_mae3,
    ds_nome_mae3_sound,
    nu_idade_anos,
    dt_nasc,
    dt_notific,
    dt_internacao,
    dt_obito,
  -- dt_ocor,
  -- cd_cep_res,
    cd_mun_res,
    CAST(nu_cns AS VARCHAR) AS nu_cns,
    ds_rua_res,
    ds_bairro_res,
    nu_tel,
    sg_sexo,
    banco,
    ano,
    recem_nasc
FROM tratado_sinan_iexo
"

# Executar a consulta e armazenar os resultados em um dataframe
viol <- dbGetQuery(con, query_viol)
print('Sinan violências carregado')

# Gerando base do sim
sim <- dbGetQuery(con, query_sim)
print('SIM carregado')

# Gerando base do sih
sih <- dbGetQuery(con, query_sih)
print('SIH carregado')

# Gerando base do SINAN intoxicação exogena
intox <- dbGetQuery(con, query_intox)
print('SINAN intoxicação exógena carregado')

# Gerando base do esus
esus<- dbGetQuery(con, query_esus)
esus <- esus |> mutate(recem_nasc = as.character(recem_nasc))
print('e-SUS APS carregado')

esus <- bind_rows(
  esus |> 
    vitallinkage::as_char(), 
  sih |> 
    vitallinkage::as_char(),
  sim |> 
    vitallinkage::as_char(), 
  viol |> 
    vitallinkage::as_char(),
  intox |> 
    vitallinkage::as_char())

print('Base do linkage gerada')

# Limpar objetos temporários
rm(#esus,
  sih, sim, viol, intox, query_esus, query_sih, query_sim, query_viol, query_intox)
gc()
print('Objetos temporários removidos')

# Ajustes iniciais
esus <- esus |> 
  mutate(
    across(starts_with("dt_"), ~ ifelse(. == "", NA, .)),
    #nu_cpf = ifelse(str_detect(nu_cpf, "^[0-9.]+$"), as.numeric(nu_cpf), NA),
    ignora_maria = ifelse(ds_nome_mae1 == 'MARIA', NA, 1),
    ignora_francisca = ifelse(ds_nome_mae1 == 'FRANCISCA', NA, 1),
    ignora_josefa = ifelse(ds_nome_mae1 == 'JOSEFA', NA, 1),
    morreu = ifelse(!is.na(dt_obito), 1, NA),
    #nao_gemelar = ifelse(is.na(gemelar), 1, NA),
    nome_pac_6 = substr(ds_nome_pac, 1, 11),
    nome_5_12 = substr(ds_nome_pac, 5, 12),
    #dif_ob_nasc = dt_obito-dt_nasc,
    nome_menos_5d = str_sub(ds_nome_pac, end = -6),
    ignora_francisca_maria = ifelse(ds_nome_mae == 'FRANCISCA MARIA CONCEICAO', NA, 1),
    mae_last8 = substr(ds_nome_mae, nchar(ds_nome_mae) - 7, nchar(ds_nome_mae)),
    mae_menos5d = substr(ds_nome_mae, 1, nchar(ds_nome_mae) - 5),
    mae_menos10d = substr(ds_nome_mae, 1, nchar(ds_nome_mae) - 10),
    nome_menos_2d = str_sub(ds_nome_pac, end = -2),
    dt_nasc = ymd(dt_nasc),
    ano_nasc = year(dt_nasc),
    mes_nasc = month(dt_nasc),
    dia_nasc = day(dt_nasc),
    dt_evento_inicio = coalesce(dt_internacao, dt_ocor, dt_notific, dt_inicio_ap, dt_obito), # dt_obito só vale para o SIM
    dt_evento_fim = coalesce(dt_saida, dt_fim_ap),
    dt_registro = coalesce(dt_emissao, dt_notific, dt_inicio_ap, dt_atestado, dt_obito), # Criar a dt_atestado e/ou outra data do SIM - 
    recem_nasc = as.numeric(recem_nasc),
    nao_recem_nasc = case_when(recem_nasc == 1 ~ NA, TRUE~1)
  ) |> # Data do evento e data do registro
  group_by(ds_nome_pac1) |> 
  mutate(nome_raro = n()) |> 
  ungroup() |> 
  mutate(nome_raro = ifelse(nome_raro == 2, 1, NA)) |> 
  ungroup() |> 
  mutate(
    pac_13 = substr(ds_nome_pac, 1, 13),
    mae_13 = substr(ds_nome_mae, 1, 13),
    nu_tel_novo = coalesce(nu_tel_cel, nu_tel, nu_tel_contato),
    tel_sem_ddd = str_remove_all(nu_tel_novo, "[^0-9]"),
    tel_sem_ddd = if_else(
      str_starts(tel_sem_ddd, "81"),
      str_sub(tel_sem_ddd, 3),
      tel_sem_ddd
    ),
    tel_sem_ddd = if_else(
      tel_sem_ddd %in% c("000000000", "00000000000", "99999999999", "900000000", "98888888",
                         "", "201101400", "20110100", "20110181", "20111000", "20111010",
                         "201110100", "20111011",  "20112100", "21000000", "21000100", "21001101",
                         "21010011", "21010100", "21011100", "21050000", "212105000",
                         "2121050000", "0", "999999999", "6133152425", "999999990", "99999990",
                         "33152425", "99999999", "988888888", "33552178"),
      NA_character_,
      tel_sem_ddd
    )
  )

print('Novas variáveis criadas')

gc()

print('Base preparada para iniciar o linkage!')

# 'ds_nome_pac', 'ds_nome_mae1_sound', 'ds_nomemae3', 'dia_nasc', 'ano_nasc', 'nu_tel_cel'

source('global.R')

# 1. ‑‑ Cria somente a estrutura (0 linhas) -----------------------------
dbWriteTable(
  conn      = con,
  name      = SQL("processo_linkage"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = esus,              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE
)

# 2. ‑‑ Ajusta tipos/constraints depois que a tabela existe -------------
dbExecute(con, "
  ALTER TABLE processo_linkage 
    ADD PRIMARY KEY (id_esus_aps)
")

# 3. ‑‑ Insere o conteúdo real (mantém o esquema) -----------------------
tictoc::tic()
dbAppendTable(con, "processo_linkage", esus)
tictoc::toc()
