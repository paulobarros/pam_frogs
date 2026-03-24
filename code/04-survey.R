# limpa variaveis de sessão
rm(list = ls())


# Funções auxiliares
source(here::here("code/00-helper_functions.R"))


raven_sel <- function(data,audio){

  pattern <- "^([[:alnum:]]+)_(\\d{4}-\\d{2}-\\d{2}_\\d{6})"

  folder_id <- str_match(audio,pattern = pattern)[2]
  datetime <- str_match(audio,pattern = pattern)[3]

  fname <- glue("{folder_id}_{str_replace_all(datetime,'-','')}.Table1.selections.txt")
  fnamexcel <- glue("{folder_id}_{str_replace_all(datetime,'-','')}.validate.csv")

  colnames <- c("Selection",	"View",	"Channel",	"Begin Time (s)",	"End Time (s)",	"Low Freq (Hz)",	"High Freq (Hz)")

  if(nrow(data)==0){

    raven_file <- data.frame(
      view = "Spectogram 1",
      channel = 1,
      bt = 0,
      et = 0,
      lf = 4000,
      hf = 6500
    ) |>
    mutate(sel = 1:n(), .before = 1)
    
    csv_file <- data |>
      add_row() |>
      mutate(sel = 1:n(), .before = 1) |>
      mutate(valid = NA_character_)

  }else{

    raven_file <- data.frame(
      view = "Spectogram 1",
      channel = 1,
      bt = floor(data$time),
      et = ceiling(data$time),
      lf = 4000,
      hf = 6500
  ) |>
    mutate(sel = 1:n(), .before = 1)

    csv_file <- data |>
      mutate(sel = 1:n(), .before = 1) |>
      mutate(valid = NA_character_)

  }
  


  colnames(raven_file) <- colnames

  # cria arquivo de selecao do Raven
  write.table(raven_file, 
    file = here("detections",today(),"raven_sel",folder_id, fname),
    quote = F, row.names = F, sep = "\t")
  
  # salva arquivo de detecao pra validação pos
  readr::write_excel_csv(csv_file,
    file = here("detections",today(),"raven_sel",folder_id, fnamexcel),
    quote = "needed"

  )

}


temp_save <- function(data,audio){

  pattern <- "^([[:alnum:]]+)_(\\d{4}-\\d{2}-\\d{2}_\\d{6})"

  folder_id <- str_match(audio,pattern = pattern)[2]
  datetime <- str_match(audio,pattern = pattern)[3]

  fname <- glue("{folder_id}_{str_replace_all(datetime,'-','')}_temp_det.RDS")
  

  # Salva Detecções em RDS
  saveRDS(data, file = here("detections",today(),"raven_sel",folder_id,fname))

  

}

rec_time <- function(recdate){

  pattern <- "^([[:alnum:]]+)_(\\d{4}-\\d{2}-\\d{2}_\\d{6})"

  datenew <- as.POSIXct(str_match(recdate,pattern = pattern)[3], format = "%Y-%m-%d_%H%M%S")
  
  return(datenew)

}


# Templates Combinados
tempList <- readRDS(here("data","2026-03-04","template_2026-03-04.RDS"))

# str_match("A01_2025-12-19_150000_-0300.wav","-300","UTC3")


# pattern <- "^([[:alnum:]]+)_(\\d{4}-\\d{2}-\\d{2}_\\d{6})"

# str_match("A01_2025-12-19_150000_UTC3_filt.wav",pattern = pattern)


land_folders <- list.files(here("landscape","filtered"))

# exclui pasta do dia pra não sobrescrever
unlink(here("detections"),recursive = TRUE)

# cria pasta da data
dir.create(here("detections",today(),"raven_sel"), recursive = TRUE)

land_folders |>
  set_names() |>
  walk(\(lsc_folder){

    

    # cria pasta pro raven por pasta
    dir.create(here("detections",today(),"raven_sel",lsc_folder))
    
    #print("*******************************************************")
    print(glue("*******************************************************\nPasta: {lsc_folder} .......\n*******************************************************"))
    #print("*******************************************************")

    # lista arquivos de survey em cada pasta
    survey_files <- list.files(here("landscape","filtered",lsc_folder), pattern = "*.wav")

    
    # Faz o survey por arquivo, salva o objeto e salva o arquivo de validacao do raven
    survey_files |>
      set_names() |>
      walk(\(sur_file){
        
        print("*******************************************************")
        print(glue("Audio: {lsc_folder} - {sur_file} ......."))
        print("*******************************************************")

        temp_det <- corMatch(survey = here("landscape","filtered",lsc_folder,sur_file),
          templates = tempList,
          parallel = TRUE,
          show.prog = TRUE,
          time.source = "filename",
          rec.tz = "America/Bahia") |>
            findPeaks() |>
            getDetections() |>
            mutate(date.time = rec_time(sur_file))
        
         raven_sel(temp_det, audio = sur_file)
        
        if(nrow(temp_det)==0){
          temp_det <- temp_det |>
            add_row() |>
            mutate(audio = sur_file, .before = 1)
        }else{
          temp_det <- temp_det |>
            mutate(audio = sur_file, .before = 1)
        }
        
        temp_save(temp_det,sur_file)
      })

  })


detections <- list.files(here("detections"),recursive = TRUE, pattern = "*.RDS", full.names = TRUE) |>
  map(\(x){
    return(readRDS(x))
  }) |>
  reduce(bind_rows)

detections <- 
total_det <- flatten(teste) |>
reduce(bind_rows)

saveRDS(detections, here("data","testDetections.RDS"))

detections |>
  glimpse()

#saveRDS(total_det,here("data","testDetections.RDS"))



teste <- readRDS("/mnt/PB-Cloud/COLABS/PAM_ANA/detections/2026-03-24/raven_sel/A03/A03_20251219_191500_temp_det.RDS")
