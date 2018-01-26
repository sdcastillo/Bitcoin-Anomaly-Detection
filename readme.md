This app identifies sudden shifts in bitcoin (BTC) closing prices by fitting ARIMA models.  Once a model has been fit, outlying price jumps are
 determined by the absolute value of the standardized residuals of the model.  A sensitivity threshold is determined by the user.  For each 
abnormal date detected, additional stock information for a two-month window around this date is provided.

Instructions:

1. Input an evaluation time period in `Date Range`
2. Input a risk tolerance amount as `Sensitivity`
3. Identify when Bitcoin experiences abnormal price jumps
4. Profit 

The time series is first transformed with a natural logarithm to stabilize the variance, and then an ARFIMA model is fitted with the 
`auto.arima` function from the `forecast` package.  A fractional differencing algorithm produces an approximately stationary time series to then
fit with an ARMA model. This is found by looking over all possible combinations of AR and MA coefficients and ranking by AIC and BIC.

These models are far from perfect, but do not need be.  The purpose is not for prediction, but to merely identify abnormal price behavior.  For short time periods, the model is often a moving average MA(1), AR(1), or ARMA(1,1) model of the differenced log of the closing price.  Over longer time intervals, more complex models allow for greater sensitivity to price fluctuations.
