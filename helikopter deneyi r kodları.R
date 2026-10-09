#### 1) Gerekli K??t??phanelerin Y??klenmesi ####
if (!require(car)) install.packages("car")
if (!require(emmeans)) install.packages("emmeans")
if (!require(agricolae)) install.packages("agricolae")

library(car)
library(emmeans)
library(agricolae)

#### 2) Veri Setinin Olu??turulmas?? ####
verid <- data.frame(
  A = factor(c(rep("Kisa", 3), rep("Uzun", 3), rep("Kisa", 3), rep("Uzun", 3),
               rep("Kisa", 3), rep("Uzun", 3), rep("Kisa", 3), rep("Uzun", 3))),
  B = factor(c(rep("Kisa", 6), rep("Uzun", 6), rep("Kisa", 6), rep("Uzun", 6))),
  C = factor(c(rep("Saman", 12), rep("A4", 12))),
  
  Ucus_Suresi = c(
    9.39, 9.00, 8.89,     # Kanat(A)=K??sa, Kuyruk(B)=K??sa, Ka????t(C)=Saman
    7.13, 7.58, 7.40 ,     # Kanat(A)=Uzun, Kuyruk(B)=K??sa, Ka????t(C)=Saman
    11.01, 11.01, 9.51,   # Kanat(A)=K??sa, Kuyruk(B)=Uzun, Ka????t(C)=Saman
    10.65, 11.48, 11.30,   # Kanat(A)=Uzun, Kuyruk(B)=Uzun, Ka????t(C)=Saman
    8.33, 7.70, 6.91,     # Kanat(A)=K??sa, Kuyruk(B)=K??sa, Ka????t(C)=A4
    6.70, 6.82, 5.90,     # Kanat(A)=Uzun, Kuyruk(B)=K??sa, Ka????t(C)=A4
    10.41, 10.01, 10.82,  # Kanat(A)=K??sa, Kuyruk(B)=Uzun, Ka????t(C)=A4
    9.48, 10.41, 10.20     # Kanat(A)=Uzun, Kuyruk(B)=Uzun, Ka????t(C)=A4
  )
)

#### 3) Veri ??nceleme ve Tan??mlay??c?? ??statistikler ####
print("--- Veri Yap??s?? ve Ozetleri ---")
str(verid)
summary(verid)

print("--- Hucre Ortalamalar?? ---")
aggregate(Ucus_Suresi ~ A + B + C, data = verid, mean)
print("--- HUcre Standart Sapmalar?? ---")
aggregate(Ucus_Suresi ~ A + B + C, data = verid, sd)
# H??cre gozlem sayilari
aggregate(Ucus_Suresi ~ A + B + C, data = verid, length)

#### 4) ???? Etkenli Fakt??riyel ANOVA Modeli ####
set.seed(123)
model <- aov(Ucus_Suresi ~ A * B * C, data = verid)
print("--- 3 Etkenli Tam Faktoriyel ANOVA Tablosu ---")
set.seed(123)

summary(model)
set.seed(123)

# Belirtme Katsay??s??na (R-Kare) Bakmak ????in:
summary.lm(model)

#### 5) Varsay??m Kontrolleri (Art??k Analizi) ####
par(mfrow = c(2, 2))
# Do??rusall??k ve Homojenlik
plot(model, which = 1)
# Normallik (Q-Q Plot)
plot(model, which = 2)
# Histogram
hist(residuals(model), main = "Art??klar??n Histogram??", xlab = "Art??klar", col = "lightblue", breaks = 10)
# Ba????ms??zl??k (G??zlem S??ras??)
plot(residuals(model), type = "b", main = "Artiklar vs Gozlem Sirasi", xlab = "Gozlem No", ylab = "Artiklar", pch = 16, col = "darkgreen")
abline(h = 0, col = "red", lty = 2)
par(mfrow = c(1, 1)) # ??izim panelini s??f??rla

print("--- Shapiro-Wilk Normallik Testi ---")
shapiro.test(residuals(model))

