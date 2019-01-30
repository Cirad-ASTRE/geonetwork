#' Plot a geonetwork
#'
#' Plot one or more attributes of a geonetwork on a map
#'
#'
#' @param x Object of class \code{geonetwork}.
#' @param y Ignored.
#' @param ... Further specifications passed to \link{plot_sf}.
#'
#' @export
#' @importFrom graphics plot
#'
#' @examples
#' plot(eurodist, axes = TRUE, type = "n")
#' plot(sf::st_geometry(spData::world), col = "lightgray", add = TRUE)
#' plot(eurodist, axes = TRUE, add = TRUE)
plot.geonetwork <- function(x, y, ...) {

  stopifnot(missing(y))

  dots = list(...)

  sfc_nodes <- attr(x, "geom_node")

  nodes_sf <-
    sf::st_sf(
      vertex_attr(x),
      geom = sfc_nodes,
      stringsAsFactors = FALSE
    )

  if (is.null(sfc_edges <- attr(x, "geom_edge"))) {
    ## Build default "connections" between nodes

    edge_extremes_ids <- matrix(match(as_edgelist(x), igraph::as_ids(V(x))), ncol = 2)
    coords <- st_coordinates(sfc_nodes)

    if (sf::st_is_longlat(sfc_nodes)) {
      ## Great circle lines
      line_coords <-
        geosphere::gcIntermediate(
          coords[edge_extremes_ids[,1], ],
          coords[edge_extremes_ids[,2], ],
          n = 99,
          addStartEnd = TRUE
        )
    } else {
      ## Straight lines
      n_lines <- nrow(edge_extremes_ids)
      line_coords <-
        lapply(
          seq.int(n_lines),
          function(x)
            array(
              coords[edge_extremes_ids, ],
              dim = c(n_lines, 2, 2)
            )[x,,]
        )
    }

    sfc_edges <-
      sf::st_sfc(
        lapply(line_coords, st_linestring, dim = "XY"),
        crs = st_crs(sfc_nodes)
      )
  }

  if (length(edge_attr(x)) > 0) {
    edges_sf <-
      sf::st_sf(
        edge_attr(x),
        geom = sfc_edges,
        stringsAsFactors = FALSE
      )
  } else {
    edges_sf <-
      sf::st_sf(
        geom = sfc_edges,
        stringsAsFactors = FALSE
      )
  }


  plot(st_geometry(edges_sf), ...)

  if (isTRUE(dots$add)) {
    plot(st_geometry(nodes_sf), ...)
  } else{
    plot(st_geometry(nodes_sf), add = TRUE, ...)
  }

}
