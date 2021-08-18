### Set up packages and data from earlier episodes:
library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)

DSM_HARV <- raster("neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
DSM_HARV_df <- as.data.frame(DSM_HARV, xy = TRUE)

# DTM data for Harvard Forest
DTM_HARV <- raster("neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")
DTM_HARV_df <- as.data.frame(DTM_HARV, xy = TRUE)

# DSM data for SJER
DSM_SJER <- raster("neon_data/NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmCrop.tif")
DSM_SJER_df <- as.data.frame(DSM_SJER, xy = TRUE)

# DTM data for SJER
DTM_SJER <- raster("neon_data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif")
DTM_SJER_df <- as.data.frame(DTM_SJER, xy = TRUE)

### Check the spatial attributes:
GDALinfo("neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
GDALinfo("neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")

DSM_HARV
DTM_HARV

?compareRaster
compareRaster(DSM_HARV, DTM_HARV)
compareRaster(DSM_HARV, DTM_HARV, values = TRUE)

### plot the rasters
ggplot() +
  geom_raster(data = DTM_HARV_df, aes(x = x, y = y, fill = HARV_dtmCrop)) +
  scale_fill_gradientn(name = 'Elevation', colors = terrain.colors(10)) +
  coord_quickmap() +
  theme(axis.title = element_blank(),
        axis.text  = element_blank(),
        axis.ticks = element_blank())

ggplot() +
  geom_raster(data = DSM_HARV_df, aes(x = x, y = y, fill = HARV_dsmCrop)) +
  scale_fill_gradientn(name = 'Elevation', colors = terrain.colors(10)) +
  coord_quickmap() +
  theme_void()

### We will use two ways to calculate the CHM model: "raster math" and 
### the overlay() function.

### Raster math is like vector math:
x <- values(DSM_HARV)
head(x)

y <- x[1:20]
y
y * 2
y^2
log(y)

DSM_HARV
DSM_HARV * 2

z <- rnorm(n = 20)
z
y * z

### let's calculate CHM using raster math:
CHM_HARV1 <- DSM_HARV - DTM_HARV
CHM_HARV1_df <- as.data.frame(CHM_HARV1, xy = TRUE)

plot(CHM_HARV1)
ggplot() +
  geom_raster(data = CHM_HARV1_df, aes(x = x, y = y, fill = layer)) +
  scale_fill_gradientn(name = 'Canopy height, m', 
                       colors = c('grey60', 'lightgreen', 'darkgreen')) +
  coord_quickmap() +
  theme_void()

ggplot() +
  geom_histogram(data = CHM_HARV1_df, aes(layer))

### Challenge: 
### It’s often a good idea to explore the range of values in a raster dataset 
### just like we might explore a dataset that we collected in the field.

### * What is the min and maximum value for the Harvard Forest Canopy Height 
###   Model (CHM_HARV) that we just created?
### * What are two ways you can check this range of data for CHM_HARV?
### * What is the distribution of all the pixel values in the CHM?
### * Plot a histogram with 6 bins instead of the default and change the color 
###   of the histogram.
### * Plot the CHM_HARV raster using breaks that make sense for the data. 
###   Include an appropriate color palette for the data, plot title and no axes 
###   ticks / labels.


### Now let's perform the same calculation using the overlay() function.
?overlay
CHM_HARV2 <- overlay(DSM_HARV,
                     DTM_HARV,
                     fun = function(r1, r2) {
                       diff <- r1 - r2
                       return(diff)
                     })

CHM_HARV2
CHM_HARV2_df <- as.data.frame(CHM_HARV2, xy = TRUE)

ggplot() +
  geom_raster(data = CHM_HARV2_df, aes(x = x, y = y, fill = layer)) +
  scale_fill_gradientn(name = 'Canopy height, m', 
                       colors = c('grey60', 'lightgreen', 'darkgreen')) +
  coord_quickmap() +
  theme_void()

### use compareRaster with values = TRUE to check that the spatial 
### attributes AND the raster values all match up
compareRaster(CHM_HARV1, CHM_HARV2, values = TRUE)

### Let's use writeRaster to write our results to a file
?writeRaster
writeRaster(CHM_HARV1, filename = 'CHM_HARV.tif',
            format = 'GTiff',
            overwrite = TRUE,
            NAflag = -9999)

### Challenge:
### Data are often more interesting and powerful when we compare them across 
### various locations. Let’s compare some data collected over Harvard Forest 
### to data collected in Southern California. The NEON San Joaquin Experimental
### Range (SJER) field site located in Southern California has a very different
### ecosystem and climate than the NEON Harvard Forest Field Site in 
### Massachusetts.

### Import the SJER DSM and DTM raster files and create a Canopy Height Model. 
### Then compare the two sites. Be sure to name your R objects and outputs
### carefully, as follows: objectType_SJER (e.g. DSM_SJER). This will help you 
### keep track of data from different sites!
  
### You should have the DSM and DTM data for the SJER site already loaded 
### from the Plot Raster Data in R episode.) Don’t forget to check the CRSs 
### and units of the data.
### * Create a CHM from the two raster layers and check to make sure the data 
###   are what you expect.
### * Plot the CHM from SJER.
### * Export the SJER CHM as a GeoTIFF.
### * Compare the vegetation structure of the Harvard Forest and San Joaquin 
###   Experimental Range.
