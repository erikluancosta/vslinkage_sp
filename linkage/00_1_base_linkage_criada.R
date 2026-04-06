source('global.R')
source('funcoes/algoritmo.R')

df <- dbGetQuery(
  con,
  "SELECT * FROM processo_linkage"
)


df <- df |>
  start_linkage_dt(c('nu_doc', 'ds_nome_pac_sound', "ano_nasc")) 



# Regra para iniciar o linkage - Ok
tictoc::tic('tempo total do linkage')
#df <- df |> select(par_1, par_c1, ds_nome_pac, dt_nasc, ds_nome_mae, nu_cns, everything())
# Regra 2 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac", "dt_nasc", "ds_nome_mae", "nu_cns"),
    2)

# Regra 3 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3", "dt_nasc", "ds_nome_mae1", "ds_nome_mae2", "nu_cns", "nao_recem_nasc"),
    3)

# Regra 4 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3", "dt_nasc", "ds_nome_mae1", "ds_nome_mae3", "nu_cns","nao_recem_nasc"),
    4)

# Regra 5 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac", "dia_nasc","ano_nasc", "ds_nome_mae", "nu_cns"),
    5)

# Regra 6 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac", "mes_nasc","ano_nasc", "ds_nome_mae", "nu_cns"),
    6)

# Regra Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac", "mes_nasc","dia_nasc", "ds_nome_mae", "nu_cns"),
    7)

# Regra 8 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3","mes_nasc","dia_nasc", "ds_nome_mae", "nu_cns","nao_recem_nasc"),
    8)

# Regra 9 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3","ano_nasc","dia_nasc", "ds_nome_mae", "nu_cns","nao_recem_nasc"),
    9)

# Regra 10 - Ok 
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3","ano_nasc","mes_nasc", "ds_nome_mae", "nu_cns","nao_recem_nasc"),
    10)

# Regra 11 - Ok 
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3","ano_nasc", "dt_nasc", "ds_nome_mae3", "nu_cns","nao_recem_nasc"),
    11)

# Regra 12 - Ok 
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac2","ano_nasc","mes_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    12)

# VERSAO DAS 12 REGRAS COM SOUNDEX
# Regra 13 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "dt_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    13)

# Regra 14 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound", "dt_nasc", "ds_nome_mae1_sound", "ds_nome_mae2_sound", "nu_cns","nao_recem_nasc"),
    14)

# Regra 15 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound", "dt_nasc", "ds_nome_mae1_sound", "ds_nome_mae3_sound", "nu_cns","nao_recem_nasc"),
    15)

# Regra 16 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "dia_nasc","ano_nasc", "ds_nome_mae_sound", "nu_cns"),
    16)

# Regra 17 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "mes_nasc","ano_nasc", "ds_nome_mae_sound", "nu_cns"),
    17)

# Regra 18 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "mes_nasc","dia_nasc", "ds_nome_mae_sound", "nu_cns"),
    18)

# Regra 19 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound","mes_nasc","dia_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    19)

# Regra 20 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound","ano_nasc","dia_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    20)

# Regra 21 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound","ano_nasc","mes_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    21)

# Regra 22 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac3_sound","ano_nasc", "dt_nasc", "ds_nome_mae3_sound", "nu_cns","nao_recem_nasc"),
    22)

# Regra 23 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1_sound", "ds_nome_pac2_sound","ano_nasc","mes_nasc", "ds_nome_mae_sound", "nu_cns","nao_recem_nasc"),
    23)

# Regras com o telefone
# Regra 24 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "nu_tel", 'dt_nasc',"nao_recem_nasc"),
    24)

# Regra 25 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ds_nome_mae', 'dt_nasc'),
    25)

# Regra 26 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac_sound','dt_nasc','mae_menos10d', 'nao_recem_nasc', 'ds_nome_pac1'),
    26)

# Regra 27 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ds_nome_mae_sound', 'dt_nasc', 'ds_nome_mae1'),
    27)


# Regras 28 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1', 'dt_nasc', 'nome_raro',"nao_recem_nasc"),
    28
  )

# Regras 29 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1', 'dia_nasc', 'mes_nasc', 'nome_raro',"nao_recem_nasc", 'ds_nome_mae1_sound'),
    29
  )

# Regras 30 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1', 'ano_nasc', 'mes_nasc', 'nome_raro',"nao_recem_nasc", 'ds_nome_mae1_sound'),
    30
  )

# Regras 31 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1', 'ano_nasc', 'dia_nasc', 'nome_raro',"nao_recem_nasc", 'ds_nome_mae1_sound'),
    31
  )

# Regra 32 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac1", "ds_nome_pac3", "dt_nasc", "ds_nome_mae_sound", "dt_obito","nao_recem_nasc"),
    32)

# Regra 33 - Ok
df <- df |> 
  regras_linkage_dt(
    c("ds_nome_pac_sound", "dt_nasc", "ds_nome_mae_sound", "dt_obito","nao_recem_nasc"),
    33)

# Regra 34 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dt_nasc', 'dt_obito', 'ds_bairro_res', 'ds_nome_pac1_sound',"ds_nome_pac3_sound",'ds_nome_mae',"nao_recem_nasc"),
    34)

# Regra 35 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1_sound', 'nu_tel', 'ano_nasc', 'mes_nasc', 'ds_nome_mae1', 'ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    35
  )

# Regra 36 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dt_nasc', 'nome_menos_2d', 'ignora_maria', 'ignora_francisca', "ignora_josefa", 'mae_menos5d',"nao_recem_nasc"),
    36
  )

