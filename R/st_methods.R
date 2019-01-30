#' @export
#' @import sf
st_bbox.geonetwork <- function(obj, ...) {
  geom_nodes <- attr(obj, "geom_node")
  sf::st_bbox(geom_nodes)
}

#' @export
#' @import sf
st_crs.geonetwork <- function(x, ...) {
  geom_nodes <- attr(x, "geom_node")
  sf::st_crs(geom_nodes)
}

#' @export
#' @import sf
st_transform.geonetwork <- function(x, crs, ...) {
  geom_nodes <- attr(x, "geom_node")
  attr(x, "geom_node") <- sf::st_transform(geom_nodes, crs)
  return(x)
}
