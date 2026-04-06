# Função para decodificar a raça/cor
ds_raca <- function(df){
  df <- df |> mutate(ds_raca=
                       case_when(
                         cd_raca == 1 ~ "Branca", 
                         cd_raca == 2 ~ "Preta",
                         cd_raca == 3 ~ "Amarela",
                         cd_raca == 4 ~ "Parda",
                         cd_raca == 5 ~ "Indígena",
                         cd_raca == 9 ~ "Ignorada",
                         TRUE ~ "Ignorada"
                       )
  )
}
# Função para decodificar a descrição do grupo do agente tóxico
ds_agente_tox <- function(df){
  df <- df |> mutate(ds_agente_tox =
                       case_when(  
                         cd_agente_tox == "01" ~ "Medicamento",
                         cd_agente_tox == "02" ~ "Agrotóxico/uso agrícola", 
                         cd_agente_tox == "03" ~ "Agrotóxico/uso doméstico",
                         cd_agente_tox == "04" ~ "Agrotóxico/uso saúde pública", 
                         cd_agente_tox == "05" ~ "Raticida", 
                         cd_agente_tox == "06" ~ "Produto Veterinário",
                         cd_agente_tox == "07" ~ "Produto de uso domiciliar", 
                         cd_agente_tox == "08" ~ "Cosmético / higiene pessoal",
                         cd_agente_tox == "09" ~ "Produto químico de uso industrial",
                         cd_agente_tox == "10" ~ "Metal",
                         cd_agente_tox == "11" ~ "Drogas de abuso", 
                         cd_agente_tox == "12" ~ "Planta tóxica",
                         cd_agente_tox == "13" ~ "Alimento e bebida", 
                         cd_agente_tox == "14" ~ "Outro", 
                         cd_agente_tox == "99" ~ "Ignorado",
                         TRUE ~"Ignorado"))
}

# Função para decodificar o local de ocorrência da exposição
ds_loc_expo <- function(df){
  df <- df |> 
    mutate(
      ds_loc_expo =
        case_when(
          cd_loc_expo == "1" ~ "Residência", 
          cd_loc_expo == "2" ~ "Ambiente de Trabalho", 
          cd_loc_expo == "3" ~ "Trajeto do trabalho", 
          cd_loc_expo == "4" ~ "Serviços de saúde", 
          cd_loc_expo == "5" ~ "Escola/creche",
          cd_loc_expo == "6" ~ "Ambiente Externo",
          cd_loc_expo == "7" ~ "Outro",
          cd_loc_expo == "9" ~ "Ignorado",
          TRUE ~ "Ignorado"
        )
    )
  
}

# Função para decodificar a via de exposição primeira opção
ds_via_1 <- function(df){
  df <- df |> 
    mutate(
      ds_cd_via1 =
        case_when(
          cd_via1 == "1" ~ "Digestiva", 
          cd_via1 == "2" ~ "Cutânea", 
          cd_via1 == "3" ~ "Respiratória", 
          cd_via1 == "4" ~ "Ocular", 
          cd_via1 == "5" ~ "Parenteral", 
          cd_via1 == "6" ~ "Vaginal", 
          cd_via1 == "7" ~ "Transplacentária", 
          cd_via1 == "8" ~ "Outra", 
          cd_via1 == "9" ~ "Ignorado",
          TRUE ~ "Ignorado"
        ))
}

# Função para decodificar a via de exposição segunda opção
ds_via_2 <- function(df){
  df <- df |> 
    mutate(
      ds_via_2 =
        case_when(
          cd_via2 == "1" ~ "Digestiva", 
          cd_via2 == "2" ~ "Cutânea", 
          cd_via2 == "3" ~ "Respiratória", 
          cd_via2 == "4" ~ "Ocular", 
          cd_via2 == "5" ~ "Parenteral", 
          cd_via2 == "6" ~ "Vaginal", 
          cd_via2 == "7" ~ "Transplacentária", 
          cd_via2 == "8" ~ "Outra", 
          cd_via2 == "9" ~ "Ignorado",
          TRUE ~ "Ignorado"
        ))
}

