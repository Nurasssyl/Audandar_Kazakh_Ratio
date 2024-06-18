# Load necessary libraries
library(devtools)
library(geokz)
library(dplyr)
library(sf)
library(tmap)

devtools::install_github("arodionoff/geokz")

# Read the dataset
Population_Density_df <- read.csv('C:/Users/User/Desktop/R/Audandar-kazakhs.csv', sep = ";", fileEncoding = "ISO-8859-1")

# Rename the problematic column
colnames(Population_Density_df)[colnames(Population_Density_df) == "percentage of Kazakhs"] <- "Percentage_of_Kazakhs"

Population_Density_df <- Population_Density_df %>%
  dplyr::select(ADM2_PCODE, ADM2_EN, Area, Population, Percentage_of_Kazakhs) %>%
  dplyr::rename(ISO_3166_2 = ADM2_PCODE, Region = ADM2_EN) %>%
  dplyr::mutate(
    Percentage_of_Kazakhs = as.numeric(gsub("%", "", Percentage_of_Kazakhs)),
    Kazakh_Category = cut(Percentage_of_Kazakhs,
                          breaks = c(-Inf, 40, 60, 80, 100),
                          labels = c("Below 40%", "40-60%", "60-80%", "80-100%"))
  )

Population_Density_df$ISO_3166_2 <- trimws(Population_Density_df$ISO_3166_2)
rayons_map <- get_kaz_rayons_map(Year = 2024)
rayons_map$ADM2_PCODE <- trimws(rayons_map$ADM2_PCODE)

Population_Density_df$ISO_3166_2 <- as.character(Population_Density_df$ISO_3166_2)
rayons_map$ADM2_PCODE <- as.character(rayons_map$ADM2_PCODE)

print(unique(Population_Density_df$ISO_3166_2))
print(unique(rayons_map$ADM2_PCODE))

map_data <- dplyr::inner_join(
  x = rayons_map,
  y = Population_Density_df[, c("ISO_3166_2", "Kazakh_Category")],
  by = c("ADM2_PCODE" = "ISO_3166_2")
)

print(map_data)

map_plot <- tmap::tm_shape(map_data) +
  tmap::tm_fill("Kazakh_Category", palette = "Blues", title = "Percentage of Kazakhs") +
  tmap::tm_borders()

# Save the map
tmap::tmap_save(map_plot, "C:/Users/User/Desktop/Audandar_Kazakh_Ratio.jpeg")

# Show the map on the screen
tmap::tmap_mode("view")
map_plot
