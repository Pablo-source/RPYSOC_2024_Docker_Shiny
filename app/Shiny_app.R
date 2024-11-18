# Shiny_app
# R Script: \Shiny_app.R

# This Shiny app will include three main sections:

# KPI
# Plotly bar charts section
# Plotly line chart section

# Shiny app displaying confirmed, recovered and death COVID cases by countries.

# Shiny app using {tidyverse} for data wrangling,  {leaflet},{plotly} for interactive visualizations
# and {tidygeocoder} to obtain LAT LONG values using API calls.

library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)

ui <- dashboardPage(
  
  dashboardHeader(title = "COVID-19"),
  # Sidebar menu allows us to include new items on the sidebar navigation menu
  dashboardSidebar(
    sidebarMenu(
      # Setting id makes input$tabs give the tabName of currently-selected tab
      id = "tabs",
      menuItem("About", tabName = "about", icon = icon("desktop")),
      menuItem("COVID-19 Dashboard", tabName = "main_tab", icon = icon("map"))
    )
  )
  ,
  dashboardBody(  
    # Start building dashboard content 
    
    # 1. KPIS  at the top of the dashboard:
    # Infobox: Total figures KPI UK
    fluidRow(
      infoBoxOutput("Confirmed_cases_UK", width = 3),
      infoBoxOutput("Recovered_cases_UK", width = 3),
      infoBoxOutput("Death_cases_UK", width = 3),
      infoBoxOutput("Date", width = 3)
    ),
    
    tabItems(  
      tabItem(tabName ="about",h1("About the COVID-19 app"),
              
              fluidRow( box(
                source("Shiny_features/About_tab/about_tab.R", local = T)
                ,width = 12 ))
              
      ),
      
      tabItem(
        # 2. Time slider and title for charts below
        # 2.1 Main title and instructions for time slider
        tabName ="main_tab",
        
        h4("Clik play on the time slider below to start chart animation"),
        
        # 2. TIME SLIDER - Used across all charts in the dashboard 
        fluidRow(       
          box(
            sliderInput(inputId = "Time_Slider",
                        label = "Select Date",
                        min = min(METRICS_POP_RATES$date),
                        max = max(METRICS_POP_RATES$date),
                        value = max(METRICS_POP_RATES$date),
                        width = "100%",
                        timeFormat = "%d-%m-%Y",
                        animate = animationOptions(interval=3000,
                                                   loop = TRUE,
                                                   playButton = h3(c("Play")),
                                                   pauseButton = NULL)
            ),
            class = "slider",
            width = 15
          )
        ),
        
        h2("Covid-19 metrics (Confirmed, Recovered, Death) cases by country"),br(),
        
        # 3. Container with two objects (A Table and dynamic plotly bar chart) 
        #    Secont Tabbed frame with three plotly bar charts  
        # 3-1 Table
        # 3-2 Plotlty bar chart 
        fluidRow(
          box(  
            column(6, dataTableOutput("tableleft")),
            column(6, 
                   
                   # In this section goes the new tabsetPanel() function to support tabbed frames
                   # Then each tab is populated by tabPanel() function
                   tabsetPanel(id = "Threetabs",
                               tabPanel("Confirmed", plotlyOutput("ToptenCONFtab"),value = "confirmed"),
                               tabPanel("Recovered", plotlyOutput("ToptenRECtab"),value = "recovered"),
                               tabPanel("Deaths", plotlyOutput("ToptenDEATHtab"),value = "deaths")),
                   p("Bar plot displaying  confirmed, recovered and death cases by country ranked by total figures")),
            width = 15), 
        ),
        
        # 4. Choose country to display Confirmed, Recovered and Death time series data from drop down menu
        fluidRow(h2("Covid 19 Indicators (Confirmed, Recovered, Deaths) rates by 10,000 population by country")),
        fluidRow(h4("Select country from dropdown menu - Interactive Plotly charts")),
        
        
        # 4.1 Drop down menu to select country for plotly line charts:
        fluidRow(column(4,
                        selectInput("country",
                                    "Country:",
                                    c("All",unique(as.character(METRICS_POP_RATES$country)))))
        ),
        
        # 4.2 Three Plotly line charts for each metric () based on country selected in previous Drop down menu
        
        fluidRow( box(
          column(4, plotlyOutput("Confcountries")),
          column(4, plotlyOutput("Reccountries")),
          column(4, plotlyOutput("Deathscountries")),
          width = 12))
        
      ) # tabItem() function closing parenthesis
    ) # tabItems() function closing parenthesis
  ) # dashboardBody() function closing parenthesis
) # dashboardPage() function closing parenthesis 




# [2-2] SERVER SECTION - Server  - app content (tables, maps, charts)

