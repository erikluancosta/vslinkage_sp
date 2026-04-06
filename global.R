#---------------------------
# Carregando pacotes
#---------------------------
library(vitallinkage)
library(vitaltable)
library(tidyr)
library(dplyr)
library(foreign)
library(RPostgres)
library(DBI)
library(stringi)
library(stringr)
library(lubridate)


#---------------------------
# Carregar a função de conexão
#---------------------------
source('conectar/conectar.R')
con <- conectar('aws')
rm(conectar)