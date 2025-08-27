###################################### MONITORAMENTO CLIMÁTICO / CLIMATIC MONITORING ####################################

########################################### CARREGANDO PACOTES / LOADING PACKAGES ######################################
library(dplyr)       # MANIPULAÇÃO DE DADOS / DATA MANIPULATION
library(readxl)      # LEITURA DE ARQUIVOS EXCEL / READING EXCEL FILES
library(lubridate)   # TRATAMENTO DE DATAS E HORAS / DATE AND TIME HANDLING

########################################### DEFINIR PASTA DE DADOS / SET DATA FOLDER ##################################
PASTA_DADOS = "data/"  # PASTA COM OS ARQUIVOS EXCEL / FOLDER WITH EXCEL FILES

########################################### LISTAR ARQUIVOS / LIST FILES #############################################
# LISTAR TODOS OS ARQUIVOS INTERNOS / LIST ALL INTERNAL FILES
arquivos_intern = list.files(PASTA_DADOS, pattern = "intern.*\\.xlsx$", full.names = TRUE)

# LISTAR TODOS OS ARQUIVOS EXTERNOS / LIST ALL EXTERNAL FILES
arquivos_extern = list.files(PASTA_DADOS, pattern = "extern.*\\.xlsx$", full.names = TRUE)

########################################### FUNÇÃO PARA LER E TRATAR ARQUIVOS / FUNCTION TO READ AND CLEAN FILES #######
ler_tratar_dados = function(arquivo) {
  # LER ARQUIVO / READ FILE
  dados = read_xlsx(arquivo)
  
  # CONVERTER TIPOS / CONVERT TYPES
  dados$DATA = as.Date(dados$DATA)
  dados$TEMPO = as.POSIXct(dados$TEMPO)
  dados$TEMPERATURA = as.numeric(dados$TEMPERATURA)
  dados$UMIDADE = as.numeric(dados$UMIDADE)
  
  # EXTRAIR HORA / EXTRACT HOUR
  dados$HORA = format(dados$TEMPO, "%H:%M:%S")
  
  # IDENTIFICAR DIAS COM MENOS DE 24 REGISTROS / IDENTIFY DAYS WITH LESS THAN 24 RECORDS
  grouped = dados %>%
    group_by(DATA) %>%
    summarize(num_registros = n())
  
  dias_faltantes = grouped %>%
    filter(num_registros < 24) %>%
    pull(DATA)
  
  # DUPLICAR LINHA SE FALTAR APENAS 1 REGISTRO / DUPLICATE ROW IF ONLY 1 RECORD IS MISSING
  for (data_dia in dias_faltantes) {
    if (sum(dados$DATA == data_dia) == 23) {
      linha_duplicada = dados %>% filter(DATA == data_dia) %>% slice_tail(n = 1)
      dados = bind_rows(dados, linha_duplicada)
    }
  }
  
  # REMOVER DIAS COM MENOS DE 23 REGISTROS / REMOVE DAYS WITH LESS THAN 23 RECORDS
  dias_muitos_faltantes = grouped %>%
    filter(num_registros < 23) %>%
    pull(DATA)
  
  dados = dados %>%
    filter(!(DATA %in% dias_muitos_faltantes))
  
  # MANTER SOMENTE REGISTROS EM HORAS CHEIAS / KEEP ONLY RECORDS ON FULL HOURS
  dados = dados[format(dados$TEMPO, "%M") == "00", ]
  
  return(dados)
}

########################################### LER TODOS OS ARQUIVOS / READ ALL FILES ####################################
# LER E COMBINAR DADOS INTERNOS / READ AND COMBINE INTERNAL DATA
dados_intern = do.call(rbind, lapply(arquivos_intern, ler_tratar_dados))

# LER E COMBINAR DADOS EXTERNOS / READ AND COMBINE EXTERNAL DATA
dados_extern = do.call(rbind, lapply(arquivos_extern, ler_tratar_dados))

########################################### JUNTAR DADOS / MERGE DATA #################################################
# PADRONIZAR HORÁRIO (APENAS HORA) / STANDARDIZE HOUR ONLY
dados_intern$HORA = format(strptime(dados_intern$HORA, "%H:%M:%S"), "%H")
dados_extern$HORA = format(strptime(dados_extern$HORA, "%H:%M:%S"), "%H")

# JUNTAR DADOS INTERNOS E EXTERNOS PELO DIA E HORA / MERGE INTERNAL AND EXTERNAL DATA BY DAY AND HOUR
dados_combinados = merge(dados_intern, dados_extern, by=c("DATA", "HORA"), all=T)

# SELECIONAR COLUNAS DE INTERESSE E RENOMEAR / SELECT COLUMNS OF INTEREST AND RENAME
dados_combinados = dados_combinados %>%
  select(DATA, HORA, TEMPERATURA.x, UMIDADE.x, TEMPERATURA.y, UMIDADE.y)

colnames(dados_combinados) = c("Dia", "Hora", "Tint", "Uint", "Text", "Uext")

########################################### FUNÇÃO PARA PADRONIZAR HORÁRIOS / FUNCTION TO STANDARDIZE HOURS ##########
corrigir_horarios = function(hora) {
  if (nchar(hora) == 1) {
    return(paste0("0", hora, ":00:00"))
  } else if (nchar(hora) == 2 && !grepl(":", hora)) {
    return(paste0(hora, ":00:00"))
  } else {
    return(hora)
  }
}

dados_combinados = dados_combinados %>%
  mutate(Hora = sapply(Hora, corrigir_horarios))

########################################### EXPORTAR CSV FINAL / EXPORT FINAL CSV ####################################
write.csv2(dados_combinados, "data/dados_tratados.csv")
