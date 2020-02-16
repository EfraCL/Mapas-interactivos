library(rgdal)
library(leaflet)
library(htmlwidgets)

locations<-readOGR(dsn="Localizaciones.shp",
                   layer="Localizaciones",
                   encoding="ESRI Shapefile")

locations<-spTransform(locations,CRS("+init=epsg:4326"))

treatments<-readOGR(dsn="Tratamientos.shp",
                   layer="Tratamientos",
                   encoding="ESRI Shapefile")

treatments<-spTransform(treatments,CRS("+init=epsg:4326"))

estacion_meteo<-readOGR(dsn="Estacion_meteo.shp",
                        layer="Estacion_meteo",
                        encoding="ESRI Shapefile")

estacion_meteo<-spTransform(estacion_meteo,CRS("+init=epsg:4326"))

pueblos<-readOGR(dsn="pueblo.shp",
                 layer="pueblo",
                 encoding="ESRI Shapefile")

pueblos<-spTransform(pueblos,CRS("+init=epsg:4326"))

trampas<-readOGR(dsn="tramp_sed.shp",
                 layer="tramp_sed",
                 encoding="ESRI Shapefile")

trampas<-spTransform(trampas,CRS("+init=epsg:4326"))

locations.popup<-paste("<b>Datos</b>","<br/>",
                       "<b>Zona:</b>",locations@data$nombre,"<br/>",
                       "<b>Régimen de cultivo:</b>","Secano","<br/>",
                       "<b> Suelo (WRB, 2015):</b>",locations@data$WRB,"<br/>",
                       "<b> Suelo (SSS, 2014):</b>",locations@data$SST,"<br/>")

treatments.popup<-paste("<b>Datos</b>","<br/>",
                        "<b>Tratamiento:</b>",treatments@data$Descripcio,"<br/>")

color.location<-c("green","yellow")
paleta.location<-colorFactor(color.location,locations@data$nombre)

color.treatments<-c("yellow","blue","green")
paleta.treatments<-colorFactor(color.treatments,treatments@data$Tratamient)

color.pueblos<-c("darkblue","pink")
paleta.pueblos<-colorFactor(color.pueblos,pueblos@data$Nombre)

rain_icon<-awesomeIconList(
  id = makeAwesomeIcon(icon = "fas fa-cloud-rain",
                         iconColor = "black", markerColor = "black",
                         library = "fa"))


leaflet()%>%
  addPolygons(data=locations, popup = locations.popup,stroke=T,
              fillColor = paleta.location(locations@data$nombre),
              color = "green",opacity = 0.5,, group="Zonas de cultivo")%>%
  addPolygons(data=treatments, popup=treatments.popup,stroke=T,
              fillColor=paleta.treatments(treatments@data$Tratamient),
              color="black",group="Tratamientos")%>%
  addPolygons(data=pueblos,label=pueblos@data$Nombre,stroke=T,color="black",
              fillColor=paleta.pueblos(pueblos@data$Nombre), group="Núcleos urbanos")%>%
  addCircleMarkers(lng=trampas@coords[,1], lat=trampas@coords[,2],label=trampas@data$nombre,
                   radius=2, opacity = 1, fillOpacity = 1,
                   color ="blue", group="Trampas de sedimentos")%>%
  addAwesomeMarkers(lng=estacion_meteo@coords[,1], lat=estacion_meteo@coords[,2],
                   label=estacion_meteo@data$nombre,
                   icon=makeAwesomeIcon(icon = "fas fa-tint",
                                        iconColor = "white", markerColor = "blue",
                                        library = "fa"),group="Estación meteorológica")%>%
  addTiles(group="Open Street Map")%>%
  addWMSTiles("https://ortofotos-gis.carm.es/geoserver/ORTOFOTOS/wms?",
              layers = "2019_PNOA",
              attribution = "Plan Nacional de Ortofotografía Aérea 2019",,group="PNOA")%>%
  addLayersControl(overlayGroups = c("Zonas de cultivo","Tratamientos","Núcleos urbanos",
                                     "Trampas de sedimentos","Estación meteorológica",
                                     "Open Street Map","PNOA"),
                   options = layersControlOptions(collapsed = TRUE))->mapa


saveWidget( mapa, file= "MAPA_ANILLOS.html")
