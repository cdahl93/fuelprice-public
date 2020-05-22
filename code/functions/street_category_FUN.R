###############################################################################

#                           FUNCTION: street_category                         #

###############################################################################

# Description
# This function determines the street category (autohof, autobahn, sonstige)
# based on the stations name, brand, street and house number by pattern
# recognition.

street_category <- function(data,
                            default = "Sonstige"){
  # Set all to default category
  street_cat = rep(default, dim(data)[1])
  
  # Index Autohöfe
  autohof_ind = c(grep(pattern = "autohof", x = data$name, ignore.case = T),
                  grep(pattern = "autohof", x = data$brand, ignore.case = T),
                  grep(pattern = "autohof", x = data$street, ignore.case = T),
                  grep(pattern = "autohof", x = data$house_number, ignore.case = T))
  autohof_ind = sort(unique(autohof_ind)) # remove double entries and sort asc.
  
  # Index Autobahn
  autobahn_ind = c(which(data$street == "A"),
                   grep(pattern = "A[0-9]{1,3}", x = data$name, ignore.case = T),
                   grep(pattern = "A[0-9]{1,3}", x = data$street, ignore.case = T),
                   grep(pattern = "A[0-9]{1,3}", x = data$house_number, ignore.case = T),
                   grep(pattern = "autobahn", x = data$name, ignore.case = T),
                   grep(pattern = "autobahn", x = data$brand, ignore.case = T),
                   grep(pattern = "autobahn", x = data$street, ignore.case = T),
                   grep(pattern = "autobahn", x = data$house_number, ignore.case = T),
                   grep(pattern = "BAB [0-9]{1,3}", x = data$name, ignore.case = T),
                   grep(pattern = "BAB [0-9]{1,3}", x = data$street, ignore.case = T),
                   grep(pattern = "BAB [0-9]{1,3}", x = data$house_number, ignore.case = T),
                   grep(pattern = "BAB[0-9]{1,3}", x = data$name, ignore.case = T),
                   grep(pattern = "BAB[0-9]{1,3}", x = data$street, ignore.case = T),
                   grep(pattern = "BAB[0-9]{1,3}", x = data$house_number, ignore.case = T),
                   grep(pattern = "BAB[0-9]{1,3}", x = data$street, ignore.case = T),
                   grep(pattern = "BAT", x = data$name, ignore.case = F),
                   grep(pattern = "BAT", x = data$street, ignore.case = F),
                   grep(pattern = "BAT", x = data$house_number, ignore.case = F))
  autobahn_ind <- sort(unique(autobahn_ind)) # remove double entries and sort asc.
  autobahn_ind <- setdiff(autobahn_ind, autohof_ind) # remove autohof cases from autobahn index
  
  street_cat[autohof_ind] = "Autohof"
  street_cat[autobahn_ind] = "Autobahn"
  
  return(street_cat)
}