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
- **Ethics.** Sam favors decentralized banking when the security around it is white hat: the owner’s permission, a defined scope, a report back to that owner, and no theft. The college project is public math on a public price series. The sources are in [White hat standard](#white-hat).

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
  <a href="#white-hat">White hat</a>
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

<section class="sw-section" id="white-hat">
<div class="sw-section-head">
<h2>White hat standard <span class="sw-pill">Ethics</span></h2>
<p>The college math behind this page, and the reading Sam uses when he talks about decentralized markets.</p>
</div>
</section>

<p class="sw-intro">Samuel Castillo built this detector in January 2018, while he was still a mathematics student at UMass Amherst. He took a public series of daily Bitcoin closes, logged the price, fit an ARIMA model, and marked the days when the close left that path. The Shiny app, the knitted note, and the price file are public so a reader can see the rule. The purpose he gives the project is support for safe, fair trading of a decentralized currency: a mathematical way to notice an unusual day. The flag is statistical. A large residual means the close departed from that fit. It is not, by itself, a finding of fraud.</p>

<p class="sw-intro">Sam is in favor of decentralized banking, and of decentralized currencies, when the work around them is white hat. He is against black-hat intrusion, theft, and fraud. Businesses that want his support for this part of the industry are businesses that use cybersecurity to protect customers, publish their methods, and stay inside the law.</p>

<p class="sw-intro">The IQ.wiki glossary, cited below, states the white-hat test in four parts. The system owner gave written permission. The work stays inside an agreed scope. Findings go back to that owner, rather than being sold or leaked. Nothing is damaged or stolen. In crypto, that permission is usually a signed audit contract, a statement of work, or the published rules of a bug bounty. Remove any part of the test and the same intrusion can be a crime. Black-hat work is the failure of that test: access without permission, or harm to someone else’s assets.</p>

<p class="sw-intro">This repository stays on the public-data side of the line. <code>detect_anom()</code> fits <code>auto.arima</code> to the log close of a price file already in the project. A business can read the method, rerun it, and argue with the cutoff. The function does not sign in to an exchange, open a wallet, call a smart contract, or move coins. The 2018 project was a student statistics exercise. It was not a paid audit and it was not a rescue of funds.</p>

<p class="sw-intro">The ten notes below are short summaries of public writing, with the page they come from. They are the citations for the standard above: what ethical crypto security is, how groups such as the Security Alliance have tried to put legal rails around authorized response, and what brokerages and the Massachusetts Attorney General tell people who are being pitched a scam. Summaries are ours. The claims live on the linked pages.</p>

<div class="sw-grid">
<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://iq.wiki/wiki/whitehat">Whitehat</a></h3>
<span class="sw-lang">IQ.wiki</span>
</div>
<p class="sw-meta">Glossary · 25 September 2026</p>
<p>IQ.wiki defines a white hat as a security specialist who, with the system owner’s explicit authorization, looks for weaknesses in blockchains, smart contracts, exchanges, wallets, and bridges, then reports them in private. The aim is to prevent permanent on-chain loss. The entry’s four-part test is written permission, an agreed scope, a report to the owner, and no damage or theft. Responsible work stays off real user funds unless the owner has expressly allowed that contact.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://forklog.com/en/who-are-the-white-hats-and-how-do-they-protect-the-blockchain-industry/">Who Are “White Hats” and How Do They Protect the Blockchain Industry?</a></h3>
<span class="sw-lang">ForkLog</span>
</div>
<p class="sw-meta">12 November 2024</p>
<p>ForkLog treats white hats as people who protect blockchain projects with the owner’s permission, and who try to fix a weakness before a criminal finds it. The article points to smart-contract audits, bug-bounty programs, and platforms such as Immunefi and Hacken. It says the work has to respect confidentiality, non-disclosure agreements, and laws such as the U.S. Computer Fraud and Abuse Act and the EU GDPR. It also describes the Security Alliance’s Safe Harbor Agreement as an effort to give authorized responders clearer legal footing.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://cointelegraph.com/news/white-hat-hackers-saved-billions-crypto-seal-safe-harbor">Ethical hackers save crypto billions, SEAL’s Safe Harbor makes it possible</a></h3>
<span class="sw-lang">Cointelegraph</span>
</div>
<p class="sw-meta">1 October 2025</p>
<p>Cointelegraph reports that the Security Alliance had acknowledged 29 companies for adopting its Safe Harbor framework, a 2024 set of rules for projects and ethical responders during a live attack. As that article describes the rules, funds held for temporary safekeeping are to be returned within 72 hours, the bounty is 10 percent of recovered funds and capped at $1 million, and payment follows identity and sanctions checks. A legal-defense fund is mentioned for researchers who acted in good faith and then faced legal trouble.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://cointelegraph.com/news/ethical-hackers-alliance-crypto-hack-protection">White hat ‘SEAL’ team protecting from crypto hacks surpasses 900</a></h3>
<span class="sw-lang">Cointelegraph</span>
</div>
<p class="sw-meta">27 August 2024</p>
<p>An earlier Cointelegraph report says SEAL had received more than 900 hack-related tickets since its August 2023 launch. It describes the Whitehat Safe Harbor Agreement as a legal framework for ethical responders, with a defense fund for researchers who face claims after good-faith security work. Many laws forbid access to a computer system without authorization. The article’s point is legal clarity for people who already have a basis to act.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://hal.science/hal-04872249v1/document">HAL open-access paper, hal-04872249</a></h3>
<span class="sw-lang">HAL</span>
</div>
<p class="sw-meta">Open-access record hal-04872249</p>
<p>This HAL paper describes SEAL’s emergency reporting channel, training drills, legal agreements for recovery during an incident, and a way to share threat intelligence. Its finding is that security on public blockchains depends on norms, legal mechanisms, technical review, and incentives together. White-hat practice, in that account, is reporting a weakness so it can be fixed before a criminal uses it, including authorized recovery of funds inside those legal agreements.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://www.fidelity.com/learning-center/trading-investing/crypto-scams">How to protect yourself from crypto scams</a></h3>
<span class="sw-lang">Fidelity</span>
</div>
<p class="sw-meta">22 April 2026</p>
<p>Fidelity’s investor note says most crypto scams reuse impersonation, emotional pressure, and a promise of guaranteed returns. An unexpected message that asks someone to verify an account, move funds, or share a seed phrase, private key, password, or security code is a warning. A real firm does not contact customers to collect those secrets. The steps it recommends are research before acting, multi-factor authentication on financial and crypto accounts, and privacy for social-media and financial details.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://www.morganstanley.com/articles/cryptocurrency-scams">Crypto Scams to Watch Out For</a></h3>
<span class="sw-lang">Morgan Stanley</span>
</div>
<p class="sw-meta">4 August 2026</p>
<p>Morgan Stanley says scammers use crypto because a transfer is fast and usually cannot be reversed, and that common pitches include doubled investments, fake giveaways, and job fees. Impersonators pose as agencies, brokerages, or exchanges. The article tells readers to confirm any request on a phone number or website they looked up themselves, to treat a Bitcoin ATM demand as a red flag, to bookmark real addresses, and to ignore giveaway addresses on social media. It points reports to the FTC, the CFTC, the SEC, and the FBI’s Internet Crime Complaint Center. No U.S. government agency demands payment in cryptocurrency.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://www.mass.gov/info-details/beware-cryptocurrency-scams">Beware Cryptocurrency Scams</a></h3>
<span class="sw-lang">Mass.gov</span>
</div>
<p class="sw-meta">Massachusetts Attorney General</p>
<p>The Attorney General’s office warns that crypto is volatile and that criminals use romance and investment schemes, impersonation, fake coin offerings, and phony remote jobs. Ignore unsolicited crypto pitches. Be wary of sending coins to someone you have not met. Verify a debt on the organization’s own published number. Refuse any demand that cryptocurrency is the only way to pay. If funds have been sent, report the crime to local police and the FBI and keep both wallet addresses and each transaction hash. Private “recovery” firms often charge another fee and lack law enforcement’s authority.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://www.panewslab.com/zh/articles/01a0e779-8e4a-70f1-add8-5cae43a910d3">2026 最新防骗指南：币圈骗局，你知道几种？</a></h3>
<span class="sw-lang">PANews</span>
</div>
<p class="sw-meta">28 September 2026 · Chinese</p>
<p>PANews’s guide is a defensive checklist for people in crypto markets. Treat an unsolicited approach as something that may be fraud. Re-enter a project from its own official account and check the domain before using a link. Keep a device that holds large balances separate from the device used for chat, meetings, and downloads. Stop if a stranger pushes a meeting link, an installer, or a plugin. Keep the system and everyday software up to date, and confirm any transfer through a second channel you already trust.</p>
</article>

<article class="sw-card">
<div class="sw-card-top">
<h3 class="sw-name"><a href="https://erickimphotography.com/bitcoin-bounty-hunters-platforms-people-and-cases/">Bitcoin Bounty Hunters: Platforms, People, and Cases</a></h3>
<span class="sw-lang">Essay</span>
</div>
<p class="sw-meta">25 January 2026</p>
<p>This commentary uses “Bitcoin bounty hunter” for bug bounties, people who trace stolen coins, and investigators who work a case for a crypto reward. It also describes cases in which someone went after a thief and later returned funds for a reward. An unsanctioned counter-intrusion is not white hat under the test on this page. Permission, scope, a report to the owner, and no theft still govern. The essay is cited as part of the public conversation, and it should be read as commentary.</p>
</article>
</div>

<p class="sw-intro">For a business, the practical reading is short. Publish the method, as this student project does. Keep any test of someone else’s system inside written permission and a defined scope. Teach customers the scam checks in the Fidelity, Morgan Stanley, Massachusetts Attorney General, and PANews notes: unexpected payment demands, requests for keys, and strangers who insist on a download are reasons to stop and verify. Decentralized banking, on Sam’s terms, is worth supporting on that white-hat side.</p>
