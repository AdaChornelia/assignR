\name{pdRaster}

\alias{pdRaster}

\title{
Probability of origin surfaces
}

\description{
Calculate posterior probabilities of origin for a sample based on its isotope ratio.
}

\usage{
pdRaster(r, unknown, prior = NULL, mask = NULL, genplot = TRUE, outDir = NULL)
}

\arguments{
\item{r}{
RasterStack or RasterBrick with two layers, e.g., as created by \code{\link[assignR]{calRaster}}. The first layer is the tissue-specific isoscape and the second the isoscape prediction uncertainty (1 standard deviation).
}
\item{unknown}{
data.frame. First column should be unique sample IDs, and second column should be tissue isotope values for the individuals for which the assignments will be made.
}
\item{prior}{
raster. Optional raster layer with prior probabilities, which has the same projection, resolution and extent as \code{r}.
}
\item{mask}{
SpatialPolygonsDataFrame. This mask will constrain the assignment area. If this is not provided, a default of mask of the extent of \code{r} is used.
}
\item{genplot}{
logical. Plot results in R.
}
\item{outDir}{
character string. Directory path to which output will be saved. If NULL no files are written.
}
}

\value{
RasterStack or RasterLayer including a probability density surface for each individual in \code{unknown}. If \code{outDir} is not NULL, writes individual rasters in GeoTIFF format and a single PDF file with images for each probability density raster to the designated directory.
}

\seealso{
\code{\link[assignR]{calRaster}}
}

\examples{
# load North America boundary and global isoscape
data("naMap")
data("d2h_world")

# load hydrogen isotope data for human hair in North America
d = subOrigData(group = "Modern human", mask = naMap)

# rescale from environmental isoscape to tissue isoscape
r = calRaster(known = d, isoscape = d2h_world, mask = naMap)

# sample to assign
id = "smile"
d2H = -80
un = data.frame(id, d2H)

# posterior probability surface
asn = pdRaster(r, unknown = un, mask = naMap)
}
