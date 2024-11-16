# 01_load_app_data.R
# Input data file: "\data\METRICS_POP_RATES_DATA_FORMATED.csv"


# Required libraries to be loaded (after installing them using the renv::install() command
# (here, tidyverse, janitor, shiny,shinydashboard,plotly)
library(here)
library(tidyverse)
library(janitor)
library(shiny)
library(shinydashboard)

# 1. Input file "METRICS_POP_RATES_DATA_FORMATED.csv"
here()
app_data_prep  <-read.table(here("Shiny_app","data", "METRICS_POP_RATES_DATA_FORMATED.csv"),
                            header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
str(app_data_prep)

# 2. Apply several calculations

# 2.1 Transform initial date variable into a standard R date using as.Date() function.
app_date_fmt <- app_data_prep %>% select(!c("x")) %>% mutate(date = as.Date(date) )
names(app_date_fmt)

#[1] "country"                 "date"                    "confirmed"               "recovered"               "deaths"                 
#[6] "population"              "conf_7days_moving_avg"   "rec_7days_moving_avg"    "deaths_7days_moving_avg" "conf_x10_000pop_rate"   
#[11] "rec_x10_000pop_rate"     "deaths_x10_000pop_rate" 

app_data_sorted <- app_date_fmt %>% select(country,date,confirmed,recovered,deaths,population) %>% 
  arrange(country,date)
app_data_sorted

# 2.2 Apply several calculations

# 2.2.1 Compute 7days rolling average

# 2.2.2 Compute population rates (see # R Script: \R\02_Covid_metrics_population_rates.R" 
# from "Basic-Shiny-app" project)  for detals

METRICS_POP_RATES <- app_data_sorted %>% 
  select(country,date,Confirmed = confirmed,
         Recovered = recovered,
         Deaths = deaths,date, population) %>% 
  mutate(
    CONFR =ceiling(((Confirmed/population)*10000)),
    RECR = ceiling(((Recovered/population)*10000)),
    DEATHR =ceiling(((Deaths/population)*10000))
  )

METRICS_POP_RATES

## Remove decimals from Confirmed, recovered and Deaths cases, declare them as integer


