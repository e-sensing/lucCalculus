library(lucCalculus)
# sudo apt remove libgdal-dev
# sudo apt remove libproj-dev
# sudo apt remove gdal-bin
# sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
# sudo apt update
# sudo apt get libgdal-dev
# install.packages('rgdal')

# always
options(digits = 12)

#----------------------------
# 1- Open idividual images and create a RasterBrick with each one and metadata with SITS
#----------------------------

# create a RasterBrick from individual raster saved previously
#lucC_create_RasterBrick(path_open_GeoTIFFs = "~/Desktop/INPE_2018/SBSR_2019/raster2007-2017", path_save_RasterBrick = "~/Desktop/INPE_2018/SBSR_2019/raster2007-2017")

# ------------- define variables to use in sits -------------
# open files
#file <- c("~/Desktop/INPE_2018/SBSR_2019/raster2007-2017/raster2007-2017.tif")
file <- c("~/TESTE/PRODES/raster2007-2017/raster2007-2017.tif")
file

# create timeline with classified data from SVM method
timeline <- lubridate::as_date(c("2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01", "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01", "2016-09-01", "2017-09-01"))
timeline

# #library(sits)
# # create a RasterBrick metadata file based on the information about the files
# raster.tb <- sits::sits_coverage(files = file, name = "NovoProgresso", timeline = timeline, bands = "ndvi")
# raster.tb
#
# # new variable
# rb_sits <- raster.tb$r_objs[[1]][[1]]
# rb_sits

# create a raster object associated to the file
rb_sits <- raster::brick(file)
rb_sits
# find out how many layers the object has
n_layers <- rb_sits@file@nbands

# ------------- define variables to plot raster -------------
# original label - see QML file, same order
label <- as.character(c("Forest", "Deforestation", "Non-Forest", "Hydrograph"))
#label

# colors
#colors_1 <- c("#b3cc33", "#d1f0f7", "#8ddbec", "#228b22", "#afe3c8", "#7ecfa4", "#64b376", "#e1cdb6", "#b6a896", "#b69872", "#b68549", "#9c6f38", "#e5c6a0", "#e5a352", "#0000ff", "#3a3aff")
colors_1 <- c("#00aa00", "#c81411", "#ffff00", "#0000ff")
#colors_1

# # plot raster brick
# lucC_plot_raster(raster_obj = rb_sits$raster2007.2017.1,
#                  timeline = timeline, label = label,
#                  custom_palette = TRUE, RGB_color = colors_1, plot_ncol = 5)
#
# raster::plot(rb_sits)

# # select some layers
# rb_sits
# layers <- c(1, 3, 5, 7, 9, 11)
# rb_sits_2years <- raster::subset(rb_sits, layers)
# rb_sits_2years
#
# # create timeline with classified data from SVM method
# timeline_n <- lubridate::as_date(c("2007-09-01", "2009-09-01", "2011-09-01", "2013-09-01", "2015-09-01", "2017-09-01"))
# timeline_n
#
# png(filename = "~/Desktop/fig_TESE/fig_Prodes_2d.png", width = 7, height = 5.5, units = 'in', res = 300) # width = 6.7, height = 5.4
# lucC_plot_raster(raster_obj = rb_sits_2years,
#                  timeline = timeline_n, label = label,
#                  custom_palette = TRUE, RGB_color = colors_1, plot_ncol = 3)
# dev.off()
#
# rm(rb_sits_2years)
# gc()


#----------------------------
# 1- Forest holds during entire period - LUC Calculus
#----------------------------

# 1. Verify if forest RECUR ins econd interval
system.time(
  deforestation_holds <- lucC_pred_holds(raster_obj = rb_sits, raster_class = "Deforestation",
                                    time_interval = c("2007-09-01","2017-09-01"), relation_interval = "contains",
                                    label = label, timeline = timeline)
)

head(deforestation_holds)

deforestation_holds2 <- as.data.frame(deforestation_holds)

