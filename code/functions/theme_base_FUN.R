###############################################################################

#                          FUNCTION: theme_base_FUN.R                         #

###############################################################################

# DESCRIPTION
# This function defines a basic theme for ggplot, based on 
# ggthemes::theme_fivethirtyeight

# FUNCTION
theme_base <- function(base_size = 12, base_family = "sans") {
  colors <- deframe(ggthemes::ggthemes_data[["fivethirtyeight"]])
  (theme_foundation(base_size = base_size, base_family = base_family)
    + theme(
      line = element_line(colour = "black"),
      rect = element_rect(fill = colors["White"],
                          linetype = 0, colour = NA),
      text = element_text(colour = colors["Dark Gray"]),
      axis.title = element_text(),
      axis.text = element_text(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      legend.background = element_rect(),
      legend.position = "bottom",
      legend.direction = "horizontal",
      legend.box = "vertical",
      panel.grid = element_line(colour = NULL),
      panel.grid.major.x =
        element_line(colour = colors["Medium Gray"]),
      panel.grid.major.y =
        element_blank(),
      panel.grid.minor = element_blank(),
      # unfortunately, can't mimic subtitles TODO!
      plot.title = element_text(hjust = 0, size = rel(1.5), face = "bold"),
      plot.margin = unit(c(1, 1, 1, 1), "lines"),
      strip.background = element_rect()))
}