
library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)

## View raster file attributes

HARV_dsmCrop_info <- capture.output(
  GDALinfo('~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif')
)

## Open a raster in R

dsm_harv <- raster('~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif')

dsm_harv_df <- as.data.frame(dsm_harv, xy = TRUE)

ggplot() +
  geom_raster(data = dsm_harv_df, aes(x = x, y = y, fill = HARV_dsmCrop)) +
  scale_fill_viridis_c() +
  coord_quickmap()

### View raster coordinate reference system in R

crs(dsm_harv)


## Understanding CRS in Proj4 format

## Calculate Raster Min and Max Values

minValue(dsm_harv)
maxValue(dsm_harv)
dsm_harv <- setMinMax(dsm_harv)

## Dealing with missing data

#############################
### plot raster data in R ###
#############################

### plotting data using breaks

dsm_harv_df <- dsm_harv_df %>%
  mutate(fct_elevation = cut(HARV_dsmCrop, breaks = 3))

ggplot() +
  geom_bar(data = dsm_harv_df, aes(x = fct_elevation))

unique(dsm_harv_df$fct_elevation)

dsm_harv_df %>%
  count(fct_elevation)

custom_bins <- c(300, 350, 400, 450)
dsm_harv_df <- dsm_harv_df %>%
  mutate(fct_elevation2 = cut(HARV_dsmCrop, breaks = custom_bins))
unique(dsm_harv_df$fct_elevation2)
ggplot() +
  geom_bar(data = dsm_harv_df, aes(x = fct_elevation2))


### Plot the map using these breaks

my_col <- terrain.colors(3)
ggplot() +
  geom_raster(data = dsm_harv_df, aes(x = x, y = y, fill = fct_elevation2)) +
  coord_quickmap() +
  scale_fill_manual(values = my_col, name = 'Elevation') +
  theme_void()

### add hillshade effect

dsm_hill_harv <- raster('~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif')

dsm_hill_harv_df <- as.data.frame(dsm_hill_harv, xy = TRUE)

ggplot() +
  geom_raster(data = dsm_hill_harv_df, aes(x = x, y = y, alpha = HARV_DSMhill), 
              fill = 'black') +
  scale_alpha(range = c(0.15, 0.65), guide = 'none') +
  coord_quickmap()

ggplot() +
  geom_raster(data = dsm_harv_df, aes(x = x, y = y, fill = fct_elevation2)) +
  geom_raster(data = dsm_hill_harv_df, aes(x = x, y = y, alpha = HARV_DSMhill), 
              fill = 'black') +
  scale_alpha(range = c(0.15, 0.65), guide = 'none') +
  scale_fill_manual(values = my_col, name = 'Elevation') +
  coord_quickmap() +
  theme_void()
