# R Script: 02_Metrics_population_rates.R
# Input data file: "\data\METRICS_POP_RATES_DATA_FORMATED.csv"

# Required libraries to be loaded (after installing them using the renv::install() command
# (here, tidyverse, janitor, shiny,shinydashboard,plotly)
library(here)
library(tidyverse)
library(janitor)
library(shiny)
library(shinydashboard)

# 1. Input file "METRICS_POP_RATES_DATA_FORMATED.csv"

app_data_prep  <-read.table(here("Shiny_app","data", "METRICS_POP_RATES_DATA_FORMATED.csv"),
                            header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
str(app_data_prep)

# 2. Apply several calculations

# 2.1 Transform initial date variable into a standard R date using as.Date() function.
app_date_fmt <- app_data_prep %>% select(!c("x")) %>% mutate(date = as.Date(date) )
names(app_date_fmt)

app_data_sorted <- app_date_fmt %>% select(country,date,confirmed,recovered,deaths,population) %>% 
  arrange(country,date)
app_data_sorted

# 2.2 Apply several calculations

# 2.2.1 Compute 7days rolling average

library(zoo) # {zoo} library required to use rollmean() function to compute rolling average 

METRICS_RATES_prep <- app_data_sorted %>%
  select(country,date,confirmed,recovered,deaths,population) %>% 
  mutate(
    Confirmed_7DMA = rollmean(confirmed, k = 7, fill = NA),
    Recovered_7DMA = rollmean(recovered, k = 7, fill = NA),
    Deaths_7DMA = rollmean(deaths, k = 7, fill = NA)
  )
METRICS_RATES_prep
head(METRICS_RATES_prep)

METRICS_RATES <- METRICS_RATES_prep %>% na.omit()
head(METRICS_RATES)

# rm(METRICS_POP_RATES)

# 2.2.2 Then we can compute the daily population rates based on these metrics 
METRICS_POP_RATES_calc <- METRICS_RATES %>% 
  select(country,date,Confirmed = Confirmed_7DMA,
         Recovered = Recovered_7DMA,
         Deaths = Deaths_7DMA,
         date, population) %>% 
  mutate(
    CONFR =ceiling(((Confirmed/population)*10000)),
    RECR = ceiling(((Recovered/population)*10000)),
    DEATHR =ceiling(((Deaths/population)*10000))
  )
METRICS_POP_RATES_calc

METRICS_RATES_DATA_final <- METRICS_POP_RATES_calc

rm(list=ls()[! ls() %in% c("METRICS_RATES_DATA_final")])

# 3. Save final data set used for Shiny app in a dedicated \data_processed folder  
# First I check whether this \data_processed sub-folder exists, if not I create it.
if(!dir.exists(here("Shiny_app","data_processed")))
   {dir.create(here("Shiny_app","data_processed"))}

write.csv(METRICS_RATES_DATA_final,here("Shiny_app","data_processed","METRICS_POP_RATES.csv"), row.names = TRUE)

