
<!-- README.md is generated from README.Rmd. Please edit that file -->
geonetwork
==========

Classes and methods for handling networks or graphs whose nodes are geographical (i.e. locations in the globe). Create, transform, plot.

Installation
------------

<!-- You can install the released version of geonetwork from [CRAN](https://CRAN.R-project.org) with: -->
<!-- ``` r -->
<!-- install.packages("geonetwork") -->
<!-- ``` -->
`geonetwork` is in development. You can install the current version from GitLab with:

``` r
remotes::install_gitlab("famuvie/geonetwork")
```

Example
-------

### Creation

A `geonetwork` is an object of class `igraph` whose nodes have *geospatial* attributes (i.e. coordinates and CRS).

Consider the distances (in km) between 21 cities in Europe from the `datasets` package. A simple way of constructing a `geonetwork` is by combining a data.frame of `nodes` with one of `edges`:

``` r
cities <- cbind(
  city = labels(datasets::eurodist),
  ggmap::geocode(labels(datasets::eurodist), source = "dsk")
)
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Athens&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Barcelona&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Brussels&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Calais&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Cherbourg&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Cologne&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Copenhagen&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Geneva&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Gibraltar&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Hamburg&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Hook%20of%20Holland&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Lisbon&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Lyons&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Madrid&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Marseilles&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Milan&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Munich&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Paris&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Rome&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Stockholm&sensor=false
#> Information from URL : http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Vienna&sensor=false

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
#> 'data.frame':    21 obs. of  3 variables:
#>  $ city: Factor w/ 21 levels "Athens","Barcelona",..: 1 2 3 4 5 6 7 8 9 10 ...
#>  $ lon : num  23.72 2.16 4.35 1.85 -1.62 ...
#>  $ lat : num  38 41.4 50.9 51 49.6 ...
str(distances)
#> 'data.frame':    210 obs. of  3 variables:
#>  $ origin  : chr  "Barcelona" "Brussels" "Calais" "Cherbourg" ...
#>  $ destin  : chr  "Athens" "Athens" "Athens" "Athens" ...
#>  $ distance: num  3313 2963 3175 3339 2762 ...

eurod_net <- geonetwork(distances, nodes = cities, directed = FALSE)
```

Several assumptions were made here unless otherwise specified:

-   The first column in `cities` was matched with the first two columns in `distances`.

-   The second and third columns in `cities` were assumed to be longitude and latitude in decimal degrees in a WGS84 CRS.

-   The remaining column in `distances` was treated as an edge *weight*.

Now we can readily plot the network, optionally with some additional geographical layer for context:

``` r
library(sp)
plot(as(eurod_net, "Spatial"))  # sp
maps::map(add = TRUE, fill = TRUE, col = "lightgray")
points(as(eurod_net, "Spatial"))  # sp
```

<img src="man/figures/README-plotting-1.png" width="100%" />

``` r


# library(ggplot2)
# ggplot() +
#   geom_sf(eurod_net_dummy) +
#   geom_sf(spData::world)
```