message("Prepare image 1 ...\n")
lucC_save_raster_result(raster_obj = rb_sits, data_mtx = deforestation_holds2, timeline = timeline, label = label, path_raster_folder = "~/TESTE/PRODES/deforestation_holds", as_RasterBrick = FALSE)

message("Prepare image 2 ...\n")
lucC_save_raster_result(raster_obj = rb_sits, data_mtx = deforestation_holds2, timeline = timeline, label = label, path_raster_folder = "~/TESTE/PRODES/deforestation_holds_brick", as_RasterBrick = TRUE)

png(filename = "~/TESTE/PRODES/fig_PA_def_holds2.png", width = 6.5, height = 4.5, units = 'in', res = 300)
#lucC_plot_bar_events2(deforestation_holds, custom_palette = TRUE, RGB_color = c("black"), pixel_resolution = 61.006, side_by_side = FALSE)
#lucC_plot_bar_events(deforestation_holds, custom_palette = TRUE, RGB_color = c("black"), pixel_resolution = 61.006, legend_text = "Legend:")
lucC_plot_frequency_events(deforestation_holds, custom_palette = TRUE, RGB_color = c("black"), pixel_resolution = 61.006, legend_text = "Legend:")
dev.off()

# Compute values
measures_defores_holds <- lucC_result_measures(data_mtx = deforestation_holds, pixel_resolution = 61.006)
measures_defores_holds


# Years       Classes Pixel_number      Area_km2 Cumulative_Sum
# 1   2007 Deforestation      1037033 3859.55893849  3859.55893849
# 2   2008 Deforestation      1110328 4132.34328807  7991.90222656
# 3   2009 Deforestation      1235031 4596.45443815 12588.35666471
# 4   2010 Deforestation      1257211 4679.00245471 17267.35911942
# 5   2011 Deforestation      1281915 4770.94412293 22038.30324235
# 6   2012 Deforestation      1318880 4908.51794764 26946.82118999
# 7   2013 Deforestation      1388554 5167.82590552 32114.64709551
# 8   2014 Deforestation      1433988 5336.91907884 37451.56617435
# 9   2015 Deforestation      1469229 5468.07663752 42919.64281187
# 10  2016 Deforestation      1502157 5590.62583000 48510.26864187
# 11  2017 Deforestation      1520124 5657.49418949 54167.76283136
# Relative_Frequency Cumulative_Relative_Frequency
# 1       7.12519538698                 7.12519538698
# 2       7.62878707200                14.75398245897
# 3       8.48559031774                23.23957277671
# 4       8.63798357203                31.87755634875
# 5       8.80771860153                40.68527495027
# 6       9.06169590744                49.74697085771
# 7       9.54040860355                59.28737946126
# 8       9.85257429858                69.13995375985
# 9      10.09470642999                79.23466018984
# 10     10.32094651464                89.55560670448
# 11     10.44439329552               100.00000000000


#----------------------------
# 2- Forest evolve to deforestation - LUC Calculus
#----------------------------

# 1. Verify if forest RECUR ins econd interval
system.time(
  forest_evolve <- lucC_pred_evolve(raster_obj = rb_sits, raster_class1 = "Forest",
                             time_interval1 = c("2007-09-01","2007-09-01"), relation_interval1 = "equals",
                             raster_class2 = "Deforestation",
                             time_interval2 = c("2008-09-01","2017-09-01"), relation_interval2 = "contains",
                             label = label, timeline = timeline)
)

head(forest_evolve)


png(filename = "~/TESTE/PRODES/fig_PA_def_evolve.png", width = 6.5, height = 4.5, units = 'in', res = 300)
lucC_plot_bar_events(forest_evolve, custom_palette = TRUE, RGB_color = c("black"), pixel_resolution = 61.006, side_by_side = TRUE)
#lucC_plot_bar_events(forest_holds, custom_palette = FALSE, pixel_resolution = 70, legend_text = "Legend:")
dev.off()

#lucC_plot_bar_events(forest_evolve, custom_palette = FALSE, pixel_resolution = 70, legend_text = "Legend:")