server <- function(input,output) {
  
  # 2. Dynamic Datasets for KPIS and Charts based on METRICS_POP_RATES dataframe loaded on previous script
  # Dynamic data set for KPIS (current and previous day all indicator (confirmed, recovered, death cases))
  dailyData <- reactive(METRICS_POP_RATES[METRICS_POP_RATES$date == format(input$Time_Slider,"%Y/%m/%d"),]) # KPIs
  prevDay <- reactive(METRICS_POP_RATES[METRICS_POP_RATES$date == format(input$Time_Slider-1,"%Y/%m/%d"),]) # KPIs
  RATESTable <- reactive(METRICS_POP_RATES[METRICS_POP_RATES$date == format(input$Time_Slider,"%Y/%m/%d"),]) # dynamic tables
  PLOTLYcharts <- reactive(METRICS_POP_RATES[METRICS_POP_RATES$date == format(input$Time_Slider,"%Y/%m/%d"),]) # plotly charts
  
  # - FIRST DASHBOARD SECTION - KPIs 
  # KPI 01 - Total confirmed cases - KPI 1-4
  output$Confirmed_cases_UK <- renderValueBox({
    
    prevday_conf <- prevDay()
    prevday_conf2 <- prevday_conf %>%
      select(country,date,Confirmed) %>%
      filter( country == "United Kingdom")
    
    day_conf <- dailyData()
    day_conf2 <- day_conf %>%
      select(country,date,Confirmed) %>%
      filter( country == "United Kingdom")
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(
        round(day_conf2$Confirmed,0), big.mark = ','
      ),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_conf2$Confirmed-prevday_conf2$Confirmed)/
                   prevday_conf2$Confirmed
               )*100
               ,1),"%"
             ,"]")
    ), "Confirmed | % change prev day | UK", icon = icon("list"),
    color = "blue")
    
    
  })
  
  
  # KPI 02: Recovered cases
  output$Recovered_cases_UK <- renderValueBox({
    
    prevday_rec <- prevDay()
    prevday_rec2 <- prevday_rec %>%
      select(country,date,Recovered) %>%
      filter( country == "United Kingdom")
    
    day_rec <- dailyData()
    day_rec2 <- day_rec %>%
      select(country,date,Recovered) %>%
      filter( country == "United Kingdom")
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(
        round(day_rec2$Recovered,0), big.mark = ','
      ),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_rec2$Recovered-prevday_rec2$Recovered)/
                   prevday_rec2$Recovered
               )*100
               ,1),"%"
             ,"]")
    ), "Recovered | % change prev day | UK", icon = icon("check"),
    color = "green")
    
    
  })
  # KPI 03: Death cases 
  output$Death_cases_UK <- renderValueBox({
    
    prevday_death <- prevDay()
    prevday_death2 <- prevday_death %>%
      select(country,date,Deaths) %>%
      filter( country == "United Kingdom")
    
    day_death <- dailyData()
    day_death2 <- day_death %>%
      select(country,date,Deaths) %>%
      filter( country == "United Kingdom")
    
    valueBox(paste0(
      # Main figure displays daily  death cases
      format(
        round(day_death2$Deaths,0), big.mark = ','
      ),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_death2$Deaths-prevday_death2$Deaths)/
                   prevday_death2$Deaths
               )*100
               ,1),"%"
             ,"]")
    ), "Deaths | % change prev day | UK", icon = icon("user-doctor"),
    color = "orange")
  })
  
  # KPI 04: Date
  # Variable: date
  output$Date   <- renderValueBox({
    
    Datebox <- dailyData()
    Datebox2 <- Datebox %>% 
      select(country,date,Confirmed) %>%
      filter( country == "United Kingdom")
    
    valueBox(
      Datebox2$date,
      "Date | Daily cases",
      icon = icon("calendar"),color = "yellow")
    
    
  })
  
  
  # OUTPUT 07   - Table in a new container including two items (item 01-02 TABLE )
  output$tableleft <- renderDataTable({
    
    # Using dynamic time-slider input data set  
    TableLEFT <- RATESTable()
    
    TableLEFT  %>%
      select(country, date, 
             CONFR,
             RECR,
             DEATHR) %>% 
      arrange(desc(CONFR))
    
  })
  
  # OUTPUT 08 - Plotly bar chart in a container including three charts
  #             Metric: Confirmed
  # Indicator: Top 10 countries by number of Confirmed covid19 cases
  # Tabbed bar chart - Plot 01-03
  output$ToptenCONFtab = renderPlotly({
    
    conf_top_cases <- METRICS_POP_RATES  %>%
      select(country,date,Confirmed,CONFR) %>% 
      mutate(Max_date = max(METRICS_POP_RATES$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc(CONFR)) %>% 
      group_by(date) %>% 
      mutate(Confirmed_fmt = round(Confirmed,0)) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_conf <- ggplot(conf_top_cases,
                                     aes(x = reorder(country, + Confirmed_fmt), y = Confirmed_fmt)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "deepskyblue3") +
      geom_text(aes(label = Confirmed_fmt), position = position_dodge(width = 0.9),
                vjust = -6.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Confirmed cases") +
      coord_flip()
    COUNTRIES_flipped_conf
    
    ggplotly(COUNTRIES_flipped_conf)
    
  })
  
  # OUTPUT 09 - Plotly bar chart in a container including three charts 
  #             Metric: Recovered
  # Indicator: Top 10 countries by number of Recovered covid19 cases
  # Tabbed bar chart - Plot 02-03
  
  output$ToptenRECtab = renderPlotly({
    
    rec_top_cases <- METRICS_POP_RATES  %>%
      select(country,date,Recovered,RECR) %>% 
      mutate(Max_date = max(METRICS_POP_RATES$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc(RECR)) %>% 
      group_by(date) %>% 
      mutate(Recovered_fmt = round(Recovered,0)) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_rec <- ggplot(rec_top_cases,
                                    aes(x = reorder(country, + Recovered_fmt), y = Recovered_fmt)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "darkseagreen2") +
      geom_text(aes(label = Recovered_fmt), position = position_dodge(width = 0.9),
                vjust = -6.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Recovered cases") +
      coord_flip()
    COUNTRIES_flipped_rec
    
    ggplotly(COUNTRIES_flipped_rec)
    
  })
  
  # OUTPUT 10 - Plotly bar chart in a container including three charts  
  #             Metric: Death cases
  # Indicator: Top 10 countries by number of Death covid19 cases
  # Tabbed bar chart - Plot 03-03
  
  output$ToptenDEATHtab = renderPlotly({
    
    death_top_cases <- METRICS_POP_RATES  %>%
      select(country,date,Deaths,DEATHR) %>% 
      mutate(Max_date = max(METRICS_POP_RATES$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc(DEATHR)) %>% 
      mutate(Deaths_fmt = round(Deaths,0)) %>% 
      group_by(date) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_death <- ggplot(death_top_cases,
                                      aes(x = reorder(country, + Deaths_fmt), y = Deaths_fmt)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "coral1") +
      geom_text(aes(label = Deaths_fmt), position = position_dodge(width = 0.9),
                vjust = -6.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Death cases") +
      coord_flip()
    COUNTRIES_flipped_death
    
    ggplotly(COUNTRIES_flipped_death)
    
  })
  
  # OUTPUT 11 PLOTLY LINE CHART CONFIRMED CASES BY COUNTRY with DROP DOWN MENU TO CHOOSE COUNTRY TO DISPLAY
  # From UI Section this first plot matches "Confcountries" object
  output$Confcountries = renderPlotly({
    
    conf_line_country <- METRICS_POP_RATES
    
    if (input$country != "All") {
      conf_line_country <- conf_line_country[METRICS_POP_RATES$country == input$country,] 
    }
    # Confirmed cases PLOTLY chart based on select country input$country
    plot_ly(conf_line_country,x = ~date, y = ~CONFR,
            type = 'scatter', mode = 'lines', color = 'blue') %>% 
      layout(title = "Confirmed cases rate x10,000 population")
    
    
  })
  
  
  # OUTPUT 12 PLOTLY LINE CHART RECOVERED CASES BY COUNTRY with DROP DOWN MENU TO CHOOSE COUNTRY TO DISPLAY
  # From UI Section this second plotly line chart matches "Reccountries" object
  output$Reccountries = renderPlotly({
    
    rec_line_country <- METRICS_POP_RATES
    
    if (input$country != "All") {
      rec_line_country <- rec_line_country[METRICS_POP_RATES$country == input$country,] 
    }
    # Confirmed cases PLOTLY chart based on select country input$country
    plot_ly(rec_line_country,x = ~date, y = ~RECR,
            type = 'scatter', mode = 'lines', color = 'green') %>% 
      layout(title = "Recovered cases rate x10,000 population")
    
    
  })
  
  
  # OUTPUT 13 PLOTLY LINE CHART DEATH CASES BY COUNTRY with DROP DOWN MENU TO CHOOSE COUNTRY TO DISPLAY
  # From UI Section this third plotly line chart matches "Deathscountries" object 
  output$Deathscountries = renderPlotly({
    
    death_line_country <- METRICS_POP_RATES
    
    if (input$country != "All") {
      death_line_country <- death_line_country[METRICS_POP_RATES$country == input$country,] 
    }
    # Confirmed cases PLOTLY chart based on select country input$country
    plot_ly(death_line_country,x = ~date, y = ~DEATHR,
            type = 'scatter', mode = 'lines', color = 'coral') %>% 
      layout(title = "Recovered cases rate x10,000 population")
    
    
  })
  
  
  
}

# Launch it
shinyApp(ui = ui,server = server)