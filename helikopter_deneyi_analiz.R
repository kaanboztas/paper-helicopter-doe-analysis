# ==============================================================================
# Kağıt Helikopterlerde Uçuş Süresini Etkileyen Faktörlerin İncelenmesi
# 3 Etkenli Tam Faktöriyel Deney Tasarımı (2^3 x 3 Tekrar = 24 Gözlem)
# Yazar: Kaan Boztaş
# Ders: İST 3032 - İstatistiksel Deney Tasarımı
# ==============================================================================

# ------------------------------------------------------------------------------
# 1) Gerekli Kütüphanelerin Yüklenmesi ve Dahil Edilmesi
# ------------------------------------------------------------------------------
gerekli_paketler <- c("car", "emmeans", "agricolae", "effectsize")
yeni_paketler <- gerekli_paketler[!(gerekli_paketler %in% installed.packages()[, "Package"])]
if (length(yeni_paketler) > 0) install.packages(yeni_paketler)

library(car)
library(emmeans)
library(agricolae)
library(effectsize)

# ------------------------------------------------------------------------------
# 2) Veri Setinin Oluşturulması
# ------------------------------------------------------------------------------
# Not: Veri doğrudan CSV dosyasından veya aşağıdaki veri çerçevesinden okunabilir.
if (file.exists("data/helicopter_flight_data.csv")) {
  verid_csv <- read.csv("data/helicopter_flight_data.csv", fileEncoding = "UTF-8")
  verid <- data.frame(
    A = factor(verid_csv$Kanat_A, levels = c("Kısa", "Uzun")),
    B = factor(verid_csv$Kuyruk_B, levels = c("Kısa", "Uzun")),
    C = factor(verid_csv$Kagit_C, levels = c("Saman", "A4")),
    Ucus_Suresi = verid_csv$Ucus_Suresi_sn
  )
} else {
  verid <- data.frame(
    A = factor(c(rep("Kısa", 3), rep("Uzun", 3), rep("Kısa", 3), rep("Uzun", 3),
                 rep("Kısa", 3), rep("Uzun", 3), rep("Kısa", 3), rep("Uzun", 3))),
    B = factor(c(rep("Kısa", 6), rep("Uzun", 6), rep("Kısa", 6), rep("Uzun", 6))),
    C = factor(c(rep("Saman", 12), rep("A4", 12))),
    Ucus_Suresi = c(
      9.39, 9.00, 8.89,     # Kanat(A)=Kısa, Kuyruk(B)=Kısa, Kağıt(C)=Saman
      7.13, 7.58, 7.40,     # Kanat(A)=Uzun, Kuyruk(B)=Kısa, Kağıt(C)=Saman
      11.01, 11.01, 9.51,   # Kanat(A)=Kısa, Kuyruk(B)=Uzun, Kağıt(C)=Saman
      10.65, 11.48, 11.30,  # Kanat(A)=Uzun, Kuyruk(B)=Uzun, Kağıt(C)=Saman
      8.33, 7.70, 6.91,     # Kanat(A)=Kısa, Kuyruk(B)=Kısa, Kağıt(C)=A4
      6.70, 6.82, 5.90,     # Kanat(A)=Uzun, Kuyruk(B)=Kısa, Kağıt(C)=A4
      10.41, 10.01, 10.82,  # Kanat(A)=Kısa, Kuyruk(B)=Uzun, Kağıt(C)=A4
      9.48, 10.41, 10.20    # Kanat(A)=Uzun, Kuyruk(B)=Uzun, Kağıt(C)=A4
    )
  )
}

# ------------------------------------------------------------------------------
# 3) Veri İnceleme ve Tanımlayıcı İstatistikler
# ------------------------------------------------------------------------------
cat("\n--- Veri Yapısı ve Özetleri ---\n")
str(verid)
summary(verid)

cat("\n--- Hücre Ortalamaları ---\n")
print(aggregate(Ucus_Suresi ~ A + B + C, data = verid, mean))

cat("\n--- Hücre Standart Sapmaları ---\n")
print(aggregate(Ucus_Suresi ~ A + B + C, data = verid, sd))

cat("\n--- Hücre Gözlem Sayıları ---\n")
print(aggregate(Ucus_Suresi ~ A + B + C, data = verid, length))

# ------------------------------------------------------------------------------
# 4) Üç Etkenli Faktöriyel ANOVA Modeli
# ------------------------------------------------------------------------------
set.seed(123)
model <- aov(Ucus_Suresi ~ A * B * C, data = verid)

cat("\n--- 3 Etkenli Tam Faktöriyel ANOVA Tablosu ---\n")
print(summary(model))

cat("\n--- Model Katsayıları ve Belirtme Katsayısı (R-Kare) ---\n")
print(summary.lm(model))

# ------------------------------------------------------------------------------
# 5) Varsayım Kontrolleri (Artık Analizi)
# ------------------------------------------------------------------------------
par(mfrow = c(2, 2))
# Doğrusallık ve Eşvaryanslık
plot(model, which = 1, main = "Artıklar vs Tahmin Edilen")
# Normallik (Q-Q Plot)
plot(model, which = 2, main = "Normal Q-Q Grafiği")
# Histogram
hist(residuals(model), main = "Artıkların Histogramı", xlab = "Artıklar", col = "lightblue", breaks = 10)
# Bağımsızlık (Gözlem Sırası)
plot(residuals(model), type = "b", main = "Artıklar vs Gözlem Sırası", xlab = "Gözlem No", ylab = "Artıklar", pch = 16, col = "darkgreen")
abline(h = 0, col = "red", lty = 2)
par(mfrow = c(1, 1))

