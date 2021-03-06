#################################################################
##                                                             ##
##   (c) Adeline Marinho <adelsud6@gmail.com>                  ##
##                                                             ##
##       Image Processing Division                             ##
##       National Institute for Space Research (INPE), Brazil  ##
##                                                             ##
##                                                             ##
##   R script with predicates holds(o,c,t) with raster         ##
##   and combined predicates, recur, evolve and convert        ##
##                                                             ##
##                                             2018-08-28      ##
##                                                             ##
##  J. F. Allen.  Towards a general theory of action and       ##
##  time. Artificial Intelligence, 23(2): 123--154, 1984.      ##
##                                                             ##
#################################################################


#' @title Predicate Allen Holds
#' @name lucC_pred_holds
#' @aliases lucC_pred_holds
#' @author Adeline M. Maciel
#' @docType data
#'
#' @description Provide a predicate HOLDS which evaluates as true when a class \code{c_i},
#' e.g. 'Forest', holds uring the interval \code{t_i}. Return a matrix with values within
#' defined interval
#'
#' @usage lucC_pred_holds (raster_obj = NULL, raster_class = NULL,
#' time_interval = c("2000-01-01", "2004-01-01"),
#' relation_interval = "contains", label = NULL, timeline = NULL)
#'
#' @param raster_obj        Raster. A raster brick with classified images
#' @param raster_class      Character. Name of the class of interest, such as 'Forest', to research
#' @param time_interval     Interval. A time interval to verify if class is over or not
#' @param relation_interval Character. If a location HOLDS during all time interval 'equals' or can be appear in any
#'                          times 'contains'. Default is 'contains'
#' @param label             Character Vector. All labels of each value of pixel from classified raster
#' @param timeline          Character. A list of all dates of classified raster, timeline
#'
#' @keywords datasets
#' @return Matrix with all states which holds during a time interval
#' @importFrom lubridate int_standardize int_start int_end as_date ymd years
#' @importFrom raster subset rasterToPoints values
#' @importFrom tidyr drop_na
#' @export
#'
#' @examples \dontrun{
#' library(lucCalculus)
#'
#' file <- c(system.file("extdata/raster/rasterSample.tif", package = "lucCalculus"))
#' rb_class <- raster::brick(file)
#' my_label <- c("Degradation", "Fallow_Cotton", "Forest", "Pasture", "Soy_Corn", "Soy_Cotton",
#'               "Soy_Fallow", "Soy_Millet", "Soy_Sunflower", "Sugarcane", "Urban_Area", "Water")
#' my_timeline <- c("2001-09-01", "2002-09-01", "2003-09-01", "2004-09-01", "2005-09-01",
#'                  "2006-09-01", "2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01",
#'                  "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01",
#'                  "2016-09-01")
#'
#' a <- lucC_pred_holds(raster_obj = rb_class, raster_class = c("Pasture"),
#'                      time_interval = c("2007-09-01","2010-09-01"),
#'                      relation_interval = "contains", label = my_label,
#'                      timeline = my_timeline)
#' a
#'
#'}
#'

