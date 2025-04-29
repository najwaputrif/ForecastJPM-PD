# 📊 ForecastJPM-PD

**ForecastJPM-PD** is a time series forecasting project built using R, designed to model and predict the monthly closing prices of JPMorgan Chase & Co. preferred stock (JPM-PD). This repository represents a personal extension of a previous academic group project and explores a new forecasting period from **January 2021 to December 2025** using updated data and improved seasonal ARIMA modeling.



## 🔍 Project Background

This project originated from an academic assignment for the course **Forecasting Methods**, part of the undergraduate program in Statistics at Universitas Indonesia. The original project applied classical ARIMA modeling to stock price forecasting.

This repository further develops the original work by incorporating:

- A new forecasting horizon (2021–2025)
- A refined model specification: **ARIMA(2,0,0)(1,1,0)**
- Enhanced visualization and interpretation tools
- Structured code and documentation for open-source collaboration

The data was obtained via [Yahoo Finance](https://finance.yahoo.com/quote/JPM-PD/history) for the ticker symbol **JPM-PD**.



## 📦 Features

- 📥 Automatic data retrieval from Yahoo Finance using `quantmod`
- 📉 Stationarity testing using Augmented Dickey-Fuller (ADF) test
- 🔁 First-order differencing for trend removal
- 📊 Visualization of time series trends by year with `ggplot2`
- 📈 ACF, PACF, and EACF analysis to guide model selection
- 🔧 Comparative modeling with multiple ARIMA variants:
  - ARIMA(1,1,1)(1,0,0)
  - ARIMA(1,1,0)(1,0,0)
  - ARIMA(2,0,0)(1,1,0) ← **selected model**
  - ARIMA(1,0,2)(1,1,0)
  - ARIMA(3,0,1)(1,1,0)
- 📤 Forecast output with 95% confidence intervals
- 📝 Export of results to `.xlsx` via `openxlsx`
- 🧾 Custom model summary printing with statistical significance



## ⚙️ Setup & Installation

Make sure you have R and RStudio installed. Then install the required packages:

```r
install.packages(c(
  "quantmod",   # financial data
  "forecast",   # time series forecasting
  "tseries",    # ADF test
  "TSA",        # EACF
  "ggplot2",    # visualization
  "dplyr",      # data wrangling
  "lubridate",  # date handling
  "openxlsx"    # Excel export
))
