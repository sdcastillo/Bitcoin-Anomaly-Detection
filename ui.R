library(shiny)
library(TSA)
library(zoo)
library(forecast)
library(lubridate)
library(dplyr)
library(readr)
library(tidyquant)
library(DT)

# Define UI for application 
shinyUI(fluidPage(
  titlePanel("Bitcoin Anomaly Detection using ARIMA Models"),
  div(style="display: inline-block;vertical-align:top; width: 1800px;",
      mainPanel(img(src='bitcoin.jpg', align = "right", width = 200))),
  
  mainPanel(
    div(style="display: inline-block;vertical-align:top; width: 500px;",
        sliderInput("alpha",
                     label ="Sensitivity",
                     min = 0.04,
                     max = 0.2,
                     step = 0.01,
                     value = 0.1)),
    #div(style="display: inline-block;vertical-align:top; width: 300px;",
        dateRangeInput('dateRange',
                       label = 'Date Range',
                       start = ymd("2017-11-17"),
                       end = ymd("2018-01-15"),
                       max = Sys.Date() - 1,
                       min = ymd("2009-01-01"),
                       width = '300px'
        )#)#end div
    ,
    div(style="display: inline-block;vertical-align:top; width: 1200px;",
      tabsetPanel(
        
        tabPanel("Anomaly Dates",
                 plotOutput("distPlot")
                
        ),
        tabPanel("Detailed Charts",
                 htmlOutput("selectUI"),
                 #plot output from quantmod
                 plotOutput("quantPlot")
        ),
        
        tabPanel("Data Table",
                 div(style = "width: 400px;",
                     DT::dataTableOutput("modelTable"),
                     downloadLink("ShinyData.csv", "Download csv")
                 )
        )
                 
      )#end tabset panel
    )#end div
  )
))

