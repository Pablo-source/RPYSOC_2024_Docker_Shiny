# Shiny_app

# R Script: Shiny_app.R

# Description
# Shiny app displaying confirmed, recovered and death COVID cases by countries.

# Shiny app using {tidyverse} for data wrangling,  {leaflet},{plotly} for interactive visualizations
# and {tidygeocoder} to obtain LAT LONG values using API calls.

library(shiny)
library(shinydashboard)
library(DT)
library(tidyverse)
library(leaflet)
library(plotly)

## 2.SHINY APP
# In this app, UI and SERVER scripts are both included on the same script "COVID_19_Shiny_app.R" to ease automation

# [1-2] UI SECTION -  User interface - app menus
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
    
    # 1.2 All content from this "map" tab must be enclosed in this tabItems() function:
    tabItems(
      # 1.3 Then individual content of this map tab must be INSIDE this tabItem() function:  
      
      # First tabItem to include the "about"  tab, defined by the first menuItem() function
      #    tabItem(
      #      tabName ="about",
      #       h1("About the COVID-19 app"),
      #     fluidRow(box(source("Shiny_features/About-tab/about_tab.R", local =T),width=11)),
      
      tabItem( 
        
        tabName ="about",
        h1("About the COVID-19 app"),
        
        fluidRow( box(
          source("Shiny_features/About_tab/about_tab.R", local = T)
          ,width = 12 ))
        
      ),
      
      # Then here goes the content of the SECOND tab, defined by the second menuItem() function
      
      tabItem(
        # 1. Building content for map tabName INSIDE the tabItem() function
        # 1.1 Main title for this MAP tab
        tabName ="main_tab",
        h2("World map COVID19 deaths by contry -hover over dots for country info"),
        
        # 2. MAP 
        fluidRow( box(leafletOutput("map"),p("Map displaying COVID-19 confirmed,recovered and deaths cases"),   width = 12 )),
        # 2. Adding content to the map tab
        # Each tab element goes inside a fluidRow() function
        
        # 3. TIME SLIDER - Used across all charts in the dashboard 
        # Input data set: "map_data"
        #     Variables: date > mutate(date = as.Date(date) )
        fluidRow(       
          box(
            sliderInput(inputId = "Time_Slider",
                        label = "Select Date",
                        min = min(map_data$date),
                        max = max(map_data$date),
                        value = max(map_data$date),
                        width = "100%",
                        timeFormat = "%d%m%Y",
                        animate = animationOptions(interval=3000,loop = TRUE)
            ),
            class = "slider",
            width = 15,
          )
        ),
        fluidRow(
          box(
            dataTableOutput("sitreptable"), width = 15)),
        
        # 4. Container with two objects (A Table and dynamic plotly bar chart) 
        #    Secont Tabbed frame with three plotly bar charts  
        # 1-2 Table
        # 2-2 Plotlty bar chart 
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
        
        # 5. Drop down menu to choose country for Plotly Line charts section
        fluidRow(h2("Covid 19 Timeline measures by country")),
        fluidRow(h4("Select country from dropdown menu - Interactive Plotly line charts")),
        
        # 5.1 Menu to select country for Plotly charts
        fluidRow(column(4,
                        selectInput("country",
                                    "Country:",
                                    c("All",
                                      unique(as.character(metric_rates$country)))))
        ),
        
        
        
        
        # 6. Three Plotly line charts
        fluidRow( box(  
          column(4, plotlyOutput("Confcountries")),
          column(4, plotlyOutput("Reccountries")),
          column(4, plotlyOutput("Deathscountries")),
          width =12))
        
        
      ) # tabItem() function closing parenthesis
    ) # tabItems() function closing parenthesis
  ) # dashboardBody() function closing parenthesis
) # dashboardPage() function closing parenthesis 

# [2-2] SERVER SECTION - Server  - app content (tables, maps, charts)