# 4. Remove column 2001 because it' is not used to replace pixels's only support column
#forest_evolve2 <- lucC_remove_columns(data_mtx = forest_evolve, name_columns = c("2007-09-01"))

#lucC_plot_bar_events(forest_evolve2, custom_palette = FALSE, pixel_resolution = 70, legend_text = "Legend:")

message("Prepare image 1 ...\n")
lucC_save_raster_result(raster_obj = rb_sits, data_mtx = as.data.frame(forest_evolve), timeline = timeline, label = label, path_raster_folder = "~/TESTE/PRODES/forest_evolve", as_RasterBrick = FALSE)


# Compute values
measures_defores_evolve <- lucC_result_measures(data_mtx = forest_evolve, pixel_resolution = 61.006)
measures_defores_evolve

# Years       Classes Pixel_number       Area_km2  Cumulative_Sum
# 1   2008 Deforestation        73295  272.784349579   272.784349579
# 2   2009 Deforestation       197998  736.895499664  1009.679849243
# 3   2010 Deforestation       220178  819.443516222  1829.123365465
# 4   2011 Deforestation       244882  911.385184440  2740.508549905
# 5   2012 Deforestation       281847 1048.959009150  3789.467559055
# 6   2013 Deforestation       351521 1308.266967027  5097.734526082
# 7   2014 Deforestation       396955 1477.360140350  6575.094666432
# 8   2015 Deforestation       432196 1608.517699031  8183.612365463
# 9   2016 Deforestation       465124 1731.066891512  9914.679256976
# 10  2017 Deforestation       483091 1797.935251003 11712.614507979
# Relative_Frequency Cumulative_Relative_Frequency
# 1       2.32897914802                 2.32897914802
# 2       6.29146890442                 8.62044805244
# 3       6.99624764107                15.61669569351
# 4       7.78122752882                23.39792322233
# 5       8.95580579755                32.35372901988
# 6      11.16972616264                43.52345518252
# 7      12.61341043320                56.13686561573
# 8      13.73320788399                69.87007349972
# 9      14.77950879655                84.64958229626
# 10     15.35041770374               100.00000000000



#----------------------------
# 3- Forest covnert to deforestation - LUC Calculus
#----------------------------

# create timeline with classified data from SVM method
timeline <- lubridate::as_date(c("2007-09-01", "2008-09-01", "2009-09-01", "2010-09-01", "2011-09-01", "2012-09-01", "2013-09-01", "2014-09-01", "2015-09-01", "2016-09-01", "2017-09-01"))


forest_convert <- NULL

# along of all classes
system.time(
  for(x in 2:length(timeline)){
    t_1 <- timeline[x-1]
    t_2 <- timeline[x]
    cat(paste0(t_1, ", ", t_2, sep = ""), "\n")

    # moves across all classes
      temp <- lucC_pred_convert(raster_obj = rb_sits, raster_class1 = "Forest",
                                time_interval1 = c(t_1,t_1), relation_interval1 = "equals",
                                raster_class2 = "Deforestation",
                                time_interval2 = c(t_2,t_2), relation_interval2 = "equals",
                                label = label, timeline = timeline)

      if (!is.null(temp)) {
        temp <- lucC_remove_columns(data_mtx = temp, name_columns = as.character(t_1))
      } else{
        temp <- temp
      }

      forest_convert <- lucC_merge(forest_convert, temp)
    cat("\n")
  }
)

Forest_Deforestation <- forest_convert
head(Forest_Deforestation)

#Forest_Pasture[ Forest_Pasture == "Pasture" ] <- "Forest_Pasture"
#head(Forest_Pasture)

# plot results
lucC_plot_bar_events(data_mtx = forest_convert,
                           pixel_resolution = 70, custom_palette = FALSE)

# Compute values
measures_Forest_Pasture <- lucC_result_measures(data_mtx = forest_convert, pixel_resolution = 70)
measures_Forest_Pasture




