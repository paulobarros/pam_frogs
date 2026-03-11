# limpa variaveis de sessão
rm(list = ls()) 

# Funções auxiliares
source(here::here("code/00-helper_functions.R"))


## Etapa 1 - Renomeando arquivos de Landscape --------------------------


# Lista de pastas com audios

folders <- list.dirs(here("landscape/raw"), recursive = F, full.names = F)

if(dir.exists(here("landscape/processed"))){
    unlink(here("landscape/processed"), recursive = TRUE)
  }

dir.create(here("landscape/processed"))  

# Varre as pastas e renomeia os arquivos 
# YYYY-MM-DD_HHMMSS_TIMEZONE formato pra conseguir ler metadados na hora da varredura



with_progress({
  total_audios <- list.files(here("landscape/raw"),pattern = "*.wav", recursive = TRUE, include.dirs = FALSE)
  p <- progressor(steps = length(folders) * length(total_audios))
  
  walk(folders, \(folder) {
    # Esta mensagem fica fixa no histórico do console
    message(paste("\n>>> Processando pasta:", folder))

    dir.create(here("landscape/processed",folder))

    cur_folder <- list.files(here("landscape/raw",folder),pattern = "*.wav")
    
    walk(cur_folder,\(audio) {
      p()
        #print("Renomeando Arquivos de Audio do Landscape ...")
      rename_audio_lsc(audio,folder)  
    })

    message(paste("\n>>> Pasta:", folder, " Processada ..."))
    
  })
})



## Etapa 2 - Aplicando noise filter  --------------------------

if(dir.exists(here("landscape/filtered"))){
    unlink(here("landscape/filtered"), recursive = TRUE)
}

dir.create(here("landscape/filtered"))  


with_progress({
    
    total_audios <- list.files(here("landscape","processed"),pattern = "*.wav", recursive = TRUE, include.dirs = FALSE)

    p <- progressor(steps = length(folders) * length(total_audios))
    
    walk(folders, \(folder) {
      # Esta mensagem fica fixa no histórico do console
      
      dir.create(here("landscape","filtered",folder))

      message(paste("\n>>> Processando pasta:", folder))

      cur_folder <- list.files(here("landscape/processed",folder),pattern = "*.wav")
      
      walk(cur_folder,\(audio) {
        p()
        print(glue("Aplicando Noise Filter: {audio}"))

        print(here("landscape/processed",folder,audio))
        
        # Faz leitura do audio
        wav_file <- readWave(here("landscape","processed",folder,audio))

        # 2. Aplica o filtro (frequências em Hz)
        # 'from' e 'to' definem a janela de passagem
        audio_limpo <- ffilter(wav_file,
          from = 4000,
          to = 6000,
          bandpass = TRUE,
          wl = 1024,
          output = "Wave",
          wn = "hanning")
        
        audio_norm <- normalize(audio_limpo, unit = "16")
        
        # 3. Salva o novo arquivo "limpo"
        writeWave(audio_norm, here("landscape","filtered",folder,str_replace(audio,"\\.wav","_filt\\.wav")))


      })

      message(paste("\n>>> Pasta:", folder, " Processada ..."))
      
    })
  })


