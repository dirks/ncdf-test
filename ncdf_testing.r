# testing ncdf with R
setwd("~/tmp/ncdf-test")
packages <- c("ncdf4", "dplyr", "ggplot2")
lapply(packages, library, character.only = TRUE)
sessionInfo()

# dap approach
dap_url <- "http://data.nodc.noaa.gov/thredds/dodsC/woa/WOA13/DATAv2/temperature/netcdf/decav/1.00/woa13_decav_t00_01v2.nc"
con <- nc_open(dap_url)
print(con)
summary(con)

t_an <- ncvar_get(con, "t_an")
summary(t_an)
lat <- ncvar_get(con, "lat")
lon <- ncvar_get(con, "lon")

depth <- ncvar_get(con, "depth")
dim(depth)

# plot distribution of temperature at several arbitrary depth
depth_meters <- c(0, 5, 10, 20, 50, 100)
depth_i <- which(depth %in% depth_meters)

pdf(file = "output/temperature.pdf", width = 7 * 1.6, height = 7)
for(i in depth_i) {
 title <- paste0("Annual Average Temperature at ", depth[i], " m")
 filled.contour(lon, lat, t_an[, , i], plot.title = title(title), 
  zlim = range(t_an, na.rm = TRUE), nlevels = 10, col = rev(brewer.pal(10, "RdBu")))
}
dev.off()

# size of objects in memory
sapply(ls(), function(x) format(object.size(get(x)), units = "auto"))