# Função para decodificar a Circunstância da exposição
ds_circunstan <- function(df){
  df <- df |> 
    mutate(ds_circunstan =
             case_when(
               cd_circunstan == "01" ~ "Uso habitual", 
               cd_circunstan == "02" ~ "Acidental", 
               cd_circunstan == "03" ~ "Ambiental", 
               cd_circunstan == "04" ~ "Uso terapêutico", 
               cd_circunstan == "05" ~ "Prescrição médica inadequada", 
               cd_circunstan == "06" ~ "Erro de administração", 
               cd_circunstan == "07" ~ "Automedicação",
               cd_circunstan == "08" ~ "Abuso", 
               cd_circunstan == "09" ~ "Ingestão de alimento ou bebida", 
               cd_circunstan == "10" ~ "Tentativa de suicídio",
               cd_circunstan == "11" ~ "Tentativa de aborto", 
               cd_circunstan == "12" ~ "Violência / homicídio", 
               cd_circunstan == "13" ~ "Outra", 
               cd_circunstan == "99" ~ "Ignorado",
               TRUE ~ "Ignorado"
             )
    )
}

# Função para decodificar o Tipo de exposição
ds_tpexp <- function(df){
  df <- df |> 
    mutate(ds_tpexp =
             case_when(
               cd_tpexpo == "1" ~ "Aguda – única", 
               cd_tpexpo == "2" ~ "Aguda – repetida", 
               cd_tpexpo == "3" ~ "Crônica", 
               cd_tpexpo == "4" ~ "Aguda sobre crônica",
               cd_tpexpo == "9" ~ "Ignorado",
               TRUE ~ "Ignorado"
             )
    )
  
}


# Função para decodificar o tipo de atendimento
ds_tpatend <- function(df){
  df <- df |> 
    mutate(ds_tpatend =
             case_when(
               cd_tpatende == "1" ~ "Hospitalar", 
               cd_tpatende == "2" ~ "Ambulatorial", 
               cd_tpatende == "3" ~ "Domiciliar", 
               cd_tpatende == "4" ~ "Nenhum",
               cd_tpatende == "9" ~ "Ignorado",
               TRUE ~ "Ignorado"
             )
    )
  
}

# Função para decodificar se houve hospitalização
ds_hospital <- function(df){
  df <- df |> 
    mutate(ds_hospital =
             case_when(
               cd_hospitalizacao == "1" ~ "Sim", 
               cd_hospitalizacao == "2" ~ "Não", 
               cd_hospitalizacao == "9" ~ "Ignorado",
               TRUE ~ "Ignorado"
             )
    )
  
}

# Função para decodificar a classificação final
## DESCOBRIR O QUE É O 8
ds_classi_fin <- function(df){
  df <- df |> 
    mutate(
      ds_classi_fin =
        case_when(
          cd_classi_fin == "1" ~ "Intoxicação Confirmada", 
          cd_classi_fin == "2" ~ "Exposição", 
          cd_classi_fin == "3" ~ "Reação adversa", 
          cd_classi_fin == "4" ~ "Diagnóstico diferencial", 
          cd_classi_fin == "5" ~ "Síndrome de abstinência", 
          cd_classi_fin == "9" ~ "Ignorado",
          TRUE ~ cd_classi_fin
        ))
}


# Decodificando a variável de Evolução do caso
ds_evolucao <- function(df){
  df <- df |> 
    mutate(
      ds_evolucao =
        case_when(
          cd_evolucao == "1" ~ "Cura sem sequela", 
          cd_evolucao == "2" ~ "Cura com sequela", 
          cd_evolucao == "3" ~ "Óbito por intoxicação exógena", 
          cd_evolucao == "4" ~ "Óbito por outra causa", 
          cd_evolucao == "5" ~ "Perda do seguimento", 
          cd_evolucao == "9" ~ "Ignorado",
          TRUE ~ "Ignorado"
        ))
}