server <- function(input,output) {
  
  # Dynamic data sets
  # Metrics acoss all data sets: confirmed_d, recovered_d, deaths_d
  # 1-3. Dynamic data set for KPIS (current and previous day all indicator (confirmed, recovered, death cases))
  dailyData <- reactive(map_data[map_data$date == format(input$Time_Slider,"%Y/%m/%d"),])
  prevDay <- reactive(map_data[map_data$date == format(input$Time_Slider-1,"%Y/%m/%d"),])
  # 2-3 Dynamic data set to build dynamic tables
  RATESTable <- reactive(metric_rates[metric_rates$date == format(input$Time_Slider,"%Y/%m/%d"),])
  # 3-3 Dynamic data set to build Plotly chart 
  PLOTLYcharts <- reactive(metric_rates[metric_rates$date == format(input$Time_Slider,"%Y/%m/%d"),])
  
  # - FIRST DASHBOARD SECTION - KPIs 
  # KPI 01 - Total confirmed cases - KPI 1-4
  # Daily values and difference between today vs yesterday values
  # Variable: confirmed_d
  output$Confirmed_cases_UK <- renderValueBox({
    
    prevday_conf <- prevDay()
    prevday_conf2 <- prevday_conf %>%
      select(country_map,date,confirmed_d) %>%
      filter( country_map == "UnitedKingdom")
    
    day_conf <- dailyData()
    day_conf2 <- day_conf %>%
      select(country_map,date,confirmed_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(day_conf2$confirmed_d, big.mark = ','),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_conf2$confirmed_d-prevday_conf2$confirmed_d)/
                   prevday_conf2$confirmed_d
               )*100
               ,1),"%"
             ,"]")
    ), "Confirmed | % change prev day | UK", icon = icon("list"),
    color = "blue")
    
    
  })
  
  
  # KPI 02 - Total recovered cases  - KPI 2-4
  # Daily values and difference between today vs yesterday values
  # Variable: recovered_d
  output$Recovered_cases_UK <- renderValueBox({
    
    day_rec <- dailyData()
    day_rec2 <- day_rec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    prevday_rec <- prevDay()
    prevday_rec2 <- prevday_rec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(day_rec2$recovered_d, big.mark = ','),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_rec2$recovered_d-prevday_rec2$recovered_d)/
                   prevday_rec2$recovered_d
               )*100
               ,1),"%"
             ,"]")
    ), "Recovered | % change prev day | UK", icon = icon("check"),
    color = "green")
    
    
  })
  
  # KPI 03 - Total death cases - KPI 3-4
  # Daily values and difference between today vs yesterday values
  # Variable: deaths_d
  
  output$Death_cases_UK <- renderValueBox({
    
    DeathCases <- dailyData()
    DeathCases2 <- DeathCases %>% 
      select(country_map,date,deaths_d) %>% 
      filter( country_map == "UnitedKingdom")
    
    DeathCasesprev <- prevDay() 
    DeathCasesprev2 <- DeathCasesprev %>% 
      select(country_map,date,deaths_d) %>% 
      filter(country_map =="United Kingdom")
    
    valueBox(paste0(
      format(DeathCases2$deaths_d, big.mark = ','),
      paste0("[",
             round(
               (
                 (DeathCases2$deaths_d - DeathCasesprev2$deaths_d)/
                   DeathCasesprev2$deaths_d
               )*100
               ,1),"%"
             ,"]")
    ), "Deaths | % change prev day | UK", icon = icon("user-doctor"),
    color = "orange"
    )
    
    
  })
  
  # KPI 04 - Date - KPI 4-4
  # DATE
  # Variable: date
  output$Date   <- renderValueBox({
    
    Datebox <- dailyData()
    Datebox2 <- Datebox %>% 
      select(country_map,date,recovered_d) %>% 
      filter( country_map == "UnitedKingdom")
    
    valueBox(Datebox2$date,
             "Date | Daily figures",
             icon = icon("calendar"),color = "yellow")
    
  })
  
  # - SECOND DASHBOARD SECTION - Map 
  # Output 05 "MAP"
  output$map = renderLeaflet ({
    
    # This is the new data frame that is modified by "Time_Slider" parameter
    # We input now this dataframe into the LEAFLEFT function
    dataframe <- dailyData()
    
    # Create new palette for map legend 
    pal_sb <- colorNumeric(palette = "YlGnBu",domain = dataframe$deaths_d)      
    
    # If filter date is disables the map is displayed !!
    #   filter(date == input$date[1]) %>%   
    dataframe %>% 
      leaflet() %>% 
      addTiles() %>% 
      setView(lng = -10, lat = 20, zoom = 3) %>% 
      addCircles(lng = ~ long, 
                 lat = ~lat,
                 weight = 5, 
                 radius = ~sqrt(dataframe$deaths_d)*1000,
                 
                 popup = paste0(
                   "<b>Country:  </b>",dataframe$country,' ',dataframe$date,
                   "<br>Confirmed=",dataframe$confirmed_d,
                   "<br>Deaths=",dataframe$deaths_d,
                   "<br>Recovered=",dataframe$recovered_d,
                   sep = " "
                   
                 ),
                 
                 fillColor = "lightblue",
                 highlightOptions = highlightOptions( weight = 10, color = "red", fillColor = "green")
                 
      ) %>% 
      # Add legend to existing map
      addLegend("bottomleft", pal = pal_sb, values = ~deaths_d,
                title = "COVID-19 Deaths",opacity = 1)
  })
  
  # - THIRD DASHBOARD SECTION - Data Table
  # Output 06 "DATA TABLE" 
  # population)*10000
  output$sitreptable <- renderDataTable({
    
    Tabledesc <- RATESTable()
    
    Tabledesc  %>%
      select(country, date, confirmed,recovered,deaths,population,
             conf_7Days_moving_avg,
             rec_7Days_moving_avg, 
             deaths_7Days_moving_avg,
             'conf_x10,000pop_rate',
             'rec_x10,000pop_rate',
             'deaths_x10,000pop_rate') %>% 
      arrange(desc(confirmed))
    
  })
  
  # OUTPUT 07   - Table in new container including two items (item 01-02 TABLE )
  output$tableleft <- renderDataTable({
    
    # Using dynamic time-slider input data set  
    TableLEFT <- RATESTable()
    
    TableLEFT  %>%
      select(country, date, 
             'conf_x10,000pop_rate',
             'rec_x10,000pop_rate',
             'deaths_x10,000pop_rate') %>% 
      arrange(desc('conf_x10,000pop_rate'))
    
  })
  
  # OUTPUT 08 - Plotly bar chart in a container including three charts
  #             Metric: 'conf_x10,000pop_rate'
  # tabbed frame(01-03)
  # Tabbed bar chart - Plot 01-03
  output$ToptenCONFtab = renderPlotly({
    
    conf_top_cases <- metric_rates  %>%
      select(country,date,confirmed) %>% 
      mutate(Max_date = max(metric_rates$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc('conf_x10,000pop_rate')) %>% 
      group_by(date) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_conf <- ggplot(conf_top_cases,
                                     aes(x = reorder(country, +confirmed), y = confirmed)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "deepskyblue3") +
      geom_text(aes(label = confirmed), position = position_dodge(width = 0.9),
                vjust = -6.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Confirmed cases") +
      coord_flip()
    COUNTRIES_flipped_conf
    
    ggplotly(COUNTRIES_flipped_conf)
    
  })
  # Tabbed bar chart - Plot 02-03
  # tabbed frame(02-03)
  output$ToptenRECtab = renderPlotly({
    
    conf_top_cases <- metric_rates  %>%
      select(country,date,recovered) %>% 
      mutate(Max_date = max(metric_rates$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc('conf_x10,000pop_rate')) %>% 
      group_by(date) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_rec <- ggplot(conf_top_cases,
                                    aes(x = reorder(country, + recovered), y = recovered)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "darkseagreen2") +
      geom_text(aes(label = recovered), position = position_dodge(width = 0.9),
                vjust = -0.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Recovered cases") +
      coord_flip()
    COUNTRIES_flipped_rec
    
    ggplotly(COUNTRIES_flipped_rec)
    
  })
  
  # Tabbed bar chart - Plot 03-03
  # tabbed frame(03-03)
  output$ToptenDEATHtab = renderPlotly({
    
    conf_top_cases <- metric_rates  %>%
      select(country,date,deaths) %>% 
      mutate(Max_date = max(metric_rates$date)) %>% 
      mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
      filter(Flag_max_date==1) %>% 
      arrange(desc('conf_x10,000pop_rate')) %>% 
      group_by(date) %>% 
      slice(1:10) %>% 
      ungroup()
    
    COUNTRIES_flipped_death <- ggplot(conf_top_cases,
                                      aes(x = reorder(country, +deaths), y = deaths)) +
      geom_bar(position = 'dodge', stat = 'identity',fill = "coral1") +
      geom_text(aes(label = deaths), position = position_dodge(width = 0.9),
                vjust = -0.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
      ggtitle("Top 10 Countries by COVID-19 Death cases") +
      coord_flip()
    COUNTRIES_flipped_death
    
    ggplotly(COUNTRIES_flipped_death)
    
  })
  # - FOURTH DASHBOARD SECTION - Plotly line charts -Confirmed, Recovered and Death cases
  
  # OUTPUT 08 > Confirmed cases plotly line chart - Country displayed select from UI Drop down menu
  output$Confcountries = renderPlotly({
    
    data_confpl <- metric_rates
    if (input$country != "All") {
      data_confpl <- data_confpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_confpl, x = ~date, y = ~conf_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'blue')%>%
      layout(title="Confirmed cases")
    
    
  })
  
  # OUTPUT 09 > Recovered cases plotly line chart - Country displayed select from UI Drop down menu
  output$Reccountries = renderPlotly({
    
    data_recpl <- metric_rates
    if (input$country != "All") {
      data_recpl <- data_recpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_recpl, x = ~date, y = ~rec_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'red')%>%
      layout(title="Recovered cases")
    
    
  })
  # OUTPUT 10 > Death cases plotly line chart - Country displayed select from UI Drop down menu
  output$Deathscountries = renderPlotly({
    
    data_deathpl <- metric_rates
    if (input$country != "All") {
      data_deathpl <- data_deathpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_deathpl, x = ~date, y = ~deaths_7Days_moving_avg, 
            type = 'scatter', mode = 'lines', color = 'orange')%>%
      layout(title="Deaths")
    
    
  })
  
}

# Launch it
shinyApp(ui = ui,server = server)