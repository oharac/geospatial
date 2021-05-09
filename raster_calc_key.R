
### Attach packages
### NOTE: attach raster before dplyr due to `select()` conflict
library(raster)
library(rgdal)
library(dplyr)
library(ggplot2)

### read in data
dsm_harv_file <- '~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif'
dtm_harv_file <- '~/neon_data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif'
dsm_harv <- raster(dsm_harv_file)
dtm_harv <- raster(dtm_harv_file)

### raster math

### raster as a vector in disguise
x <- values(dsm_harv)

### try out some random math operations on vectors:
y <- x[1:20]
y
y*2
y^2
log(y)
z <- rnorm(n = 20)
y * z
### Remember that NA values can poison a calculation; this is true of
### raster math as well...
y[3] <- NA
y * z

### math operations on a single raster
### note: use base plot, rather than ggplot, for quick peeks
plot(dsm_harv)
plot(dsm_harv - 300)
plot(log(dsm_harv-300))

### to do math across multiple rasters, we need to make sure the spatial
### parameters are the same - CRS, projection, extent, etc.

### EXERCISE: Pause and let them use GDALinfo() to compare CRS, resolution, and origin

GDALinfo(dsm_harv_file) ### works on the file, not the raster
GDALinfo(dtm_harv_file)

### AFTER EXERCISE:
### you can also look at the raster 
dsm_harv
dtm_harv

### or you can use compareRaster()
?compareRaster
### note res=FALSE and orig=FALSE are redundant if extent=TRUE and rowcol=TRUE
compareRaster(dsm_harv, dtm_harv)

### put our rasters in dataframes to plot again
dsm_harv_df <- as.data.frame(dsm_harv, xy = TRUE)
dtm_harv_df <- as.data.frame(dtm_harv, xy = TRUE)

mycols <- terrain.colors(10)
ggplot() +
  geom_raster(data = dtm_harv_df, 
              aes(x = x, y = y, fill = HARV_dtmCrop)) +
  scale_fill_gradientn(name = 'Elevation', colors = mycols) +
  coord_quickmap() # +
  # theme(axis.title = element_blank(),
  #       axis.text = element_blank(),
  #       axis.ticks = element_blank())

ggplot() +
  geom_raster(data = dsm_harv_df, 
              aes(x = x, y = y, fill = HARV_dsmCrop)) +
  scale_fill_gradientn(name = 'Elevation', colors = mycols) +
  coord_quickmap() +
  theme_void() ### quickly drops all axis text, background, grid, etc

### Now for the raster math!  Two ways: raster math, overlay

### 1: just use regular math operators directly on the rasters, just like we did earlier.
chm_harv1 <- dsm_harv - dtm_harv
### (note could have multiplied, divided, etc)

chm_harv1_df <- as.data.frame(chm_harv1, xy = TRUE)
### look at it; note third column is generic "layer"
### check dtm_harv object, note "names" field; that's where 
### as.data.frame() gets the column name.
### with chm_harv1 object, names is just "layer"

### plot the map
ggplot(chm_harv1_df) +
  geom_raster(aes(x = x, y = y, fill = layer)) +
  scale_fill_gradientn(name = 'canopy height', colors = mycols) +
  coord_quickmap() +
  theme_void()

### plot the histogram to check the distribution of canopy heights
ggplot(chm_harv1_df) +
  geom_histogram(aes(x = layer))
### recall that each cell is a 1x1 meter square, so there are 150,000 square meters of canopy-less area, about 15 hectares

### CHALLENGE EXERCISE?
### * what is the min and max value?
### * what are two ways to check the range?
### * re-plot the distribution with only 6 bins, and change color
### * plot the chm_harv raster using breaks that make sense for the data,
###   with an appropriate color palette for the data, a title, and no axis ticks/labels

### use the overlay() function - efficient for large rasters or more complex calcs
?overlay
chm_harv2 <- overlay(dsm_harv, dtm_harv, 
                     fun = function(r1, r2) {
                       diff <- r1 - r2
                       return(diff)
                     })
chm_harv2_df <- as.data.frame(chm_harv2, xy = TRUE)

### plot the map
ggplot(chm_harv2_df) +
  geom_raster(aes(x = x, y = y, fill = layer)) +
  scale_fill_gradientn(name = 'canopy height', colors = mycols) +
  coord_quickmap() +
  theme_void()

### plot the histogram to check the distribution of canopy heights
ggplot(chm_harv2_df) +
  geom_histogram(aes(x = layer))

### How do the plots compare?  How do the actual rasters compare?
compareRaster(chm_harv1, chm_harv2, values = TRUE)


### Writing out a raster
?writeRaster
writeRaster(chm_harv1, filename = 'chm_harv.tif',
            format = 'GTiff',
            overwrite = TRUE,
            NAflag = -9999)
### note, writeRaster guesses the format from the file extension, so
### format = 'GTiff' is redundant in this case.  

##################
### KEY POINTS ###
##################
### * Mathematical functions can be used to operate on and make calculations
###   with rasters.
### * the overlay() function provides an efficient way to do raster math.
### * the compareRaster() function provides a quick way to compare two or more 
###   rasters.
### * the writeRaster() function can be used to write raster data to a file.
