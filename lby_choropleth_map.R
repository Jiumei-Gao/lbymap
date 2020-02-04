install.packages("googlesheets")
install.packages("tigris")
install.packages("usethis")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(tmap)
library(tigris)
library(usethis)

install.packages("leaflet")
library(leaflet)
library(rgdal)
library(sf)


leaflet(options = leafletOptions(minZoom = 0, maxZoom = 18))

#add tiles.
m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addTiles()


#read admin boundary shapefile
lby_adm2 <- st_read("c:/Users/JiumeiGao/British Red Cross Society/Maps Team - Documents/2020/02_International_BRC/01_January/Alex Pendry - Libya Protection Assessment Analysis/QGIS/Admin Boundary/lby_adm_unosat_lbsc_20180507_SHP/lby_admbnda_adm2_unosat_lbsc_20180507.shp")

# information about the shapefile
st_geometry_type(lby_adm2) #polygon
st_crs(lby_adm2) #projection
lby_adm2 #information

# plot the shapefile
ggplot() +
  geom_sf(data = lby_adm2, size = 1, color = "black")

# plot the shapefile with basemap in leaflet
lby_adm2 %>% leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~ADM2_EN)

# load admin2 data
lby_disp_data <- read.csv("c:/Users/JiumeiGao/British Red Cross Society/Maps Team - Documents/2020/02_International_BRC/01_January/Alex Pendry - Libya Protection Assessment Analysis/R/adm2_displacement.csv")

# check the data
lby_disp_data

# join the data with the shapefile
lby_adm2_disp_joined <- geo_join(lby_adm2, lby_disp_data, "ADM2_PCODE", "adm2_pcode")

# define color palette
pal <- colorNumeric("Reds", domain=lby_adm2_disp_joined$not_same_location_prior_2012)

# define popup on the leaflet map
popup_sb <- paste0("<strong>", lby_adm2_disp_joined$ADM2_EN,
                   "</strong><br />Percentage: ", as.character(lby_adm2_disp_joined$not_same_location_prior_2012))

# map
lby_disp_map <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% # choose style of basemap
  setView(20.040343, 25.501866, zoom =5.2) %>%  # set the centre of the map
  addPolygons(data = lby_adm2_disp_joined,
              fillColor = ~pal(lby_adm2_disp_joined$not_same_location_prior_2012),
              fillOpacity = 0.7,
              weight = 0.2,
              smoothFactor = 0.2,
              popup = ~popup_sb) %>% 
  addLegend(pal = pal,
            values = lby_adm2_disp_joined$not_same_location_prior_2012,
            position = "bottomright",
            title = "Percentage of respondents<br />living in a different baladiya<br/ >prior to 2011")

lby_disp_map