# HOLDS(property, time)
# Asserts that a class holds during a time interval
# version: 3
# format: holds(o,c,t)
# parameters: o = locations, c = class of locations and t = time intervals
lucC_pred_holds <- function(raster_obj = NULL, raster_class = NULL, time_interval = c("2000-01-01", "2004-01-01"), relation_interval = "contains", label = NULL, timeline = NULL){

  options(digits = 12)

  if (!is.null(raster_obj) & !is.null(raster_class) & !is.null(label) & !is.null(timeline)) {
    rasterBrick_obj <- raster_obj
    class_name <- as.character(raster_class)
    label <- label
    timeline <- timeline
  } else {
    stop("\nParameters:\n raster_obj (rasterBrick),\n
         raster_class ('Forest') and must be defined!\n
         final_result = TRUE or FALSE\n")
  }

  rm(raster_obj)
  gc()

  if (!is.null(time_interval) & isTRUE(time_interval[1] <= time_interval[2])) {

    # checking if first or second interval values are correct
    t <- lucC_interval(time_interval[1],time_interval[2]) %>%
      lubridate::int_standardize()

    # define time interval initial
    date_start <- match(as.character(lubridate::as_date(format(lubridate::int_start(t), format = '%Y-%m-%d'))), as.character(timeline))

    # define time interval final
    date_end <- match(as.character(lubridate::as_date(format(lubridate::int_end(t), format = '%Y-%m-%d'))), as.character(timeline))

  } else {
    stop("\nParameters:\n
         First date needs to be less than second.\n
         Date format of time_interval = c('2000-01-01', '2004-01-01') must be defined!\n")
  }

  # relation Allen CONTAINS or EQUALS
  if (!is.null(relation_interval) & (relation_interval == "equals" | relation_interval == "contains")) {
    relation_allen <- relation_interval
  } else{
    stop("\nInvalide option: 'equals' or 'contains' must be defined!\n")
  }

  # define values to query, in accordance of label order
  #class <- match(class_name, label)
  class <- which(label %in% class_name)

  # subset with all locations from raster holds during a time interval
  .holds_raster <- function(ras.obj, class.ras, start_date.ras, end_date.ras) {
    # subset in accordance with range of date
    output <- raster::subset(ras.obj, start_date.ras:end_date.ras, value = TRUE)
    # just replace all values raster match will position label
    raster::values(output) <- ifelse(raster::values(output) %in% class.ras, 1, NA)
    #output[output[] %in% class.ras] <- NA
    return(output)
  }

  # apply holds_raster to obtain results
  output_holds <- .holds_raster(rasterBrick_obj, class, date_start, date_end)

  # empty data
  longLatFromRaster <- NULL

  # extract x, y, and values from raster output_holds
  longLatFromRaster <- raster::rasterToPoints(output_holds)
  #longLatFromRaster <- raster::as.data.frame(output_holds, xy = TRUE) # another way

  if (relation_allen == "equals" & ncol(longLatFromRaster) > 3) {
    longLatFromRaster.mtx <- longLatFromRaster[
      base::rowSums(longLatFromRaster[,c(3:ncol(longLatFromRaster)), drop=FALSE] &
                      !is.na(longLatFromRaster[,c(3:ncol(longLatFromRaster))])) == length(3:ncol(longLatFromRaster)),]
  } else if (relation_allen == "contains" & ncol(longLatFromRaster) > 3)  {
    longLatFromRaster.mtx <- longLatFromRaster[
      base::rowSums(longLatFromRaster[,c(3:ncol(longLatFromRaster)), drop=FALSE] &
                      !is.na(longLatFromRaster[,c(3:ncol(longLatFromRaster))])) > 0,]
  } else if ((relation_allen == "equals" | relation_allen == "contains") & ncol(longLatFromRaster) == 3){
    longLatFromRaster.mtx <- longLatFromRaster[!(is.na(longLatFromRaster[, 3]) | longLatFromRaster[, 3] == 0), ]
  }

  ## test rows entire FALSE values
  # dplyr::anti_join(longLatFromRaster,longLatFromRaster.mtx)

  rm(longLatFromRaster)
  gc()

  # define timeline from raster output_holds
  timeline_holds = timeline[ timeline >= timeline[date_start] & timeline <= timeline[date_end]]

  # alter column names of data.frame
  if( NCOL(longLatFromRaster.mtx) == 1 & is.null(ncol(longLatFromRaster.mtx))){
    # case there is only one value
    longLatFromRaster.mtx <- base::as.matrix(t(longLatFromRaster.mtx))
    colnames(longLatFromRaster.mtx)[c(3:ncol(longLatFromRaster.mtx))] <- as.character(timeline_holds)
  } else if( nrow(longLatFromRaster.mtx) == 0){
    # case there is no values
    longLatFromRaster.mtx <- NULL
    return(longLatFromRaster.mtx)
  } else {
    # case more than one value
    colnames(longLatFromRaster.mtx)[c(3:ncol(longLatFromRaster.mtx))] <- as.character(timeline_holds)
  }

  # alter label for original value in character
  longLatFromRaster.mtx[,c(3:ncol(longLatFromRaster.mtx))] <-
    as.character(ifelse(longLatFromRaster.mtx[,c(3:ncol(longLatFromRaster.mtx))] == 1, class_name, NA))

  longLatFromRaster.mtx

  return(longLatFromRaster.mtx)
  }


#' @title Build Intervals of Data with Raster
#' @name .lucC_check_intervals
#' @aliases .lucC_check_intervals
#' @author Adeline M. Maciel
#' @docType data
#'
#' @description Provide an valide interval from data set input.
#' And return a list with two intervals.
#'
#' @usage .lucC_check_intervals(first_int = NULL, second_int = NULL)
#'
#' @param first_int    Date. An interval between two dates.
#' @param second_int   Date. An interval between two dates.
#'
#' @keywords datasets
#' @return A list with value of interval for each data set
#' @importFrom lubridate int_overlaps
#'

.lucC_check_intervals <- function (first_int = NULL, second_int = NULL) {

  # check if they are intervals and not overlaped
  time_int1 <- lucC_interval(first_int[1],first_int[2])
  time_int2 <- lucC_interval(second_int[1],second_int[2])

  if (!isTRUE(lubridate::int_overlaps(time_int1,time_int2))) {
    first_interval <- first_int
    second_interval <- second_int
    # return a list with two valid values
    output <- list(first_interval, second_interval)

    return(output)
  }
  else {
    stop("\nParameters:\n
         time_interval1 can not overlap time_interval2! \n\n")
  }

  }


#' @title Predicate Recur
#' @name lucC_pred_recur
#' @aliases lucC_pred_recur
#' @author Adeline M. Maciel
#' @docType data
#'
#' @description Provide a predicate RECUR which evaluates as true when a location holds
#' a class \code{c_i}, e.g. 'Forest', during two non-continuous distinct intervals
#' \code{t_i} and \code{t_j}. Return a matrix with values within defined interval
#'
#' @usage lucC_pred_recur (raster_obj = NULL, raster_class = NULL,
#' time_interval1 = c("2001-01-01", "2001-01-01"),
#' time_interval2 = c("2002-01-01", "2005-01-01"),
#' label = NULL, timeline = NULL, remove_column = TRUE)
#'
#' @param raster_obj       Raster. A raster brick with classified images
#' @param raster_class     Character. Name of the class of interest, such as 'Forest', to research
#' @param time_interval1   Interval. A first time interval to verify if class is over or not
#' @param time_interval2   Interval. A second and non-overlapped time interval to verify if class is over or not
#' @param label            Character Vector. All labels of each value of pixel from classified raster
#' @param timeline         Character. A list of all dates of classified raster, timeline
#' @param remove_column    Boolean. Remove matrix values relating to the first time interval, only values of second interval are returned. Default is TRUE
#'
#' @keywords datasets
#' @return Matrix with all states which holds during a time interval
#' @importFrom lubridate int_standardize int_start int_end as_date ymd years
#' @importFrom raster subset rasterToPoints
#' @importFrom tidyr drop_na
#' @importFrom stats complete.cases
#' @export
#'
#' @examples \dontrun{
#'library(lucCalculus)
#'
#' file <- c(system.file("extdata/raster/rasterSample.tif", package = "lucCalculus"))
#' rb_class <- raster::brick(file)
#' my_label <- c("Degradation", "Fallow_Cotton", "Forest", "Pasture", "Soy_Corn", "Soy_Cotton",
#'               "Soy_Fallow", "Soy_Millet", "Soy_Sunflower", "Sugarcane", "Urban_Area", "Water")
#' my_timeline <- c("2001-09-01", "2002-09-01", "2003-09-01", "2004-09-01", "2005-09-01",
#'                  "2006-09-01", "2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01",
#'                  "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01",
#'                  "2016-09-01")
#'
#' b <- lucC_pred_recur(raster_obj = rb_class, raster_class = "Forest",
#'                      time_interval1 = c("2001-09-01","2001-09-01"),
#'                      time_interval2 = c("2002-09-01","2016-09-01"),
#'                      label = my_label, timeline = my_timeline)
#'
#' lucC_plot_raster_result(raster_obj = rb_class, data_mtx = b,
#'                         timeline = my_timeline, label = my_label,
#'                         custom_palette = FALSE)
#'
#'}
#'

# RECUR(location, class1, interval1, interval2)
lucC_pred_recur <- function(raster_obj = NULL, raster_class = NULL, time_interval1 = c("2001-01-01", "2001-01-01"), time_interval2 = c("2002-01-01", "2005-01-01"), label = NULL, timeline = NULL, remove_column = TRUE){

  if (!is.null(raster_obj) & !is.null(raster_class) & !is.null(label) & !is.null(timeline)) {
    rasterBrick_obj <- raster_obj
    class_name <- as.character(raster_class)
    label <- label
    timeline <- timeline
  } else {
    stop("\nParameters:\n raster_obj (rasterBrick),\n
         raster_class ('Forest') and must be defined!\n
         final_result = TRUE or FALSE\n")
  }

  rm(raster_obj)
  gc()

  # check time intervals
  if (!is.null(time_interval1) & !is.null(time_interval2) & all(time_interval1 < time_interval2)) {
    # checking if first or second interval values are valid
    time_intervals <- .lucC_check_intervals(first_int = time_interval1, second_int = time_interval2)

  } else {
    stop("\nParameters:\n
         time_interval1 must be (<) less than time_interval2 \n
         time_interval1 and time_interval2, as in the format \n
         time_interval1 = c('2000-01-01', '2004-01-01') must be defined!\n")
  }

  # apply holds in both temporal intervals
  res1 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name,
                          time_interval = c(time_intervals[[1]][1], time_intervals[[1]][2]), relation_interval = "equals",
                          label = label, timeline = timeline)
  res2 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name,
                          time_interval = c(time_intervals[[2]][1], time_intervals[[2]][2]), relation_interval = "contains",
                          label = label, timeline = timeline)

  # interval = rasters_intervals[[1]] (first interval), rasters_intervals[[2]] (second_interval)
  if (length(res1) == 0 | length(res2) == 0){
    message("\nRelation RECUR cannot be applied!\n
            This class does not exist in the defined interval.\n")
    return(result <- NULL)
  } else if( nrow(res1) > 0 & nrow(res2) > 0 & ncol(res2) > 4 ) {
    # 1. isolate only rows with NA
    # all differents of this -> F F F F F F F
    # 2. isolate rows with NA occurs after a sequence of same classes
    # all differents of this -> F F F F NA NA NA, F F NA NA NA NA or F NA NA NA NA
    res2.1 <- res2[!stats::complete.cases(res2),] %>%
      .[base::rowSums(is.na(.[,c(3:(ncol(.)-1))]) * !is.na(.[,4:ncol(.)])) > 0, ]

    # 3. isolate elements that occurs before of the first NA by row, changed them by NA
    # all differents of this -> F NA NA F F F -> NA NA NA F F F; F F NA NA F NA -> NA NA NA NA F NA
    .different_class <- function(x){
      idna <- which(is.na(x))
      idnonna <- which(!is.na(x))
      if (idnonna[1] < idna[1])
        x[idnonna[idnonna < idna[1]]] <- NA
      else
        x
      return(x)
    }

    # verify if exist res2.1 has isolated elements
    if(nrow(res2.1) > 0){
      res2.out <- cbind(res2.1[,c(1:2)], t(apply(res2.1[,c(3:ncol(res2.1))], 1, .different_class)))
    } else {
      message("\nRelation RECUR cannot be applied!\n
              Second time interval must does not has elements with recurrence \n")
      return(result <- NULL)
    }

    rm(res2.1)
    gc()

    result <- merge(res1 , res2.out, by=c("x","y"))
    result <- result[!duplicated(result), ]

    # remove first interval values of the output
    if (!is.null(result)){
      # remove first interval values of the output
      if(remove_column == TRUE){
        if(length(unique(time_interval1)) == 1){
          result <- lucC_remove_columns(data_mtx = result, name_columns = unique(time_interval1))
          return(result)
        } else {
          values <- timeline[ timeline >= time_interval1[1] & timeline <= time_interval1[2]]
          result <- lucC_remove_columns(data_mtx = result, name_columns = values)
          return(result)
        }
      } else
        return(result)
    } else
      return(result)
  } else {
    message("\nRelation RECUR cannot be applied!\n
            Second time interval must have more than two dates, i.e, 2002-2004.\n")
    return(result <- NULL)
  }

  }


#' @title Predicate Evolve
#' @name lucC_pred_evolve
#' @aliases lucC_pred_evolve
#' @author Adeline M. Maciel
#' @docType data
#'
#' @description Provide a predicate EVOLVE which evaluates as true when a location holds the
#' class \code{c_i}, e.g. 'Forest', during the interval \code{t_i}, class \code{c_j}, e.g.
#' 'Pasture', during the interval \code{t_j} and \code{t_j} is not necessarily immediately
#' sequential of \code{t_i}. Return a matrix with values within defined interval
#'
#' @usage lucC_pred_evolve (raster_obj = NULL, raster_class1 = NULL,
#' time_interval1 = c("2001-01-01", "2001-01-01"), relation_interval1 = "equals",
#' raster_class2 = NULL, time_interval2 = c("2002-01-01", "2005-01-01"),
#' relation_interval2 = "contains", label = NULL, timeline = NULL,
#' remove_column = TRUE)
#'
#' @param raster_obj         Raster. A raster brick with classified images
#' @param raster_class1      Character. Name of the first class of interest, such as 'Forest', to research
#' @param time_interval1     Interval. A first interval to verify if class is over or not
#' @param relation_interval1 Character. If a location HOLDS during all time interval 'equals' or can be appear in any
#'                           times 'contains'. Default is 'equals'
#' @param raster_class2      Character. Name of the second class of interest, such as 'Pasture', to research
#' @param time_interval2     Interval. A second interval to verify if class is over or not
#' @param relation_interval2 Character. If a location HOLDS during all time interval 'equals' or can be appear in any
#'                           times 'contains'. Default is 'contains'
#' @param label              Character Vector. All labels of each value of pixel from classified raster
#' @param timeline           Character. A list of all dates of classified raster, timeline
#' @param remove_column    Boolean. Remove matrix values relating to the first time interval, only values of second interval are returned. Default is TRUE
#'
#' @keywords datasets
#' @return Matrix with all states which holds during a time interval
#' @importFrom lubridate int_standardize int_start int_end as_date ymd years
#' @importFrom raster subset rasterToPoints
#' @importFrom tidyr drop_na
#' @export
#'
#' @examples \dontrun{
#' library(lucCalculus)
#'
#' file <- c(system.file("extdata/raster/rasterSample.tif", package = "lucCalculus"))
#' rb_class <- raster::brick(file)
#' my_label <- c("Degradation", "Fallow_Cotton", "Forest", "Pasture", "Soy_Corn", "Soy_Cotton",
#'               "Soy_Fallow", "Soy_Millet", "Soy_Sunflower", "Sugarcane", "Urban_Area", "Water")
#' my_timeline <- c("2001-09-01", "2002-09-01", "2003-09-01", "2004-09-01", "2005-09-01",
#'                  "2006-09-01", "2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01",
#'                  "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01",
#'                  "2016-09-01")
#'
#' c <- lucC_pred_evolve(raster_obj = rb_class, raster_class1 = "Forest",
#'                       time_interval1 = c("2001-09-01","2001-09-01"),
#'                       relation_interval1 = "equals",
#'                       raster_class2 = "Pasture",
#'                       time_interval2 = c("2002-09-01","2016-09-01"),
#'                       relation_interval2 = "contains",
#'                       label = my_label, timeline = my_timeline)
#'
#' lucC_plot_raster_result(raster_obj = rb_class, data_mtx = c,
#'                         timeline = my_timeline, label = my_label,
#'                         custom_palette = FALSE)
#'
#'}
#'

# EVOLVE(location, class1, interval1, class2, interval2) - USE BEFORE AND MEETS RELATIONS
lucC_pred_evolve <- function(raster_obj = NULL, raster_class1 = NULL, time_interval1 = c("2001-01-01", "2001-01-01"), relation_interval1 = "equals",  raster_class2 = NULL, time_interval2 = c("2002-01-01", "2005-01-01"), relation_interval2 = "contains", label = NULL, timeline = NULL, remove_column = TRUE){

  if (!is.null(raster_obj) & !is.null(raster_class1) & !is.null(raster_class2)
      & !is.null(label) & !is.null(timeline)) {
    rasterBrick_obj <- raster_obj
    class_name1 <- as.character(raster_class1)
    class_name2 <- as.character(raster_class2)
    label <- label
    timeline <- timeline
  } else {
    stop("\nParameters:\n raster_obj (rasterBrick),\n
         raster_class ('Forest') and must be defined!\n
         final_result = TRUE or FALSE\n")
  }

  rm(raster_obj)
  gc()

  # check time intervals
  if (!is.null(time_interval1) & !is.null(time_interval2) & all(time_interval1 < time_interval2)) {
    # checking if first or second interval values are valid
    time_intervals <- .lucC_check_intervals(first_int = time_interval1, second_int = time_interval2)

  } else {
    stop("\nParameters:\n
         time_interval1 must be (<) less than time_interval2 \n
         time_interval1 and time_interval2, as in the format \n
         time_interval1 = c('2000-01-01', '2004-01-01') must be defined!\n")
  }

  # apply holds in both temporal intervals
  res1 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name1,
                          time_interval = c(time_intervals[[1]][1], time_intervals[[1]][2]), relation_interval = "contains",
                          label = label, timeline = timeline)
  res2 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name2,
                          time_interval = c(time_intervals[[2]][1], time_intervals[[2]][2]), relation_interval = "contains",
                          label = label, timeline = timeline)

  # interval = rasters_intervals[[1]] (first interval), rasters_intervals[[2]] (second_interval)
  if (length(res1) == 0 | length(res2) == 0){
    message("\nRelation EVOLVE cannot be applied!\n
            This class does not exist in the defined interval.\n")
    return(result <- NULL)
  } else if( (nrow(res1) > 0)  & (nrow(res2) > 0) ) {

    result <- lucC_relation_follows(res1, res2)

    result <- result[!duplicated(result), ]

    # remove first interval values of the output
    if (!is.null(result)){
      # remove first interval values of the output
      if(remove_column == TRUE){
        if(length(unique(time_interval1)) == 1){
          result <- lucC_remove_columns(data_mtx = result, name_columns = unique(time_interval1))
          return(result)
        } else {
          values <- timeline[ timeline >= time_interval1[1] & timeline <= time_interval1[2]]
          result <- lucC_remove_columns(data_mtx = result, name_columns = values)
          return(result)
        }
      } else
        return(result)
    } else
      return(result)
  } else {
    message("\nRelation EVOLVE cannot be applied!\n")
    return(result <- NULL)
  }

  }



#' @title Predicate Convert
#' @name lucC_pred_convert
#' @aliases lucC_pred_convert
#' @author Adeline M. Maciel
#' @docType data
#'
#' @description Provide a predicate CONVERT which evaluates as true when a location holds the
#' class \code{c_i}, e.g. 'Forest', during the interval \code{t_i}, class \code{c_j}, e.g. 'Soybean',
#' during the interval \code{t_j} and \code{t_j} is sequential of \code{t_i}. Return a matrix
#' with values within defined interval
#'
#' @usage lucC_pred_convert (raster_obj = NULL, raster_class1 = NULL,
#' time_interval1 = c("2001-01-01", "2001-01-01"), relation_interval1 = "equals",
#' raster_class2 = NULL, time_interval2 = c("2002-01-01", "2005-01-01"),
#' relation_interval2 = "equals", label = NULL, timeline = NULL,
#' remove_column = TRUE)
#'
#' @param raster_obj         Raster. A raster brick with classified images
#' @param raster_class1      Character. Name of the first class of interest, such as 'Forest', to research
#' @param time_interval1     Interval. A first interval to verify if class is over or not
#' @param relation_interval1 Character. If a location HOLDS during all time interval 'equals' or can be appear in any
#'                           times 'contains'. Default is 'equals'
#' @param raster_class2      Character. Name of the second class of interest, such as 'Pasture', to research
#' @param time_interval2     Interval. A second interval to verify if class is over or not
#' @param relation_interval2 Character. If a location HOLDS during all time interval 'equals' or can be appear in any
#'                           times 'contains'. Default is 'equals'
#' @param label              Character Vector. All labels of each value of pixel from classified raster
#' @param timeline           Character. A list of all dates of classified raster, timeline
#' @param remove_column    Boolean. Remove matrix values relating to the first time interval, only values of second interval are returned. Default is TRUE
#'
#' @keywords datasets
#' @return Matrix with all states which holds during a time interval
#' @importFrom lubridate int_standardize int_start int_end as_date ymd years
#' @importFrom raster subset rasterToPoints
#' @importFrom tidyr drop_na
#' @export
#'
#' @examples \dontrun{
#' library(lucCalculus)
#'
#' file <- c(system.file("extdata/raster/rasterSample.tif", package = "lucCalculus"))
#' rb_class <- raster::brick(file)
#' my_label <- c("Degradation", "Fallow_Cotton", "Forest", "Pasture", "Soy_Corn", "Soy_Cotton",
#'               "Soy_Fallow", "Soy_Millet", "Soy_Sunflower", "Sugarcane", "Urban_Area", "Water")
#' my_timeline <- c("2001-09-01", "2002-09-01", "2003-09-01", "2004-09-01", "2005-09-01",
#'                  "2006-09-01", "2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01",
#'                  "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01",
#'                  "2016-09-01")
#'
#' d <- lucC_pred_convert(raster_obj = rb_class, raster_class1 = "Forest",
#'                        time_interval1 = c("2012-09-01","2012-09-01"),
#'                        relation_interval1 = "equals",
#'                        raster_class2 = "Degradation",
#'                        time_interval2 = c("2013-09-01","2013-09-01"),
#'                        relation_interval2 = "equals",
#'                        label = my_label, timeline = my_timeline)
#'
#' lucC_plot_raster_result(raster_obj = rb_class, data_mtx = d,
#'                         timeline = my_timeline, label = my_label,
#'                         custom_palette = FALSE)
#'
#'}
#'

# CONVERT(location, class1, interval1, class2, interval2) - USE ONLY MEETS RELATION
lucC_pred_convert <- function(raster_obj = NULL, raster_class1 = NULL, time_interval1 = c("2001-01-01", "2001-01-01"), relation_interval1 = "equals",  raster_class2 = NULL, time_interval2 = c("2002-01-01", "2005-01-01"), relation_interval2 = "equals", label = NULL, timeline = NULL, remove_column = TRUE){

  if (!is.null(raster_obj) & !is.null(raster_class1) & !is.null(raster_class2)
      & !is.null(label) & !is.null(timeline)) {
    rasterBrick_obj <- raster_obj
    class_name1 <- as.character(raster_class1)
    class_name2 <- as.character(raster_class2)
    label <- label
    timeline <- timeline
  } else {
    stop("\nParameters:\n raster_obj (rasterBrick),\n
         raster_class ('Forest') and must be defined!\n
         final_result = TRUE or FALSE\n")
  }

  rm(raster_obj)
  gc()

  # check time intervals
  if (!is.null(time_interval1) & !is.null(time_interval2) & all(time_interval1 < time_interval2)) {
    # checking if first or second interval values are valid
    time_intervals <- .lucC_check_intervals(first_int = time_interval1, second_int = time_interval2)

  } else {
    stop("\nParameters:\n
         time_interval1 must be (<) less than time_interval2 \n
         time_interval1 and time_interval2, as in the format \n
         time_interval1 = c('2000-01-01', '2004-01-01') must be defined!\n")
  }

  # apply holds in both temporal intervals
  res1 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name1,
                          time_interval = c(time_intervals[[1]][1], time_intervals[[1]][2]), relation_interval = relation_interval1,
                          label = label, timeline = timeline)
  res2 <- lucC_pred_holds(raster_obj = rasterBrick_obj, raster_class = class_name2,
                          time_interval = c(time_intervals[[2]][1], time_intervals[[2]][2]), relation_interval = relation_interval2,
                          label = label, timeline = timeline)

  # interval = rasters_intervals[[1]] (first interval), rasters_intervals[[2]] (second_interval)
  if (length(res1) == 0 | length(res2) == 0){
    message("\nRelation CONVERT cannot be applied!\n
         This class does not exist in the defined interval.\n")
    return(result <- NULL)
  } else if( (nrow(res1) > 0)  & (nrow(res2) > 0) ) {

    result <- lucC_relation_meets(res1, res2)

    result <- result[!duplicated(result), ]

    if (!is.null(result)){
      # remove first interval values of the output
      if(remove_column == TRUE){
        if(length(unique(time_interval1)) == 1){
          result <- lucC_remove_columns(data_mtx = result, name_columns = unique(time_interval1))
          return(result)
        } else {
          values <- timeline[ timeline >= time_interval1[1] & timeline <= time_interval1[2]]
          result <- lucC_remove_columns(data_mtx = result, name_columns = values)
          return(result)
        }
      } else
        return(result)
    } else
      return(result)
  } else {
    message("\nRelation CONVERT cannot be applied!\n")
    return(result <- NULL)
  }
  }



