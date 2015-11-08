# testing ncdf with R
setwd("~/tmp/ncdf-test")
packages <- c("ncdf4", "dplyr", "ggplot2")
lapply(packages, library, character.only = TRUE)
sessionInfo()

# dap approach
dap_url <- "http://data.nodc.noaa.gov/thredds/dodsC/woa/WOA13/DATAv2/temperature/netcdf/decav/1.00/woa13_decav_t00_01v2.nc"
con <- nc_open(dap_url)
print(con)

t_an <- ncvar_get(con, "t_an")
summary(t_an)
lat <- ncvar_get(con, "lat")
lon <- ncvar_get(con, "lon")

depth <- ncvar_get(con, "depth")
dim(depth)

depth_i <- c(1, 2, 5, 10, 20, 50, 100)
pdf(file = "output/temperature.pdf")
for(i in depth_i) {
 title <- paste0("Temperature at ", i)
 filled.contour(lon, lat, t_an[, , i], plot.title = title(title), 
  zlim = range(t_an, na.rm = TRUE), color.palette = heat.colors)
}
dev.off()