cat("\n--- Shapiro-Wilk Normallik Testi ---\n")
print(shapiro.test(residuals(model)))

cat("\n--- Levene Testi (Varyans Homojenliği) ---\n")
print(leveneTest(Ucus_Suresi ~ A * B * C, data = verid))

cat("\n--- Bartlett Testi (Varyans Homojenliği) ---\n")
print(bartlett.test(Ucus_Suresi ~ interaction(A, B, C), data = verid))

# ------------------------------------------------------------------------------
# 6) Ana Etkileşim Grafikleri
# ------------------------------------------------------------------------------
par(mfrow = c(1, 3))
interaction.plot(verid$A, verid$B, verid$Ucus_Suresi, main = "Kanat x Kuyruk", xlab = "Kanat (A)", ylab = "Ortalama Uçuş Süresi (sn)", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b")
interaction.plot(verid$A, verid$C, verid$Ucus_Suresi, main = "Kanat x Kağıt", xlab = "Kanat (A)", ylab = "Ortalama Uçuş Süresi (sn)", trace.label = "Kağıt (C)", col = c("blue", "red"), pch = 16, type = "b")
interaction.plot(verid$B, verid$C, verid$Ucus_Suresi, main = "Kuyruk x Kağıt", xlab = "Kuyruk (B)", ylab = "Ortalama Uçuş Süresi (sn)", trace.label = "Kağıt (C)", col = c("blue", "red"), pch = 16, type = "b")
par(mfrow = c(1, 1))

# ------------------------------------------------------------------------------
# 7) Alt Gruplara Ayırma ve Basit Etkiler (Kağıt Sabitken)
# ------------------------------------------------------------------------------
cat("\n--- SADECE SAMAN KAĞIDI İÇİN ANOVA (C Sabit) ---\n")
print(summary(aov(Ucus_Suresi ~ A * B, data = subset(verid, C == "Saman"))))

cat("\n--- SADECE A4 KAĞIDI İÇİN ANOVA (C Sabit) ---\n")
print(summary(aov(Ucus_Suresi ~ A * B, data = subset(verid, C == "A4"))))

par(mfrow = c(1, 2))
with(subset(verid, C == "Saman"), interaction.plot(A, B, Ucus_Suresi, main = "Kağıt = Saman", xlab = "Kanat (A)", ylab = "Ortalama Uçuş Süresi (sn)", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b"))
with(subset(verid, C == "A4"), interaction.plot(A, B, Ucus_Suresi, main = "Kağıt = A4", xlab = "Kanat (A)", ylab = "Ortalama Uçuş Süresi (sn)", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b"))
par(mfrow = c(1, 1))

# ------------------------------------------------------------------------------
# 8) Tahmini Marjinal Ortalamalar (emmeans)
# ------------------------------------------------------------------------------
cat("\n--- Ana Etki Ortalamaları (emmeans) ---\n")
print(emmeans(model, ~ A))
print(emmeans(model, ~ B))
print(emmeans(model, ~ C))

cat("\n--- Tüm Hücre Ortalamaları (emmeans) ---\n")
print(emmeans(model, ~ A * B * C))

# ------------------------------------------------------------------------------
# 9) AB Etkileşimi Anlamlı Olduğu İçin Basit Etkiler (Tukey Düzeltmeli)
# ------------------------------------------------------------------------------
cat("\n--- B Sabitken A'nın Basit Etkileri ---\n")
emm_A <- emmeans(model, ~ A | B)
print(pairs(emm_A, adjust = "tukey"))

cat("\n--- A Sabitken B'nin Basit Etkileri ---\n")
emm_B <- emmeans(model, ~ B | A)
print(pairs(emm_B, adjust = "tukey"))

# ------------------------------------------------------------------------------
# 10) C'nin Ana Etkisi ve Etki Büyüklükleri (Eta Squared)
# ------------------------------------------------------------------------------
cat("\n--- C'nin Ana Etki Karşılaştırması ---\n")
emm_C <- emmeans(model, ~ C)
print(pairs(emm_C))

cat("\n--- Etki Büyüklükleri (Eta Squared - η²) ---\n")
etki_buyuklugu <- eta_squared(model)
print(etki_buyuklugu)

# ------------------------------------------------------------------------------
# 11) Final: Model Tahminleri ve Optimal Tasarım
# ------------------------------------------------------------------------------
tahminler <- predict(model, newdata = unique(verid[, 1:3]), interval = "confidence")
sonuc_raporu <- cbind(unique(verid[, 1:3]), round(tahminler, 3))
sonuc_raporu <- sonuc_raporu[order(-sonuc_raporu$fit), ] # En yüksek uçuştan en düşüğe sırala

cat("\n--- Tahmin Edilen Uçuş Süreleri ve Güven Aralıkları (Sıralı) ---\n")
print(sonuc_raporu)

cat("\n>>> EN İYİ (OPTİMAL) TASARIM KOMBİNASYONU <<<\n")
print(sonuc_raporu[1, ])
