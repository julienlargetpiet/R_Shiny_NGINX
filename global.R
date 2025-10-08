library("shiny")
#library("ggplot2") import if you want to lot exclusively with ggpot2, modify server.R and ui.R so 
library("plotly")
library("dplyr")
library("lubridate")
library("bslib")
library("readr")
library("shinymanager")
library("shinycssloaders")
library("DT")

credentials <- data.frame(
  user = c("admin"),
  password = c("adminpass"),
  admin = c(TRUE),
  stringsAsFactors = FALSE
)

Sys.setlocale("LC_TIME", "C")

options(shiny.maxRequestSize = 300 * 1024^2)

bot_keywords <- c(
  "bot","spider","crawler","curl","wget","python","scrapy",
  "ahrefs","ahrefsbot","semrush","mj12","dotbot",
  "googlebot","bingbot","yandex","uptime","pingdom","monitor",
  "facebookexternalhit","slurp","baiduspider"
)

bot_pat <- paste(bot_keywords, collapse = "|")


mult_map <- c(h = 3600, 
              d = 24 * 3600, 
              w = 7 * 24 * 3600, 
              m = 30 * 24 * 3600, 
              y = 365 * 24 * 3600)


interval_map <- c(h = "hour", 
                  d = "day", 
                  w = "week", 
                  m = "month", 
                  y = "year")