# Regra 37 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac_sound', 'dt_nasc', 'mae_menos5d', 'ignora_maria', 'ignora_francisca', "ignora_josefa"),
    37
  )

# Regra 38 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dt_nasc', 'nome_pac_6', 'ds_nome_mae','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    38
  )


# Regra 39 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dt_nasc', 'nome_pac_6', 'mae_menos5d','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    39
  )

# Regra 40 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dt_nasc', 'nome_5_12', 'mae_menos5d','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    40
  )

# Regra 41 - Ok
df <- df |> 
  regras_linkage_dt(
    c('dia_nasc', 'mes_nasc','nome_5_12', 'mae_menos5d','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc", 'ds_nome_pac1', 'dt_obito'),
    41
  )

# Regra 42 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ano_nasc', 'mes_nasc','nome_5_12', 'mae_menos5d','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc", 'ds_nome_pac1'),
    42
  )

# Regra 43 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ano_nasc', 'dia_nasc','nome_5_12', 'mae_menos5d','ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc", 'dt_obito'),
    43
  )

# Regra 44 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'dt_nasc', 'nu_cns','cd_mun_res', 'ds_bairro_res',"nao_recem_nasc"),
    44
  )

# Regra 45 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ano_nasc', 'dia_nasc','nu_cns','cd_mun_res', 'ds_bairro_res',"nao_recem_nasc"),
    45
  )

# Regra 46 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ano_nasc', 'mes_nasc','nu_cns','cd_mun_res', 'ds_bairro_res',"nao_recem_nasc"),
    46
  )

# Regra 47 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ds_nome_mae1','dia_nasc', 'mes_nasc','nu_cns','cd_mun_res', 'ds_bairro_res',"nao_recem_nasc"),
    47
  )

# Regra 48 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', "nu_tel", 'ds_nome_mae', 'ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    48
  )

# Regra 49 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', "nu_cns", 'ds_nome_mae', 'ignora_maria', 'ignora_francisca', "ignora_josefa","nao_recem_nasc"),
    49
  )

# Regra 50 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac_sound', 'dt_nasc', 'mae_menos5d', 'nu_tel',"nao_recem_nasc"),
    50
  )

# Regra 51 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_bairro_res','cd_mun_res','nome_menos_5d', 'mae_menos5d', 'dt_nasc', 'ignora_maria',"nao_recem_nasc"),
    51)

# Regra 52 - Ok
df <- df |> 
  regras_linkage_dt(
    c('mae_menos5d', 'ds_nome_pac1', 'ds_nome_pac2_sound', 'dt_nasc', 'ds_bairro_res', 'ds_nome_mae1_sound',"nao_recem_nasc"),
    52)


# Regra 53 - Ok
df <- df |> 
  regras_linkage_dt(
    c('mae_menos5d', 'nome_5_12', 'dt_nasc', "nu_cns",'nao_recem_nasc'),
    53)

# Regra 54 - Ok
df <- df |> 
  regras_linkage_dt(
    c('mae_menos5d', 'nome_5_12','ano_nasc' ,'mes_nasc', "nu_cns",'nao_recem_nasc'),
    54)

# Regras 55 - Ok
df <- df |> 
  regras_linkage_dt(
    c('mae_menos5d', 'nome_5_12','ano_nasc' ,'dia_nasc', "nu_cns",'nao_recem_nasc'),
    55)

# Regra 56 - Ok
df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ds_nome_mae1_sound', 'ds_nome_mae3', 'dia_nasc', 'ano_nasc', 'tel_sem_ddd'),
    56)

df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'ds_nome_mae1_sound', 'ds_nome_mae3', 'mes_nasc', 'ano_nasc', 'tel_sem_ddd'),
    57)


df <- df |> 
  regras_linkage_dt(
    c('pac_13', 'mae_13', 'dia_nasc', 'ano_nasc','mes_nasc', 'nu_cns'),
    58
  )

df <-  df |> 
  regras_linkage_dt(
    c('ds_nome_pac', 'mae_13','dia_nasc', 'ano_nasc', 'nu_cns', 'nao_recem_nasc'),
    59
  )


# rodar esses

df <-  df |> 
  regras_linkage_dt(
    c('pac_13', 'mae_13','mes_nasc', 'ano_nasc', 'nu_cns', 'nao_recem_nasc'),
    60
  )

df <-  df |> 
  regras_linkage_dt(
    c('pac_13', 'dt_nasc','ds_nome_mae_sound', 'nu_cns', 'nao_recem_nasc'),
    61
  )

df <- df |> 
  regras_linkage_dt(
    c('ds_nome_pac1', 'ds_nome_pac2_sound', 'dt_nasc', 'ds_nome_mae', 'nu_cns', 'nao_recem_nasc'),
    62
  )





dbWriteTable(
  conn      = con,
  name      = SQL("processo_linkage2"),   # use SQL() para preservar maiúsculas/minúsculas
  value     = df,              # dataframe zerado, mantém tipos
  overwrite = TRUE,                         # recria se já existir
  row.names = FALSE
)

# Registro linkage - craicao



duplo <- df %>% tab_2(id_pessoa, banco)

sim_duplicado <- df %>% 
  filter(par_1 %in% c(228647, 864623, 254555,1158143, 991406,1159199,1168388,1168441,
                      1168631,1168715, 1171561, 1171864, 1172714, 1173553, 1173569, 1174165, 1174202, 1174491)) %>% 
  select(par_1, starts_with('par_c'),ds_nome_pac, dt_nasc, ds_nome_mae, nu_cns, banco, dt_obito)

reduzido <- df %>% 
  select(par_1, ds_nome_pac, dt_nasc, ds_nome_mae, nu_cns, banco, dt_obito)
