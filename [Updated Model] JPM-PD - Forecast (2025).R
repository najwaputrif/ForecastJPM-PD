library(quantmod)
library(ggplot2)
library(forecast)
library(tseries)
library(TSA)
library(lubridate)
library(dplyr)
library(openxlsx)

# Retrieve data from Yahoo Finance
getSymbols("JPM-PD", src = "yahoo", from = "2021-01-01", to = "2024-12-31", periodicity = "monthly")
data <- `JPM-PD`

# Extract Close column and convert to data frame
close_xts <- Cl(data)
df <- data.frame(Date = index(close_xts), Close = coredata(close_xts))

# Create time series object
ts <- ts(df$JPM.PD.Close, start = c(2021, 1), frequency = 12)

# Plot overall time series
plot(ts, main = "Time Series of Closing Price", ylab = "Closing Price", xlab = "Year")

# Plot time series by year (overlay)
df_ts <- data.frame(
  Date = seq(as.Date("2021-01-01"), by = "month", length.out = length(ts)),
  Close = as.numeric(ts)
)
df_ts$Month <- month(df_ts$Date, label = TRUE, abbr = TRUE)
df_ts$Year <- factor(year(df_ts$Date))

ggplot(df_ts, aes(x = Month, y = Close, color = Year, group = Year)) +
  geom_line(size = 1) +
  labs(title = "Comparison of Closing Prices by Year (Monthly)",
       x = "Month", y = "Closing Price") +
  theme_minimal()

# Augmented Dickey-Fuller test for stationarity
adf_result <- adf.test(ts, alternative = "stationary")
print(adf_result)

# Differencing and retesting stationarity
ts_diff <- diff(ts, differences = 1)
adf_result_diff <- adf.test(ts_diff, alternative = "stationary")
print(adf_result_diff)

# Plot ACF, PACF, and EACF
tsdisplay(ts_diff)
eacf(ts_diff, ar.max = 8, ma.max = 8)

# Fit multiple ARIMA models for comparison
m1 <- Arima(ts, order = c(1, 1, 1), seasonal = c(1, 0, 0))
m2 <- Arima(ts, order = c(1, 1, 0), seasonal = c(1, 0, 0))
m3 <- Arima(ts, order = c(2, 0, 0), seasonal = c(1, 1, 0))
m4 <- Arima(ts, order = c(1, 0, 2), seasonal = c(1, 1, 0))
m5 <- Arima(ts, order = c(3, 0, 1), seasonal = c(1, 1, 0))

# Display coefficient summary of ARIMA models
printstatarima <- function(x, digits = 4, se = TRUE) {
  if (length(x$coef) > 0) {
    cat("\nCoefficients:\n")
    coef <- round(x$coef, digits = digits)
    if (se && nrow(x$var.coef)) {
      ses <- rep(0, length(coef))
      ses[x$mask] <- round(sqrt(diag(x$var.coef)), digits = digits)
      coef <- matrix(coef, 1, dimnames = list(NULL, names(coef)))
      coef <- rbind(coef, s.e. = ses)
      statt <- coef[1, ] / ses
      pval <- 2 * pt(abs(statt), df = length(x$residuals) - 1, lower.tail = FALSE)
      coef <- rbind(coef, t = round(statt, digits = digits), sign. = round(pval, digits = digits))
      coef <- t(coef)
    }
    print.default(coef, print.gap = 2)
  }
}

printstatarima(m1)
printstatarima(m2)
printstatarima(m3)
printstatarima(m4)
printstatarima(m5)

# Selected model
summary(m3)

# Forecast next 12 months using model m4
forecasted_values <- forecast(m4, h = 12)
forecast_dates <- seq(tail(index(close_xts), 1) + months(1), by = "month", length.out = 12)

# Plot the forecast result
autoplot(forecasted_values) + 
  ggtitle("Forecast of Closing Prices JPM-PD for January - December 2025") + 
  xlab("Time") + 
  ylab("Closing Prices") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Create forecast table with confidence intervals
forecast_table <- data.frame(
  Period = forecast_dates,
  Forecast = as.numeric(forecasted_values$mean),
  Lower95 = as.numeric(forecasted_values$lower[, "95%"]),
  Upper95 = as.numeric(forecasted_values$upper[, "95%"])
)

# Display forecast table
print(forecast_table)

# Export forecast table to Excel
write.xlsx(forecast_table, file = "JPM-PD - Forecast (2025).xlsx")
