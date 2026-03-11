
source(here::here("code/00-helper_functions.R"))

library(tidyverse)


ggplot(iris,
aes(x = `Sepal.Length`, y = `Sepal.Width`,
fill = Species)
) +
  geom_point(shape =21,
  size = 4) +
  theme_bw()
