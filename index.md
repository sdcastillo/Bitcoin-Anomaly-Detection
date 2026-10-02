---
layout: default
title: Bitcoin Anomaly Detection
description: ARIMA residuals that mark sudden jumps in the daily Bitcoin close.
samwiki: true
---

<p class="sw-intro">Samuel Castillo wrote this Shiny application in January 2018, during his mathematics studies at UMass Amherst. It takes a window of daily Bitcoin closing prices and marks the days when the close jumps away from the path an ARIMA model expects. The hosted detector still lives on shinyapps.io. This page is the walk-through, and the knitted note next to it keeps the original plots.</p>

<p class="sw-intro">The series that enters the model is the natural log of the closing price. On a log scale a move is a relative move, and the scatter does not grow just because the dollar level is higher. Over the dates you choose, <code>forecast::auto.arima</code> selects an ARIMA model for that log series: the differencing order, then the autoregressive and moving-average orders, ranked by the usual information criteria. A short window in this project often lands on a simple structure after differencing, such as an AR(1), an MA(1), or an ARMA(1,1). A longer window can keep a richer order, and that changes which days still look unusual.</p>

<p class="sw-intro">A day is flagged when the absolute residual from that fit exceeds the sensitivity you set. The residual is the gap, on the log-price scale, between the observed close and the value fitted by the ARIMA model. The slider runs from 0.04 to 0.20 in steps of 0.01 and starts at 0.10, so the default rule marks a log-residual larger than one tenth. A lower cutoff marks more days. A higher cutoff keeps the sharper breaks. The app opens on 17 November 2017 through 15 January 2018.</p>

<p class="sw-intro">Three tabs read those flags. <strong>Anomaly Dates</strong> plots the dollar close and draws a red point on each flagged day, with the point scaled by the residual. <strong>Detailed Charts</strong> takes one flagged date and draws a BTC-USD candlestick chart with Bollinger bands (a 5-day simple moving average, two standard deviations) on the twenty days before and after that date. <strong>Data Table</strong> lists the event date, the dollar change, and the percent change, and that table downloads as a CSV.</p>

<p class="sw-intro">The two pictures of a “band” in the repository are built differently, and it helps to keep them straight. In the knitted note, the ribbon is the fitted log price plus or minus 1.96 residual standard deviations, the usual normal 95% band on the log scale, and the example cutoff is α = 0.01 on 17 June 2017 through 18 August 2017. In the Shiny plot, the shaded ribbon is a loess smooth of an envelope around the dollar price: the close plus or minus five times (α times the standard deviation of the dollar residual, plus the mean of that residual). In both views the red points are the days that failed the residual cutoff. The band is context. The cutoff is the decision.</p>

### Key points

