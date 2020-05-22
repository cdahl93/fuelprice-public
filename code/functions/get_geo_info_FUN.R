###############################################################################

#                       FUNCTION: get_geo_info_FUN.R                          #

###############################################################################

# DESCRIPTION
# This function returns geographic information based on GPS coordinates.
# Returned informations are:
#   1   bl_kz
#   2   bl_name
#   3   kreis_kz
#   4   kreis_name
#   5   gemeinde_kz
#   6   gemeinde_name

# FUNCTION
get_geo_info = function(in.spat){
  out = vector(mode="character", length=6)
  out[1] = as.character(over(in.spat, laender)$AGS)
  out[2] = as.character(over(in.spat, laender)$GEN)
  out[3] = as.character(over(in.spat, kreise)$AGS)
  out[4] = as.character(over(in.spat, kreise)$GEN)
  out[5] = as.character(over(in.spat, gemeinden)$AGS)
  out[6] = as.character(over(in.spat, gemeinden)$GEN)
  return(out)
}