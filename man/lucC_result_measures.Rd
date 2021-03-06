% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lucC_result_measures.R
\docType{data}
\name{lucC_result_measures}
\alias{lucC_result_measures}
\title{Data.frame with statistical measures}
\usage{
lucC_result_measures (data_mtx = NULL, data_frequency = NULL, pixel_resolution = 250)
}
\arguments{
\item{data_mtx}{Matrix. A matrix with values obtained from predicates RECUR, EVOLVE, CONVERT or HOLDS}

\item{data_frequency}{Dataframe. A frequency table of a categorical variable from a data set}

\item{pixel_resolution}{Numeric. Is a spatial resolution of the pixel. Default is 250 meters considering MODIS 250 m. See more at \url{https://modis.gsfc.nasa.gov/about/specifications.php}.}
}
\value{
Data frame with statistical measures
}
\description{
Provide a data.frame with main statistical measures to resultd from LUC Calculus application such as: Area (km2),
Cumulative Sum, Relative Frequency and Cumulative Relative Frequency
}
\examples{
\dontrun{
library(lucCalculus)

file <- c(system.file("extdata/raster/rasterSample.tif", package = "lucCalculus"))
rb_class <- raster::brick(file)
my_label <- c("Degradation", "Fallow_Cotton", "Forest", "Pasture", "Soy_Corn", "Soy_Cotton",
              "Soy_Fallow", "Soy_Millet", "Soy_Sunflower", "Sugarcane", "Urban_Area", "Water")
my_timeline <- c("2001-09-01", "2002-09-01", "2003-09-01", "2004-09-01", "2005-09-01",
                 "2006-09-01", "2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01",
                 "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01",
                 "2016-09-01")

b <- lucC_pred_recur(raster_obj = rb_class, raster_class = "Forest",
                     time_interval1 = c("2001-09-01","2001-09-01"),
                     time_interval2 = c("2002-09-01","2016-09-01"),
                     label = my_label, timeline = my_timeline)

lucC_result_measures(data_mtx = b, pixel_resolution = 232)

}

}
\author{
Adeline M. Maciel
}
\keyword{datasets}
