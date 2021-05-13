library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)

GDALinfo('~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif')

DSM_HARV <- raster('neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif')
DTM_HARV <- raster('neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif')

summary(DSM_HARV)
summary(DSM_HARV, maxsamp = ncell(DSM_HARV))

DSM_HARV_df <- as.data.frame(DSM_HARV, xy = TRUE)
DTM_HARV_df <- as.data.frame(DTM_HARV, xy = TRUE)

ggplot() +
  geom_raster(data = DSM_HARV_df, aes(x = x, y = y, fill = HARV_dsmCrop)) +
  scale_fill_viridis_c() +
  coord_quickmap()


DSM_HARV <- setMinMax(DSM_HARV)

DSM_HARV_df <- DSM_HARV_df %>%
  mutate(fct_elevation = cut(HARV_dsmCrop, breaks = 3))

ggplot() +
  geom_bar(data = DSM_HARV_df, aes(fct_elevation))

### create custom bins
custom_bins <- c(300, 350, 400, 450)
DSM_HARV_df <- DSM_HARV_df %>%
  mutate(fct_elevation2 = cut(HARV_dsmCrop, breaks = custom_bins))
ggplot() +
  geom_bar(data = DSM_HARV_df, aes(fct_elevation2))


ggplot() + 
  geom_raster(data = DSM_HARV_df, aes(x = x, y = y, fill = fct_elevation2)) +
  scale_fill_manual(values = terrain.colors(3), name = 'Elevation') +
  coord_quickmap() +
  theme(axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text  = element_blank())

DSM_hill_HARV <- raster('neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif')
DSM_hill_HARV_df <- as.data.frame(DSM_hill_HARV, xy = TRUE)

ggplot() + 
  geom_raster(data = DSM_HARV_df, aes(x = x, y = y, fill = HARV_dsmCrop)) +
  geom_raster(data = DSM_hill_HARV_df, 
              aes(x = x, y = y, alpha = HARV_DSMhill), 
              fill = 'black') +
  scale_alpha(range = c(0.15, 0.65), guide = 'none') +
  scale_fill_gradientn(colors = terrain.colors(10), name = 'Elevation') +
  coord_quickmap() +
  theme_void()



