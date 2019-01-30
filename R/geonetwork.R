#' Create geographic networks
#'
#' Create an \code{igraph} object with geospatial attributes for the
#' nodes.
#'
#' The first two columns in \code{edges} must be character or factor,
#' and match the node names in the first column of the \code{nodes}
#' data.frame. The third column, if any, will be used as edge weights.
#' The remaining columns will be used as additional edge attributes.
#'
#' The first column in \code{nodes} must be character or factor and
#' provide node names or labels, not necessarily unique. Columns 2
#' and 3 must be numeric coordinates in the Coordinate Reference
#' System specified in \code{CRS}.
#'
#' @param edges data.frame. Edges list and attributes. See Details.
#' @param nodes data.frame. Nodes list and attributes. See Details.
#' @param directed logical. Default is to build a directed graph.
#' @param CRS CRS object. Coordinate Reference System, as built by
#'   function \code{\link[rgdal]{CRS}}.
#'
#' @return An object of class \code{geonetwork}, which also inherits
#' from \code{igraph}.
#' @export
#' @import igraph
#' @import sf
#' @importFrom sp CRS
#' @importFrom rgdal CRSargs
#' @examples
#'   e <- data.frame(from = c("A", "A"), to = c("B", "C"))
#'   n <- data.frame(id = LETTERS[1:3], x = c(0, 0, 1), y = c(0, 1, 0))
#'   geonetwork(e, n)
geonetwork <- function(edges, nodes, directed = TRUE, CRS = sp::CRS("+proj=longlat")) {

  stopifnot(
    ## numeric coordinates
    all(vapply(nodes[,2:3], is.numeric, TRUE))
  )

  nodes[, 1] <- as.character(nodes[, 1])
  edges[, 1] <- as.character(edges[, 1])
  edges[, 2] <- as.character(edges[, 2])

  ## Node geometries
  coords <- as.matrix(nodes[, 2:3])
  sfc <- st_cast(
    sf::st_sfc(
      sf::st_multipoint(coords, dim = "XY"),
      crs = rgdal::CRSargs(CRS)
    ),
    "POINT"
  )

  nodes_df <- nodes[, -(2:3), drop = FALSE]  # Node name and other attributes

  ## Standard igraph object
  ans <- igraph::graph_from_data_frame(edges, directed = directed, vertices = nodes_df)

  ## geospatial node attributes
  ## I can't store them in the graph's attributes since they are
  ## sent through C functions that loses their attributes.
  attr(ans, "geom_node") <- sfc

  class(ans) <- c("geonetwork", class(ans))
  return(ans)
}
