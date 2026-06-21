# ==============================================================
# APPLY LDA MODEL TO NEW SPECIMENS
# Suárez-Ibarra et al. (submitted)
# Classify new Globigerinoides specimens (G. ruber vs G. elongatus)
# using the morphological model from the revised taxonomy.
# ==============================================================

#Install libraries
#library(geomorph)
#library(abind)
#library(MASS)
#library(ggplot2)
#library(dplyr)
#library(ggrepel)

# Load required libraries
library(geomorph)
library(abind)
library(MASS)
library(ggplot2)
library(dplyr)
library(ggrepel)

# ==============================================================
# SETUP: point R at the repository folder, then use relative paths
# ==============================================================
# Set this ONCE to wherever you downloaded the repository.
# Everything below is read relative to it, so the script runs
# unchanged on any computer.
# setwd("path/to/foram-morphology-database")                         # <- EDIT THIS LINE

# ==============================================================
# STEP 1: LOAD THE REFERENCE DATASET (REVISED TAXONOMY)
# ==============================================================
cat("\n=== STEP 1: Loading reference dataset ===\n")

landmarks_G_elongatus   <- readland.tps("G_elongatus.tps",   specID = "ID")
landmarks_G_ruber_albus <- readland.tps("G_ruber_albus.tps", specID = "ID")
landmarks_G_ruber_ruber <- readland.tps("G_ruber_ruber.tps", specID = "ID")

n_G_elongatus   <- dim(landmarks_G_elongatus)[3]
n_G_ruber_albus <- dim(landmarks_G_ruber_albus)[3]
n_G_ruber_ruber <- dim(landmarks_G_ruber_ruber)[3]

cat("Loaded", n_G_elongatus, "G. elongatus,", n_G_ruber_albus,
    "G. ruber albus and", n_G_ruber_ruber, "G. ruber ruber specimens\n")

# ==============================================================
# STEP 2: DIGITIZE OR LOAD NEW SPECIMENS
# ==============================================================
cat("\n=== STEP 2: Loading new specimens ===\n")

# --- OPTION A: digitize new images (uncomment to use) ---
# setwd("path/to/foram-morphology-database/New_samples")                         # <- EDIT THIS LINE
# Put your .jpg images in  path/to/foram-morphology-database/New_samples/  then run:
# new_files <- list.files("path/to/foram-morphology-database/New_samples", pattern = "\\.jpg$", full.names = TRUE)
# digitize2d(
#   new_files,
#   nlandmarks = 16,                # 16 landmarks, as in the reference set
#   scale      = NULL,
#   tpsfile    = "New_samples.tps",                                                   
#   MultScale  = FALSE,
#   verbose    = FALSE              # set to TRUE, to double check each (semi)landmark
# )
# NOTE: if a landmark is misplaced for one specimen, open the .tps file with 
# "Block notes" or similar, replace that specimen's coordinates with "0 0" (as for
# un-analysed images), save, and digitize it again.

# --- OPTION B: load an existing .tps file ---
# setwd("path/to/foram-morphology-database/New_samples")                         # <- EDIT THIS LINE
#new_landmarks <- readland.tps("New_samples.tps", specID = "ID")     
#n_new <- dim(new_landmarks)[3]

cat("Loaded", n_new, "new specimens\n")

# ==============================================================
# STEP 3: POOL G. ruber albus + G. ruber ruber AS G. ruber
# ==============================================================
landmarks_G_ruber <- abind(landmarks_G_ruber_albus, landmarks_G_ruber_ruber, along = 3)
n_G_ruber <- dim(landmarks_G_ruber)[3]

# ==============================================================
# STEP 4: ALIGN ALL SPECIMENS TOGETHER WITH GPA
# ==============================================================
cat("\n=== STEP 4: Aligning all specimens with GPA ===\n")

all_landmarks <- abind(landmarks_G_elongatus, landmarks_G_ruber, new_landmarks, along = 3)
aligned_all   <- gpagen(all_landmarks, Proj = TRUE)
coords_all    <- aligned_all$coords
cat("GPA completed\n")

# ==============================================================
# STEP 5: TRAIN LDA MODEL ON REFERENCE SPECIMENS
# ==============================================================
cat("\n=== STEP 5: Training LDA model on reference specimens ===\n")

n_reference     <- n_G_elongatus + n_G_ruber
reference_coords <- coords_all[, , 1:n_reference]
land_df_ref     <- as.data.frame(two.d.array(reference_coords))

