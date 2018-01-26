

stockinfo = function(date = ymd("2018-01-10")){
  #Creates stock info for "details" page
  start.date =  date - 20
  end.date = date + 20
  
  #slightly redundant to redownload the data, but was the easiest way to get it as a time series object
  cur_BTC <- tq_get("BTC-USD", get = "stock.prices", 
                    from = as.character(start.date),
                    to = as.character(end.date))
  
  #output the candlestick plot
  out = cur_BTC %>%
    ggplot(aes(x = date, y = close, open = open,
               high = high, low = low, close = close)) +
    geom_candlestick() +
    geom_bbands(ma_fun = SMA, sd = 2, n = 5) +
    labs(title = "BTC Candlestick Chart", 
         subtitle = "BBands with SMA Applied", 
         y = "Closing Price", x = "") +
    theme_tq() + 
    theme_light()
  
  return(out)
  
}
