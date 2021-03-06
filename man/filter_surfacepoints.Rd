% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_surfacepoints.R
\name{filter_surfacepoints}
\alias{filter_surfacepoints}
\title{Filter the surface points}
\usage{
filter_surfacepoints(las, res)
}
\arguments{
\item{las}{An object of class \link[lidR:LAS-class]{LAS} or \link[lidR:LAScatalog-class]{LAScatalog}.}

\item{res}{numeric. The resolution of the grid used to filter the point cloud}
}
\value{
If the input is a \code{LAS} object, returns a \code{LAS} object. If the input is a
\code{LAScatalog}, returns a \code{LAScatalog}.
}
\description{
This function is superseded by the algorithm \link{highest} usable in \link{decimate_points}
}
\section{Supported processing options}{

Supported processing options for a \code{LAScatalog} (in bold). For more details see the
\link[lidR:LAScatalog-class]{LAScatalog engine documentation}:
\itemize{
\item \strong{chunk size}: How much data is loaded at once.
\item chunk buffer: This function guarantee a strict wall-to-wall continuous output. The \code{buffer}
option is not considered.
\item \strong{chunk alignment}: Align the processed chunks.
\item \strong{progress}: Displays a progression estimation.
\item \strong{output files*}: Mandatory because the output is likely to be too big to be returned
in R and needs to be written in las/laz files. Supported templates are \code{\{XLEFT\}}, \code{\{XRIGHT\}},
\code{\{YBOTTOM\}}, \code{\{YTOP\}}, \code{\{XCENTER\}}, \code{\{YCENTER\}} \code{\{ID\}} and, if
chunk size is equal to 0 (processing by file), \code{\{ORIGINALFILENAME\}}.
\item select: The function will write files equivalent to the original ones. Thus \code{select = "*"}
and cannot be changed.
\item \strong{filter}: Read only points of interest.
}
}

\examples{
LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
las = readLAS(LASfile)
subset = filter_surfacepoints(las, 2)
plot(subset)

}
\seealso{
Other filters: 
\code{\link{filter_duplicates}()},
\code{\link{filter_poi}()},
\code{\link{filters}}
}
\concept{filters}
