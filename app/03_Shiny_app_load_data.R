# Shiny_app
# R Script: \03_Shiny_app_load_data.R

# This script has two main functions: 
#  1. Load required libraries using pacman
#  2. Load processed data for Shiny app from “data_processed” folder

# 1. Load required packages and data to run the Shiny app

pacman::p_load(here, tidyverse, janitor, shiny,shinydashboard,plotly)

# 2. Load main data "METRIC_POP_RATES.csv" as .csv from "data_processed" folder

library(readr)
METRICS_POP_RATES <- read_csv("app/data_processed/METRICS_POP_RATES.csv", 
                              col_types = cols(...1 = col_skip(), 
                                               date = col_date(format = "%Y-%m-%d")))

head(METRICS_POP_RATES)
names(METRICS_POP_RATES)
