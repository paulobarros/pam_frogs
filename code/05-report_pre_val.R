rm(list = ls())


# Funções auxiliares
source(here::here("code/00-helper_functions.R"))


library(quarto)

rfolder <- now()

dir.create(here("reports",rfolder))

quarto_render(input = here("code","05-report_pre_val.qmd"))



# here("code","05-report_pre_val_files"),

file.copy(c(here("code","report_pre_val.html")),
here("reports",rfolder),
 recursive = T)

file.remove(c(here("code","report_pre_val.html")))

