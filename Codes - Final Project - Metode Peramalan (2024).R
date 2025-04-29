# Memuat library yang diperlukan
library(ggplot2)
library(forecast)
library(tseries)
library(rpart)
library(TSA)
library(lubridate)
library(dplyr)

# Memuat dataset dan mengonversi kolom tanggal ke format datetime
df <- read.csv("C:/JPM-PD.csv")

# Memeriksa nilai yang hilang
sum(is.na(df))

head(df$Date)

# Konversi dan pengurutan data berdasarkan tanggal
df <- df[order(df$Date), ]
df$Date <- as.Date(df$Date)

# Membuat time series dari harga penutupan
close_ts <- ts(df$Close, start = c(2018, 10), frequency = 12)

# Menampilkan struktur dari time series yang baru dibuat
print(close_ts)

# Plot time series
plot(close_ts)
tsdisplay(close_ts)

# Visualisasi data harga penutupan seiring waktu dengan ggplot2
ggplot(df, aes(x = Date, y = Close, group = 1)) +
  geom_line() +
  ggtitle("Harga Penutupan Saham JPM") +
  xlab("Tahun") +
  ylab("Harga Penutupan") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Uji stasioneritas dengan Augmented Dickey-Fuller test
adf_test_weekly <- adf.test(close_ts, alternative = "stationary")
print(adf_test_weekly)

# Differencing untuk mencapai stasioneritas
datadiff <- diff(close_ts, differences = 1)
print(datadiff)

# Uji stasioneritas lagi dengan ADF test setelah differencing
adf_test_datadiff <- adf.test(datadiff)
print(adf_test_datadiff)

# Menampilkan time series setelah differencing
tsdisplay(datadiff)
eacf(datadiff)

# Plot hasil differencing
plot(datadiff)
tsdisplay(datadiff)

# Model ARIMA
model1 <- Arima(close_ts, order = c(0, 1, 1))
model2 <- Arima(close_ts, order = c(1, 1, 0))
model3 <- Arima(close_ts, order = c(1, 1, 1))

# Ringkasan dan perbandingan model
summary(model1)
summary(model2)
summary(model3)

# Kalkulasi AIC dan BIC untuk pemilihan model
AIC(model1, model2, model3)
cbind(model1, model2, model3)

# Memilih model terbaik
fit <- model2
fit

# Membagi data menjadi training dan testing untuk cross-validation
train_size <- floor(0.8 * length(close_ts))
train_data <- close_ts[1:train_size]
test_data <- close_ts[(train_size + 1):length(close_ts)]

# Melatih model pada training data
train_model <- auto.arima(train_data)

# Forecasting pada data test
forecast_horizon <- length(test_data)
forecast_test <- forecast(train_model, h = forecast_horizon)

# Menyusun dataframe hasil forecasting bersama dengan nilai actual
results <- data.frame(
  Date = df$Date[(train_size + 1):length(df$Date)],
  Actual = test_data,
  Forecast = as.numeric(forecast_test$mean)
)

# Menampilkan hasil forecasting beserta nilai actual
print(results)

# Menghitung MAE
mae <- mean(abs(results$Actual - results$Forecast))
print(paste("Mean Absolute Error (MAE):", mae))

# Menghitung MAPE
mape <- mean(abs((results$Actual - results$Forecast) / results$Actual) * 100)
print(paste("Mean Absolute Percentage Error (MAPE):", mape))

# Menghitung RMSE
rmse <- sqrt(mean((results$Actual - results$Forecast)^2))
print(paste("Root Mean Squared Error (RMSE):", rmse))

# Forecasting menggunakan model2 untuk 12 periode ke depan
forecast_future <- forecast(model2, h = 12)

# Menampilkan hasil forecasting
print(forecast_future)

# Plot hasil forecasting
autoplot(forecast_future) +
  ggtitle("Forecasting Harga Penutupan Saham JPM untuk 12 Periode Kedepan") +
  xlab("Tahun") +
  ylab("Harga Penutupan") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))