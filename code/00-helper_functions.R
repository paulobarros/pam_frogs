# pacotes
pacman::p_load(tidyverse,monitoR,here,glue,janitor,RColorBrewer,tuneR, seewave,progress,progressr)

# instala pacotes
# só precisa rodar a primeira vez pra instalar

if (!require("pacman")) install.packages("pacman")


# Renomeia Templates

rename_template <- function(old_name) {

  pattern <- "^([[:alnum:]]+)_(\\d{4})(\\d{2})(\\d{2})_(\\d{6})\\.(.*)$"

  match <- str_match(old_name, pattern)

  folder <- match[2]
  year      <- match[3]
  month      <- match[4]
  day      <- match[5]
  time     <- match[6]
  ext <- match[7]
  tz     <- "UTC3"

  new_name <- str_glue("{folder}_{year}-{month}-{day}_{time}_{tz}.{ext}")

  file.copy(here("templates/raw",old_name), here("templates/processed",new_name))

}


# Renomeia Arquivos de Audio

rename_audio_lsc <- function(old_name,folder) {

  pattern <- "^([[:alnum:]]+)_(\\d{4})(\\d{2})(\\d{2})_(\\d{6})\\.(.*)$"

  match <- str_match(old_name, pattern)

  folder <- match[2]
  year      <- match[3]
  month      <- match[4]
  day      <- match[5]
  time     <- match[6]
  ext <- match[7]
  tz     <- "UTC3"

  new_name <- str_glue("{folder}_{year}-{month}-{day}_{time}_{tz}.{ext}")

  file.copy(here("landscape/raw",folder,old_name), here("landscape/processed",folder,new_name))

}

rename_audio_tmp <- function(old_name) {

  pattern <- "^([[:alnum:]]+)_(\\d{4})(\\d{2})(\\d{2})_(\\d{6})\\.(.*)$"

  match <- str_match(old_name, pattern)

  folder <- match[2]
  year      <- match[3]
  month      <- match[4]
  day      <- match[5]
  time     <- match[6]
  ext <- match[7]
  tz     <- "UTC3"

  new_name <- str_glue("{folder}_{year}-{month}-{day}_{time}_{tz}.{ext}")

  file.copy(here("audio_template/raw",old_name), here("audio_template/processed",new_name))

}


wav_filter <- function(audio) {
  wav_file <- readWave(audio)

        # 2. Aplica o filtro (frequências em Hz)
        # 'from' e 'to' definem a janela de passagem
        audio_limpo <- ffilter(wav_file,
          from = 4000,
          to = 7000,
          bandpass = TRUE,
          wl = 1024,
          output = "Wave",
          wn = "hanning") 
        
        # 3. Retorna arquivo filtrado
          return(audio_limpo)
        
}

