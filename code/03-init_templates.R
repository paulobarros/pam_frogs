# limpa variaveis de sessão
rm(list = ls())

# Funções auxiliares
source(here::here("code/00-helper_functions.R"))

## Etapa 1 - Criação dos Templates ---------------------

templates <- list.files(here("templates/processed"))


temp <- data.table::fread(here("templates/processed",templates[[1]])) |>
  clean_names() |>
  select(selection, matches("time|freq")) |>
  mutate(selection = str_remove(templates[[1]],"\\.Table.*"),
          across(contains("freq"),~.x/1000),
          across(where(is.numeric),~round(.x, 2))
)


# Cria um template de busca para cada entrada (linha) no arquivo
# e combina os templates em um unico objeto
temp_comb <- 1:nrow(temp) |>
   map(\(entry){

    t <- temp[i = entry,]


    file <- readWave(here("audio_template","filtered",glue("{t$selection}_filt.wav")))

    makeCorTemplate(file,
      t.lim = c(as.numeric(t$begin_time_s), as.numeric(t$end_time_s)),
      frq.lim = c(as.numeric(t$low_freq_hz), as.numeric(t$high_freq_hz)),
      select = "auto",
      score.cutoff = 0.5,
      name = glue("{t$selection}_T{entry}"),
      spec.col = rainbow.1(15),
      wn = "hanning",
      wl = 1024,
      ovlp = 80)

  }) |>
  combineCorTemplates()

# Salvando objetos de template

# cria diretório com data da execução do script
dir.create(here("data",today()))

# salva template
saveRDS(temp_comb,here("data",today(),paste0("template_",today(),".RDS")))

