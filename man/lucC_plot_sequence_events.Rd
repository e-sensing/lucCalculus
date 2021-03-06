% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lucC_plot_results.R
\docType{data}
\name{lucC_plot_sequence_events}
\alias{lucC_plot_sequence_events}
\title{Plot Sequence Maps}
\usage{
lucC_plot_sequence_events (data_mtx = NULL, custom_palette = FALSE,
RGB_color = NULL, show_y_index = TRUE, start_date = "2000-01-01",
end_date = "2016-12-31", relabel = FALSE, original_labels = NULL,
new_labels = NULL)
}
\arguments{
\item{data_mtx}{Matrix. A matrix with values obtained from predicates RECUR, EVOLVE, CONVERT or HOLDS}

\item{custom_palette}{Boolean. A TRUE or FALSE value. If TRUE, user will provide its own color palette setting! Default is FALSE}

\item{RGB_color}{Character. A vector with color names to sequence legend, for example, c("Green","Blue"). Default is setting scale_colour_hue}

\item{show_y_index}{Boolean. TRUE/FALSE to show the index values in the axis y of the graphic}

\item{start_date}{Date. A start date to plot in sequence in format (ymd), '2011-01-01'}

\item{end_date}{Date. A end date to plot in sequence in format (ymd), '2013-01-01'}

\item{relabel}{Boolean. A TRUE or FALSE value. If TRUE, user will provide its own legend text setting! Default is FALSE}

\item{original_labels}{Character. A vector with original labels from legend text, for example, c("Forest","Pasture").}

\item{new_labels}{Character. A vector with new labels to legend text, for example, c("Mature_Forest","Pasture1").}
}
\value{
Plot sequence time series as lines
}
\description{
Plot locations as a sequence of lines over time
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

a <- lucC_pred_holds(raster_obj = rb_class, raster_class = c("Pasture"),
                     time_interval = c("2007-09-01","2010-09-01"),
                     relation_interval = "contains", label = my_label,
                     timeline = my_timeline)

lucC_plot_sequence_events(data_mtx = a, show_y_index = FALSE,
                          custom_palette = TRUE, RGB_color = c("#929e6e"))

}

}
\author{
Adeline M. Maciel
}
\keyword{datasets}
