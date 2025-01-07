library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(stringdist)

## load data
data_lv0 <- read_csv("/crc_tissue_cls_origin_lv0.csv")
data_CEM <- read_csv("/crc_tissue_cls_CEM.csv")
data_SEM <- read_csv("/crc_tissue_cls_SEM.csv")

## clean data
n <- 60   ## TCGA 60 strings for matching
get_first_n_chars <- function(x, n) {
  substr(x, 1, n)
}
select_file <- get_first_n_chars(data_lv0$...1, n) # lv0: 330  lv1: 1268
matched_rows <- data_CEM[grepl(paste(select_file, collapse = "|"), data_CEM$...1), ]

## construct plot dataframe
# data_without_filename <- data_CEM[, -1]
data_without_filename <- matched_rows[, -1]
mean_proportions <- colMeans(data_without_filename)
plot_df <- data.frame(
  tissue_type = names(mean_proportions),
  mean_proportion = mean_proportions
)

plt <- ggplot(plot_df) +
  # Make custom panel grid
  geom_hline(
    aes(yintercept = y), 
    data.frame(y = c(0:3) * 30),
    color = "lightgrey"
  ) + 
  # Add bars to represent the mean_proportion
  # str_wrap(region, 5) wraps the text so each line has at most 5 characters
  geom_col(
    aes(
      x = reorder(str_wrap(tissue_type, 5), mean_proportion),
      y = mean_proportion,
      fill = mean_proportion
    ),
    position = "dodge2",
    show.legend = TRUE,
    alpha = .9
  ) +
  geom_segment(
    aes(
      x = reorder(str_wrap(tissue_type, 5), mean_proportion),
      y = 0,
      xend = reorder(str_wrap(tissue_type, 5), mean_proportion),
      yend = 90
    ),
    linetype = "dashed",
    color = "gray12"
  ) + 
  coord_polar()

# plt

plt <- plt +
  annotate(
    x = 9.7, 
    y = 31, 
    label = "30", 
    geom = "text", 
    color = "gray12", 
  ) +
  annotate(
    x = 9.7, 
    y =61, 
    label = "60", 
    geom = "text", 
    color = "gray12", 
  ) +
  annotate(
    x = 9.7,
    y =91,
    label = "90",
    geom = "text",
    color = "gray12",
  ) +
  scale_y_continuous(
    limits = c(-20, 95),
    expand = c(0, 0),
    breaks = c(0, 30, 60, 90)
  ) + 
  scale_fill_gradientn(
    "Tissue ratio (%)",
     colours = c( "#6C5B7B","#C06C84","#F67280","#F8B195")
  ) +
  guides(
    fill = guide_colorsteps(
      barwidth = 15, barheight = .5, title.position = "top", title.hjust = .5
    )
  ) +
  theme(
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(color = "gray12", size = 12),
    legend.position = "bottom",
  )

plt <- plt + 
  theme(
    text = element_text(color = "gray12"),
    panel.background = element_rect(fill = "white", color = "white"),
    panel.grid = element_blank(),
    panel.grid.major.x = element_blank()
  )




