# Installer les packages nécessaires si pas déjà fait
install.packages(c("tmap", "tmaptools", "sf"))

library(tmap)
library(tmaptools)  # Pour la géocodification
library(sf)

# 1. Liste des adresses
adresses <- c(
  "2 ter Rue des Carmes, La Rochelle",
  "9 bis Rue des trois Fuseaux, La Rochelle",
  "8 Rue Pas du Minage, La Rochelle"
)

lieux <- c("La chambre bleue", 
           "Les rebelles ordinaires",
           "The curious bar")

# Géocoder chaque adresse avec lapply
coords_list <- lapply(adresses, function(adresse) {
  result <- geocode_OSM(adresse)
  if (is.null(result)) {
    return(data.frame(lon = NA, lat = NA))
  } else {
    return(data.frame(lon = result$coords[1], lat = result$coords[2]))
  }
})

# Convertir la liste en data.frame
coords_df <- do.call(rbind, coords_list)

# Ajouter les adresses au dataframe des coordonnées
df <- data.frame(lieu = lieux, adresse = adresses, lon = coords_df$lon, lat = coords_df$lat)

print(df)

# 4. Transformer en objet spatial sf
points_sf <- st_as_sf(df, coords = c("lon", "lat"), crs = 4326)

# 5. Créer la carte interactive avec tmap
tmap_mode("view")
carte <- tm_scalebar() +
  tm_basemap(c("CartoDB.Positron")) +
  tm_shape(points_sf) +
  tm_dots(size = 1, col = "black", shape = 21, fill = "purple") +
  tm_text("lieu", just = "left", xmod = 0.5, size = 2, col = "purple") ; carte

tmap_save(carte, filename = "carte_expo.html", selfcontained = TRUE)


