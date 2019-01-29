cities <- cbind(
  city = labels(datasets::eurodist),
  ggmap::geocode(labels(datasets::eurodist), source = "dsk")
)

distances <-
  expand.grid(
    origin = labels(datasets::eurodist),
    destin = labels(datasets::eurodist),
    stringsAsFactors = FALSE,
    KEEP.OUT.ATTRS = FALSE
  )
distances <-
  cbind(
    distances[distances$destin < distances$origin,],
    distance = as.numeric(datasets::eurodist)
  )

str(cities)
str(distances)

eurodist <- geonetwork(distances, nodes = cities, directed = FALSE)

write_csv(eurodist, "data-raw/eurodist.csv")
save(eurodist, file = "data/eurodist.rda", compress = "bzip2")