#png(filename = "~/Desktop/fig_TESE/fig_MT_data.png", width = 7.0, height = 4.2, units = 'in', res = 300)
lucC_plot_bar_events2(data_frequency = data2, custom_palette = TRUE,
                      RGB_color = colors_2, pixel_resolution = 231.656,
                      side_by_side = TRUE, column_legend = 3, relabel = FALSE)
#dev.off()


#------------------------------------
library(ggplot2)

#-------------
#-------------
#  with legend angle 45 degrees
#-------------
lucC_plot_bar_events2 <- function(data_tb = NULL, custom_palette = FALSE, RGB_color = NULL, pixel_resolution = 250, relabel = FALSE, original_labels = NULL, new_labels = NULL, side_by_side = FALSE){

  # Ensure if parameters exists
  ensurer::ensure_that(data_tb, !is.null(data_tb),
                       err_desc = "data_tb tibble, file must be defined!\nThis data can be obtained using lucC_plot_maps_events().")
  ensurer::ensure_that(custom_palette, !is.null(custom_palette),
                       err_desc = "custom_palette must be defined, if wants use its own color palette setting! Default is FALSE")
  ensurer::ensure_that(pixel_resolution, !is.null(pixel_resolution),
                       err_desc = "pixel_resolution must be defined! Default is 250 meters on basis of MODIS image")

  input_data <- data_tb
  input_data <- input_data[order(input_data$index),] # order by index

  #mapBar <- data.frame(table(input_data$w, input_data$z))
  mapBar <- data.frame(table(lubridate::year(input_data$end_date), input_data$label))

  # insert own colors palette
  if(custom_palette == TRUE){
    if(is.null(RGB_color) | length(RGB_color) != length(unique(mapBar$Var2))){
      cat("\nIf custom_palette = TRUE, a RGB_color vector with colors must be defined!")
      cat("\nProvide a list of colors with the same length of the number of legend!\n")
    } else {
      my_palette = RGB_color
    }
  } else {
    # more colors
    colour_count = length(unique(mapBar$Var2))
    my_palette = scales::hue_pal()(colour_count)
  }

  original_leg_lab <- levels(droplevels(mapBar$Var2))
  cat("Original legend labels: \n", original_leg_lab, "\n")

  # insert own legend text
  if(relabel == TRUE){
    if(is.null(original_labels) | length(new_labels) != length(unique(mapBar$Var2)) |
       all(original_labels %in% original_leg_lab) == FALSE){
      cat("\nIf relabel = TRUE, a vector with original labels must be defined!")
      cat("\nProvide a list of original labels and new labels with the same length of the legend!\n")
    } else {
      my_original_label = original_labels
      my_new_labels = new_labels
    }
  } else {
    # my legend text
    my_original_label = unique(mapBar$Var2)
    my_new_labels = unique(mapBar$Var2)
  }

  # make side-by-side bar plot
  if (side_by_side == TRUE){
    bar_position = "dodge"
  } else {
    bar_position = "stack"
  }

  g <- ggplot2::ggplot(mapBar,aes(x=mapBar$Var1, y=(mapBar$Freq*(pixel_resolution*pixel_resolution))/(1000*1000), fill=mapBar$Var2))+
    geom_bar(width = 0.7, stat="identity", position = bar_position)+
    theme_bw()+
    #ylab(expression(paste("Area ",km^{2}," = ((pixels number x pixel ", resolution^{2},")/",1000^{2},")"))) +
    ylab(expression(paste("Area (",km^{2},")")))+
    xlab("Time")+
    scale_fill_manual(name="Legend:", values = my_palette, breaks = my_original_label, labels = my_new_labels) + #Legend
    #scale_fill_grey(name = "Legend:", start = 0, end = 0.8) +
    # theme(legend.position = "bottom",
    #       legend.text=element_text(size=11),  ###
    #       legend.key = element_blank())

    guides(fill=guide_legend(ncol=2)) + # number of columns - legend plot

    theme(legend.position = "bottom",
          legend.text=element_text(size=11), ### ### era 11
          axis.text.x=element_text(angle=45, hjust=1, size = 10),
          legend.key = element_blank())


  print(g)

}
