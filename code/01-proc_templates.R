# limpa variaveis de sessão
rm(list = ls()) 



# Funções auxiliares
source(here::here("code/00-helper_functions.R"))

## ETAPA 1 - Ajuste dos Arquivos de Template -------------------

# Lista de todos os arquivos de templates na pasta
templates <- list.files(here("templates/raw"))
audio_temp <- list.files(here("audio_template/raw"))

pb <- progress_bar$new(
  format = "  Processando [:bar] :percent eta: :eta",
  total = length(templates), # Total de iterações
  clear = FALSE, 
  width = 60,
  force = TRUE
)


if(dir.exists(here("templates/processed"))){
    unlink(here("templates/processed"), recursive = TRUE)
}

dir.create(here("templates/processed"))  

if(dir.exists(here("audio_template/processed"))){
    unlink(here("audio_template/processed"), recursive = TRUE)
}

dir.create(here("audio_template/processed"))  

# Renomeia Templates
walk(templates,\(x) {
  print("Renomeando Arquivos de Template ...")
  pb$tick() # Avança a barra em cada iteração
  rename_template(x)
  
})


pb <- progress_bar$new(
  format = "  Processando [:bar] :percent eta: :eta",
  total = length(audio_temp), # Total de iterações
  clear = FALSE, 
  width = 60,
  force = TRUE
)

# Renomeia os Audio Templates
walk(audio_temp,\(x) {
  print("Renomeando Arquivos de Template de Audio ...")
  pb$tick() # Avança a barra em cada iteração
  rename_audio_tmp(x)
  
})

# Aplicando filtro nos templates

if(dir.exists(here("audio_template","filtered"))){
    unlink(here("audio_template","filtered"), recursive = TRUE)
}

dir.create(here("audio_template","filtered"))  


audio_temp_proc <- list.files(here("audio_template/processed"))


walk(audio_temp_proc, \(audio_proc){
  wav_filter(here("audio_template/processed",audio_proc)) |>
  normalize(unit = "16") |>
  writeWave(here("audio_template/filtered",str_replace(audio_proc,"\\.wav","_filt\\.wav")))
})



