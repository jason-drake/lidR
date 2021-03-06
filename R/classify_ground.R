# ===============================================================================
#
# PROGRAMMERS:
#
# jean-romain.roussel.1@ulaval.ca  -  https:#github.com/Jean-Romain/lidR
#
# COPYRIGHT:
#
# Copyright 2016-2018 Jean-Romain Roussel
#
# This file is part of lidR R package.
#
# lidR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>
#
# ===============================================================================


#' Classify points as 'ground' or 'not ground'
#'
#' Classify points as 'ground' or 'not ground' with several possible algorithms. The function updates the
#' attribute \code{Classification} of the LAS object. The points classified as 'ground' are assigned
#' a value of 2 according to \href{https://www.asprs.org/wp-content/uploads/2019/07/LAS_1_4_r15.pdf}{las specifications}.
#'
#' @template param-las
#'
#' @param algorithm a ground-segmentation function. \code{lidR} has: \link{pmf} and \link{csf}.
#' @param last_returns logical. The algorithm will use only the last returns (including the first returns
#' in cases of a single return) to run the algorithm. If FALSE all the returns are used. If the attribute
#' \code{'ReturnNumber'} or \code{'NumberOfReturns'} are absent, \code{'last_returns'} is turned
#' to \code{FALSE} automatically.
#'
#' @template LAScatalog
#'
#' @template section-supported-option-lasupdater
#'
#' @template return-lasupdater-las-lascatalog
#'
#' @export
#'
#' @examples
#' LASfile <- system.file("extdata", "Topography.laz", package="lidR")
#' las <- readLAS(LASfile, select = "xyzrn")
#'
#' # Using the Progressive Morphological Filter
#' # --------------------------------------
#'
#' ws  <- seq(3,12, 3)
#' th  <- seq(0.1, 1.5, length.out = length(ws))
#'
#' las <- classify_ground(las, pmf(ws, th))
#' plot(las, color = "Classification")
#'
#' #' # Using the Cloth Simulation Filter
#' # --------------------------------------
#'
#' # (Parameters chosen mainly for speed)
#' mycsf <- csf(TRUE, 1, 1, time_step = 1)
#' las <- classify_ground(las, mycsf)
#' plot(las, color = "Classification")
classify_ground = function(las, algorithm, last_returns = TRUE)
{
  UseMethod("classify_ground", las)
}

#' @export
classify_ground.LAS = function(las, algorithm, last_returns = TRUE)
{
  assert_is_algorithm(algorithm)
  assert_is_algorithm_gnd(algorithm)

  filter <- TRUE
  if (last_returns) {
    if (!all(c("ReturnNumber", "NumberOfReturns") %in% names(las@data))) {
      warning("'ReturnNumber' and/or 'NumberOfReturns' not found. Cannot use the option 'last_returns', all the points will be used.", call. = FALSE)
    } else {
      filter <- parse_filter(las, ~ReturnNumber == NumberOfReturns)
      if (sum(filter) == 0) {
        warning("Zero last return found. Cannot use the option 'last_returns', all the points will be used.", call. = FALSE)
        filter <- TRUE
      }
    }
  }

  lidR.context <- "classify_ground"
  idx <- algorithm(las, filter)

  if ("Classification" %in% names(las@data))
  {
    nground <- fast_countequal(las@data[["Classification"]], 2L)

    if (nground > 0)
    {
      message(glue::glue("Original dataset already contains {nground} ground points. These points were reclassified as 'unclassified' before performing a new ground classification."))
      new_classes <- las@data[["Classification"]]
      new_classes[new_classes == LASGROUND] <- LASUNCLASSIFIED
    }
    else
    {
      new_classes <- las@data[["Classification"]]
    }
  }
  else
    new_classes <- rep(LASUNCLASSIFIED, npoints(las))

  new_classes[idx] <- LASGROUND
  las@data[["Classification"]] <- new_classes
  return(las)
}

#' @export
classify_ground.LAScluster = function(las, algorithm, last_returns = TRUE)
{
  buffer <- NULL
  x <- readLAS(las)
  if (is.empty(x)) return(NULL)
  x <- classify_ground(x, algorithm, last_returns)
  x <- filter_poi(x, buffer == LIDRNOBUFFER)
  return(x)
}

#' @export
classify_ground.LAScatalog = function(las, algorithm, last_returns = TRUE)
{
  opt_select(las) <- "*"
  options <- list(need_buffer = TRUE, drop_null = TRUE, need_output_file = TRUE, automerge = TRUE)
  output  <- catalog_apply(las, classify_ground, algorithm = algorithm,  last_returns = last_returns, .options = options)
  return(output)
}
