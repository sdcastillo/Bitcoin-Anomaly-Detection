library(shiny)
library(TSA)
library(zoo)
library(forecast)
library(lubridate)
library(dplyr)
library(readr)
library(tidyquant)
library(DT)

#read functions from source file
source("BTC_Functions.R", local = T)
#hard-coded main data source to reduce the number of API calls needed
BTC.df = read_csv("BTC_Close.csv")
BTC.ts = as.ts(BTC.df$BTC_close)
anom_dates = NULL

detect_anom = function(alpha = 0.1, start.date = ymd("2017-11-17"), end.date = ymd("2017-11-18")){  
  #take in user inputs, fit a model, and output a graph and table
  #convert data frame to time series object
  cur_data = BTC.df %>%
    filter(date >= start.date, date <= end.date) %>% 
    select(BTC_close) %>%
    as.ts()
  
  #dates for the x-axis
  dates = seq(from = start.date, to =  end.date, by = "days")
  
  #A model is fit the the log of the adjusted closing price
  model = auto.arima(log(cur_data))
  estimate = model$fitted
  
  #Calculate the raw, non-standardized residuals
  error = as.numeric(cur_data - exp(model$fitted))
  
  #a placeholder for calculated residuals
  t = 1:length(error)
  
  #outliers are classified by those above the sensitivity level
  #Identify the anomaly events
  anom_index = which( abs(residuals(model)) > alpha)
  
  #catching an empty-vector error
  if(length(anom_index) == 0){
    anom_dates = rep(0,5)
  } else {
    anom_dates = start.date + days(anom_index)
  }
  
  #put this all together into a data frame
  mydata = data_frame(date = dates, value = as.numeric(cur_data)) %>%
    #calculate upper and lower 90% confidence intervals and smooth them out
    mutate(upper = loess((value + (alpha*sd(error) + mean(error))*5) ~ t, span = 0.3)$fitted,
           lower = loess((value - (alpha*sd(error) + mean(error))*5)~ t, span = 0.3)$fitted)
  
  #create points for red dots on plot
  if(length(anom_index) ==0){
    anom_dates = rep(0, 10)
    points = data_frame(date = ymd("2000-01-01"), value = 0)
    point.size = 1
  } else {
    points = data_frame(date = anom_dates - 1, value = as.numeric(cur_data)[anom_index])
  point.size = residuals(model)[anom_index]*50}
  
  #table for output
  event_table = data_frame("Event Date" = as.character(anom_dates), "residual"= max(error[anom_index],0)) %>%
    arrange(residual) %>%
    mutate(`Price Change` = max(round(cur_data[anom_index] - cur_data[anom_index - 1],2),0),
           `Percent Change` = max(round(100*(cur_data[anom_index] - cur_data[anom_index - 1])/cur_data[anom_index]),0),0) %>%
    select(`Event Date`, `Price Change`, `Percent Change`)
  
  #plot object is created
  ggplot_1 = 
    ggplot(mydata, aes( x = date)) +
    #closing price
    geom_line(aes(y = value), color = "black") + 
    #confidence bands
    geom_ribbon(mapping = aes(ymin = lower, ymax = upper, fill = "90% confidence band for fitted ARIMA model"), alpha = 0.1, color = "lightblue") +
    #anomaly events
    geom_point( data = points, aes( date, value), size = point.size , color = "red", alpha = 0.5) +
    #text labels, titles, etc
    geom_text(data = points, aes( date, value), hjust = 0, vjust = 0, label = points$date) +
    ggtitle("Bitcoin (BTC) adjusted closing price") +
    xlab("Date") +
    ylab("Adjusted Close (USD)") +
    theme_light() +
    theme(axis.text=element_text(size=12),
          axis.title=element_text(size=14,face="bold"),
          legend.position = "bottom") + 
    labs(fill = "")
  
  output = list(date = anom_dates, plot = ggplot_1, model = model, event_table = event_table)  
  
  return(output)
}

# Define server logic reactive output
shinyServer(function(input, output, session) {
  
  #allows for fast updating based on input
  dataInput <- reactive({
    detect_anom(alpha = input$alpha,
                start.date = input$dateRange[1],
                end.date = input$dateRange[2])
  })
  
  output$distPlot <- renderPlot({
    #main plot with labeled anomalies
    dataInput()$plot
  })
  
  output$modelTable = DT::renderDataTable({
    #table with event price changes, percent changes, and dates
    dataInput()$event_table
  })
  
  #reactive input selection 
  output$selectUI <- renderUI({
    selectInput("anomDates", "Select specific event date", as.character(dataInput()$date))
  })
  
  output$quantPlot <- renderPlot({
    #stock information 
    stockinfo(date = ymd(input$anomDates))
    
  })
  
  output$ShinyData.csv <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file){
      write.csv(dataInput()$event_table, file)
      }, 
    contentType = "text/csv"
  )
  
})