- **Who and when.** Samuel Castillo (sdcastillo), UMass Amherst Mathematics. The knitted note is dated 26 January 2018. License GPL-3.
- **Series.** The original app window and the worked example use the daily close from 1 January 2017 through 23 January 2018, saved as `BTC_Close_OLD.csv`. `BTC-USD.csv` is a separate daily open-high-low-close extract from 13 August 2022 through 13 August 2023.
- **Model.** Log closing price, then `auto.arima` from the R `forecast` package. The fit describes the ordinary path inside the window you chose.
- **Flag.** Mark the day when the absolute log-price residual exceeds the Sensitivity slider α. Default α = 0.10, range 0.04 to 0.20.
- **What you can open.** The [Shiny app](https://samdc.shinyapps.io/Bitcoin_Anomaly_Detection/), the [worked example with plots](example_for_article.html), and the source in `ui.R`, `server.R`, and `BTC_Functions.R`.

<p class="sw-actions" style="margin: 1.25rem 0 0.5rem;">
  <a class="sw-btn sw-btn-live" href="https://samdc.shinyapps.io/Bitcoin_Anomaly_Detection/">Open the Shiny app</a>
  <a class="sw-btn sw-btn-source" href="example_for_article.html">Worked example</a>
  <a class="sw-btn sw-btn-source" href="https://github.com/sdcastillo/Bitcoin-Anomaly-Detection">Source</a>
</p>

<p class="sw-jumps">
  <a href="#using-the-app">Using the app</a>
  <a href="#procedure">Procedure</a>
  <a href="#worked-example">Worked example</a>
  <a href="#repository">Repository</a>
</p>

<section class="sw-section" id="using-the-app">
<div class="sw-section-head">
<h2>Using the app <span class="sw-pill">Shiny</span></h2>
<p>The controls are the date window and one sensitivity number. The original instructions still hold.</p>
</div>
</section>

1. Choose an evaluation period in **Date Range**. The picker allows dates from 1 January 2009 through yesterday, and it opens on 17 November 2017 through 15 January 2018.
2. Set a risk tolerance with **Sensitivity**. This is the residual cutoff α.
3. Read the days when the Bitcoin close breaks that cutoff. Switch among Anomaly Dates, Detailed Charts, and Data Table.
4. Download the event table as a CSV if you want the flagged dates outside the app.

<section class="sw-section" id="procedure">
<div class="sw-section-head">
<h2>Procedure <span class="sw-pill">ARIMA</span></h2>
<p>Three steps, as the 2018 note lays them out. The implementation details below follow the Shiny server and the knitted example.</p>
</div>
</section>

1. **Make the series workable.** Take the natural log of the adjusted close so the variance is steadier, then let the model difference away the trend. The knitted note also plots the first difference of the log close so you can see that stationary-looking series. `auto.arima` chooses the integer differencing order itself.
2. **Fit the ARIMA model.** On the logged window, `auto.arima` searches AR and MA orders and keeps a model by its information criterion. The original write-up is frank about the fit: these models are rough, and they only have to be good enough to show which days refuse to sit on the fitted path. Heteroscedasticity, one-time breaks, and extra predictors are left outside this student version.
3. **Classify the outliers.** Compute the residuals of the log-price model. If the absolute residual is above α, the day is an anomaly. In the note, α = 0.01. In the app, α is the slider, default 0.10.

The original note also describes the stationary step as a fractional difference, an ARFIMA idea, before the ARMA fit. The code that ships here calls `auto.arima` on the log close, so the differencing order it selects is an integer. The flag is still the absolute residual of that fitted model.

<section class="sw-section" id="worked-example">
<div class="sw-section-head">
<h2>Worked example <span class="sw-pill">2017</span></h2>
<p>Same rule, one fixed window, with the plots kept in the page.</p>
</div>
</section>

The knitted page [Bitcoin Anomaly Detection Example](example_for_article.html) pulls BTC-USD from 1 January 2017 through 23 January 2018 and then studies 17 June 2017 through 18 August 2017 at α = 0.01. It shows four pictures in order: the dollar close, the log close, the differenced log close, and the fitted log series with the 1.96-sigma ribbon and the red anomaly points. Source for that note is `example_for_article.Rmd`.

<section class="sw-section" id="repository">
<div class="sw-section-head">
<h2>Repository <span class="sw-pill">R</span></h2>
<p>The Shiny app, the note, and both price files stay in the project root so GitHub Pages can publish this site from the default branch.</p>
</div>
</section>

- `ui.R` — title, sensitivity slider, date range, and the three tabs.
- `server.R` — `detect_anom()` filters the window, fits `auto.arima(log(close))`, and flags `|residual| > α`.
- `BTC_Functions.R` — `stockinfo()` draws the candlestick chart and Bollinger bands for twenty days on either side of a chosen event.
- `example_for_article.Rmd` and `example_for_article.html` — the January 2018 write-up and its rendered plots.
- `BTC_Close_OLD.csv` — daily close, 1 January 2017 through 23 January 2018.
- `BTC-USD.csv` — daily OHLC, 13 August 2022 through 13 August 2023.
- `DESCRIPTION` — Shiny app metadata: title, author Samuel Castillo, GPL-3, tag ARIMA.
