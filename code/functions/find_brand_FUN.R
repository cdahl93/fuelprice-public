###############################################################################

#                           FUNCTION: find_brand                              #

###############################################################################

# DESCRIPTION
# This function finds teh brand of given gas stations by searching for patterns
# in the colum $brand of the given data file.

find_brand <- function(data, 
                       target_brands = c("ARAL","Shell","ESSO","TOTAL","AVIA",
                                         "JET","STAR","Agip","Raiffeisen",
                                         "HEM","OMV","OIL!","BFT"),
                       default = "Sonstige"){
  brand = rep(default, dim(data)[1])
  for(j in 1:length(target_brands)){
    brand[grep(target_brands[j], data$brand, ignore.case = T)] = target_brands[j]
  }
  return(brand)
}