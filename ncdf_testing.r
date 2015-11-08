# testing ncdf with R
setwd("~/tmp/ncdf-test")
packages <- c("ncdf4", "dplyr", "ggplot2", "reshape2", "RColorBrewer")
lapply(packages, library, character.only = TRUE)
sessionInfo()

# dap approach
dap_url <- "http://data.nodc.noaa.gov/thredds/dodsC/woa/WOA13/DATAv2/temperature/netcdf/decav/1.00/woa13_decav_t00_01v2.nc"
con <- nc_open(dap_url)
print(con)
summary(con)

lat <- ncvar_get(con, "lat")
lon <- ncvar_get(con, "lon")
depth <- ncvar_get(con, "depth")
dim(depth)

# get the whole temperature variable
t_an <- ncvar_get(con, "t_an")
summary(t_an)

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


# get slices of variable only
get_temp_in_depth_range <- function(con, shallow_depth = 0, deep_depth = 100) {
  # only works for slices, not multiple arbitrary depths
  # that would require a call to ncvar_get for each selected depth

  # get dimensions
  lat <- ncvar_get(con, "lat")
  lon <- ncvar_get(con, "lon")
  depth <- ncvar_get(con, "depth")
  depth_index <- which(depth >= shallow_depth & depth <= deep_depth)
  n_index <- length(depth_index)
  # get variable slice and name it
  tmp <- ncvar_get(con, "t_an",
    start = c(1, 1, depth_index[1], 1), count = c(-1, -1, n_index, -1))
  dimnames(tmp) <- list(lon, lat, depth[depth_index])
  tmp
  }

temp_depth_slice <- get_temp_in_depth_range(con, 0, 25)
df_temp_depth_slice <- melt(temp_depth_slice)
names(df_temp_depth_slice) <- c("lon", "lat", "depth", "t")
df_temp_depth_slice %>%
  ggplot(aes(x = lon, y = lat, color = t)) +
  geom_point() +
  facet_wrap(~depth)