species_ref <- factor(c(rep("G_elongatus", n_G_elongatus),
                        rep("G_ruber",     n_G_ruber)))

lda_model <- lda(species_ref ~ ., data = land_df_ref)
cat("LDA model trained successfully\n")

lda_var          <- lda_model$svd^2
lda_var_explained <- lda_var / sum(lda_var)
cat("LD1 explains", round(lda_var_explained[1] * 100, 1),
    "% of between-group variation\n")

# ==============================================================
# STEP 6: CLASSIFY NEW SPECIMENS
# ==============================================================
cat("\n=== STEP 6: Classifying new specimens ===\n")

land_df_all <- as.data.frame(two.d.array(coords_all))
new_indices <- (n_reference + 1):(n_reference + n_new)
predictions <- predict(lda_model, newdata = land_df_all[new_indices, ])

# ==============================================================
# STEP 7: VIEW AND SAVE RESULTS
# ==============================================================
cat("\n=== STEP 7: Results ===\n")

# Confidence is based on the WINNING class probability (max posterior),
# so a confident G. ruber call is scored as confidently as a G. elongatus one.
max_posterior <- apply(predictions$posterior, 1, max)

results <- data.frame(
  Specimen_ID       = rownames(land_df_all)[new_indices],
  Predicted_Species = as.character(predictions$class),
  LD1               = round(predictions$x[, 1], 3),
  Prob_elongatus    = round(predictions$posterior[, "G_elongatus"], 3),
  Prob_ruber        = round(predictions$posterior[, "G_ruber"], 3),
  Classification_Confidence = case_when(
    max_posterior > 0.95 ~ "Very High",
    max_posterior > 0.80 ~ "High",
    max_posterior > 0.60 ~ "Moderate",
    TRUE                 ~ "Low"
  )
)

print(results)

write.csv(results, "new_specimen_classifications.csv", row.names = FALSE)
cat("\nResults saved to 'new_specimen_classifications.csv'\n")

# ==============================================================
# STEP 8: VISUALISE RESULTS
# ==============================================================
cat("\n=== STEP 8: Creating visualisation ===\n")

all_scores <- predict(lda_model, newdata = land_df_all)$x

plot_df <- data.frame(
  ID      = rownames(land_df_all),
  LD1     = all_scores[, 1],
  Type    = c(rep("Reference", n_reference), rep("New", n_new)),
  Species = c(as.character(species_ref), rep("Unknown", n_new))
)

p <- ggplot() +
  geom_histogram(
    data = subset(plot_df, Type == "Reference"),
    aes(x = LD1, fill = Species, y = after_stat(count)),
    binwidth = 0.2, alpha = 0.6, color = "black", position = "identity"
  ) +
  geom_point(
    data = subset(plot_df, Type == "New"),
    aes(x = LD1, y = -2),
    size = 4, shape = 8, color = "black", stroke = 1.2
  ) +
  geom_text_repel(
    data = subset(plot_df, Type == "New"),
    aes(x = LD1, y = -2, label = ID),     # label with the specimen ID, not a row number
    direction = "y", nudge_y = -1, angle = 0, size = 3.5,
    segment.color = "gray50", segment.alpha = 0.7,
    min.segment.length = 0.1, box.padding = 0.5, point.padding = 0.3
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  scale_fill_manual(
    values = c("G_elongatus" = "#440154", "G_ruber" = "#E67E22"),
    labels = c("G. elongatus", "G. ruber")
  ) +
  labs(
    title    = "LDA Classification of New Specimens",
    subtitle = "Reference specimens (histogram) and new specimens (stars)",
    x        = paste0("LD1 (", round(lda_var_explained[1] * 100, 1), "%)"),
    y        = "Count", fill = "Species",
    caption  = "* New specimens | labels = specimen IDs"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title    = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, face = "italic", size = 10),
    plot.margin   = margin(10, 10, 40, 10)
  ) +
  scale_y_continuous(expand = expansion(mult = c(0.2, 0.05)))

print(p)
ggsave("new_specimens_lda.png", p, width = 10, height = 8, dpi = 300)
cat("Plot saved to 'new_specimens_lda.png'\n")

# ==============================================================
# SUMMARY
# ==============================================================
cat("\n=== SUMMARY ===\n")
cat("Successfully classified", n_new, "new specimens\n")
cat("Classification confidence distribution:\n")
print(table(results$Classification_Confidence))
cat("\nDone! See 'new_specimen_classifications.csv' for detailed results\n")
