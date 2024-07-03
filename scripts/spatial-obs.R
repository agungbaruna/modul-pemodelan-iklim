library(gstat)
library(readxl)
library(raster)
library(dplyr)
library(sf)
library(purrr)
library(lubridate)

# Load observation data
data_path <- "../BMKG-Jawa.xlsx"
sheets <- excel_sheets(data_path)
sheets <- sheets[2:length(sheets)] # sheet 1 is metadata
dats <- map_dfr(sheets, ~{
  sheet_name <- .x
  sheet_data <- read_excel(data_path, sheet = .x) %>%
    # Pilih hanya kolom Tanggal, Tavg, dan RR
    select(Tanggal, lon, lat, Tavg, RR) %>%
    # Menambahkan nama stasiun
    mutate(Lokasi = sheet_name) %>%
    # Mengubah kolom Tanggal dari tipe chr menjadi date
    mutate(Tanggal = as.Date(Tanggal, format = '%d-%m-%Y')) %>%
    # Mengubah nilai 8888 dan 9999 menjadi NA
    mutate(across(1:ncol(.), function(x) if_else(x == 8888 | x == 9999, NA, x)))
  
  return(sheet_data)
})

# Import administration boundary
jawa <- st_read('../jawa.geojson')

# Filter year >= 2000
dats_select <- dats %>% filter(year(Tanggal) >= 2000)

# Aggregate monthly
rr_monthly <- dats_select %>%
  group_by(Lokasi, lon, lat, YEAR = year(Tanggal), MON = month(Tanggal)) %>%
  summarise(RR = sum(RR, na.rm = T)) %>%
  mutate(MON = make_date(YEAR, MON)) %>%
  as_tibble() %>% # change to tbl_df class
  arrange(MON) # sort by Month

# Loop for each months. This step is the process to make 
# grid of rainfall with interpolation method (IDW).

# Make an empty grid with the same extent as the data and resolution set to 0.05
res <- 0.02
empty_grd <- sf::st_make_grid(jawa, what = 'centers', cellsize = res)

# Set the parameter of IDW -> use power = 1
power <- 2

# list of months
month_list <- unique(rr_monthly$MON)

# Looping step
for (mon in seq_along(month_list)) {
  # Filter the data frame by month
  rr_select <- rr_monthly %>% filter(MON == month_list[mon])
  
  # Convert dataframe to sf
  rr_select <- st_as_sf(rr_select, coords = c('lon', 'lat'), crs = st_crs(jawa))

  # Do the IDW calculation
  rr_idw <- idw(RR ~ 1, locations = rr_select, newdata = empty_grd, idp = power)
  
  # Assign coordinates to the IDW result
  rr_idw <- rr_idw %>%
    mutate(lon = st_coordinates(rr_idw)[, 1], 
           lat = st_coordinates(rr_idw)[, 2])
  
  # Sort lat descending and lon ascending
  # This because of raster package requires the data to be sorted in this way
  # From the up left corner to the bottom right corner
  rr_idw <- rr_idw %>%
    arrange(desc(lat)) %>%
    arrange(lon)
  
  # convert to matrix which has ncell = lon * lat
  lon <- unique(rr_idw$lon); nlon <- length(lon)
  lat <- unique(rr_idw$lat); nlat <- length(lat)
  rr_idw_mat <- matrix(rr_idw$var1.pred, nrow = nlat, ncol = nlon)
  
  # Convert to raster
  rr_idw_rast <- raster(rr_idw_mat, xmn = min(lon), xmx = max(lon), 
                               ymn = min(lat), ymx = max(lat))
  
  # Save to file
  writeRaster(rr_idw_rast, paste0('../JAWA/IDW_', as.character(month_list[mon]), '.tif'))
}