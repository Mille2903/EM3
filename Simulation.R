#  Load Libraries
library(ggplot2)
library(lme4)
library(readr)
library(dplyr)
library(tidyr)


#  Step 1: Load Parent Wave Data
data <- read_table("Mean_Amplitude_Parent_Waves_N400.txt", col_names = FALSE)

# Rename columns
colnames(data) <- c("Unrelated", "Related", "ERPset")
# Convert character columns to numeric
data$Unrelated <- as.numeric(data$Unrelated)
data$Related <- as.numeric(data$Related)


# Step 2: Calculate Means
mean_unrelated <- mean(data$Unrelated, na.rm = TRUE)
mean_related <- mean(data$Related, na.rm = TRUE)

unrelated <- data$Unrelated
related <- data$Related
sd_cong <- sd(related, na.rm = TRUE)
sd_incong <- sd(unrelated, na.rm = TRUE)
pooled_sd <- sqrt((sd_cong^2 + sd_incong^2) / 2)

var_cong= var(related, na.rm = TRUE)
var_incong = var(unrelated, na.rm = TRUE)

#  Step 3: Simulate Data 
set.seed(42)
n_subjects <- nrow(data)
sd_value <- pooled_sd

sim_unrelated <- rnorm(n_subjects, mean_unrelated, sd_value)
sim_related <- rnorm(n_subjects, mean_related, sd_value)

#  Step 4: Combine into Long Format
Subject <- rep(1:n_subjects, each = 2)
Condition <- rep(c("Unrelated", "Related"), times = n_subjects)
Amplitude <- as.vector(rbind(sim_unrelated, sim_related))

sim_data <- data.frame(Subject, Condition, Amplitude)

# Step 5: Plot Simulated Data
ggplot(sim_data, aes(x = Condition, y = Amplitude)) +
  geom_violin(fill = "lightblue", color = "black") +
  geom_jitter(width = 0.1, alpha = 0.6) +
  labs(title = "Simulated N400 Amplitudes at CPz",
       y = "Amplitude (µV)") +
  theme_minimal()


ggplot(sim_data, aes(x = Condition, y = Amplitude)) +
  geom_boxplot(fill = "lightblue", color = "black", width = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.6) +
  labs(title = "Simulated N400 Amplitudes at CPz",
       y = "Amplitude (µV)") +
  theme_minimal()

ggplot(sim_data, aes(x = Condition, y = Amplitude)) +
  stat_summary(fun = mean, geom = "point", shape = 21, size = 4, fill = "lightblue") +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.1) +
  geom_jitter(width = 0.1, alpha = 0.4) +
  labs(title = "Simulated N400 Mean Amplitudes with SE",
       y = "Amplitude (µV)") +
  theme_minimal()
#  Step 6: Linear Mixed-Effects Model
#  Load lmerTest instead of lme4
install.packages("lmerTest")  # if not already installed
library(lmerTest)

#  Refit model with lmerTest
model <- lmer(Amplitude ~ Condition + (1 | Subject), data = sim_data)

#  Get summary with p-values
summary(model)


#Cohens d
d <- abs(mean_related - mean_unrelated) / pooled_sd

#Power analysis
library(pwr)
pwr.t.test(d = d, power = 0.8, sig.level = 0.05, type = "paired")
# 📤 Step 7: Export Simulated Data
write_csv(sim_data, "Simulated_N400_Data.csv")