print("--- Levene Testi (Varyans Homojenligi) ---")
leveneTest(Ucus_Suresi ~ A * B * C, data = verid)

print("--- Bartlett Testi (Varyans Homojenligi) ---")
bartlett.test(Ucus_Suresi ~ interaction(A, B, C), data = verid)


#### 6) Ana Etkile??im Grafikleri ####
par(mfrow = c(1, 3))
interaction.plot(verid$A, verid$B, verid$Ucus_Suresi, main = "Kanat x Kuyruk", xlab = "Kanat (A)", ylab = "Ortalama Ucus Suresi", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b")
interaction.plot(verid$A, verid$C, verid$Ucus_Suresi, main = "Kanat x Ka????t", xlab = "Kanat (A)", ylab = "Ortalama Ucus Suresi", trace.label = "Ka????t (C)", col = c("blue", "red"), pch = 16, type = "b")
interaction.plot(verid$B, verid$C, verid$Ucus_Suresi, main = "Kuyruk x Ka????t", xlab = "Kuyruk (B)", ylab = "Ortalama Ucus Suresi", trace.label = "Ka????t (C)", col = c("blue", "red"), pch = 16, type = "b")
par(mfrow = c(1, 1))

#### 7) Alt Gruplara Ay??rma ve Basit Etkiler ####

# 7.1 - KA??IT (C) Sabitken Kanat ve Kuyruk Etkisi
print("--- SADECE SAMAN KAGIDI icin ANOVA (C Sabit) ---")
summary(aov(Ucus_Suresi ~ A * B, data = subset(verid, C == "Saman")))
print("--- SADECE A4 KAGIDI icin ANOVA (C Sabit) ---")
summary(aov(Ucus_Suresi ~ A * B, data = subset(verid, C == "A4")))

par(mfrow = c(1, 2))
with(subset(verid, C == "Saman"), interaction.plot(A, B, Ucus_Suresi, main = "Kag??t = Saman", xlab = "Kanat (A)", ylab = "Ortalama Ucus Suresi", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b"))
with(subset(verid, C == "A4"), interaction.plot(A, B, Ucus_Suresi, main = "Kag??t = A4", xlab = "Kanat (A)", ylab = "Ortalama Ucus Suresi", trace.label = "Kuyruk (B)", col = c("blue", "red"), pch = 16, type = "b"))
par(mfrow = c(1, 1))

### 8) emmeans ile ortalamalar ####

if (!require(emmeans)) install.packages("emmeans")
library(emmeans)

# Ana etki ortalamalari
emmeans(model, ~ A)
emmeans(model, ~ B)
emmeans(model, ~ C)

# Tum hucre ortalamalari
emmeans(model, ~ A * B * C)

##### 9) AB etkile??imi anlaml?? oldu??u i??in basit etkiler sadece A ve B aras??nda bak??l??r. ####

# B sabitken A n??n basit etkileri
emm_A <- emmeans(model, ~ A | B)
pairs(emm_A, adjust = "tukey")
# A sabitken B n??n basit etkileri
emm_B <- emmeans(model, ~ B | A)
pairs(emm_B, adjust = "tukey")

##### 10) C nin ana etkisi ######
emm_C <- emmeans(model, ~ C)
pairs(emm_C)

if (!require(effectsize)) install.packages("effectsize")
library(effectsize)


# Etki b??y??kl??klerini hesapla
etki_buyuklugu <- eta_squared(model)
print(etki_buyuklugu)

#### 11) Final: ####
# T??m kombinasyonlar i??in modelden gelen tahminler ve g??ven aral??klar??
tahminler <- predict(model, newdata = unique(verid[,1:3]), interval = "confidence")
sonuc_raporu <- cbind(unique(verid[,1:3]), tahminler)
sonuc_raporu <- sonuc_raporu[order(-sonuc_raporu$fit), ] # En iyiden en k??t??ye s??rala
print(sonuc_raporu)

# KOD SONU


