library(plumber)
library(DBI)
library(dygraphs)
library(xts)
library(dplyr)
library(DT)

con <- dbConnect(odbc::odbc(), "Postgres (DSN)")
bitcoin <- tbl(con, "bitcoin")

currency <- function(code="USD"){
  bitcoin %>%
    filter(name == code) %>%
    select(timestamp, last, symbol) %>%
    collect
}

#' @get /plot
#' @param code Currency code (DCA; JPY; CNY; GBP)
#' @serializer htmlwidget
function(code="USD"){
  dat <- currency(code)
  tseries <- xts(dat$last, dat$timestamp)
  lab <- paste0("Bitcoin (", dat$symbol[1], ")")
  p <- dygraph(tseries, main = lab) %>%
    dyOptions(axisLineWidth = 1.5, 
              fillGraph = TRUE, 
              drawGrid = FALSE, 
              colors = "steelblue", 
              axisLineColor = "darkgrey", 
              axisLabelFontSize = 15) %>%
    dyRangeSelector(fillColor = "lightsteelblue", strokeColor = "white")
  print(p)
}

#' @get /table
#' @param code Currency code (DCA; JPY; CNY; GBP)
#' @serializer htmlwidget
function(code="USD"){
  currency(code) %>%
    datatable
}

#' @get /data
#' @param code Currency code (DCA; JPY; CNY; GBP)
function(code="USD"){
  currency(code)
}

# rsconnect::deployAPI("bitcoin/05-api", account = "rstudio")
