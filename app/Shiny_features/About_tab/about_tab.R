# about_tab.R
# THIS IS THE FINAL ABOUT TAB CONTENT PLACED INTO A SINGLE FILE  

fluidPage ( 
  title = div("ABOUT",style ="padding-right:10px",class="h3"),
    fluidRow( 
      box(
                     column(6,
                               h3("This dashboard describes latest daily data on Covid-19 new, recovered cases and deaths 
                               COVID-19 deaths are defined as patients died of covid as primary diagnosis, COVID-19 recovered 
                               patients are defined as patients recovered from it although they might present health complications
                               from the disease. And COVID-19 New cases are patients diaganosed with COVID-19")
                              ),    
                     column(6,
                              h3("Original data to populate this Shiny dashboard can be found in the CSSEGISandData main GitHub website.
                                <https://github.com/CSSEGISandData>.The set of three specific files used on this Shiny Dashboard, 
                                can be found found under the  archived_time_series folder: 
                                <https://github.com/CSSEGISandData/COVID-19/tree/master/archived_data/archived_time_series>
                                
                                I have read the data directly into R with an ad hoc function DownloadCOVIDData() using download.file() function with specific 
                                URL address for each of the three individual files, this function used the 'Raw' path provided on the GitHub repo location of 
                                each of the invidual input files: 
                                
                                These are the three input files read into R directly from the “archived_time_series” folder of the CSSEGISandData/COVID-19 repository:  
                                    'time_series_19-covid-Confirmed_archived_0325.csv' 
                                    'time_series_19-covid-Deaths_archived_0325.csv'   
                                    'time_series_19-covid-Recovered_archived_0325.csv'
                                "  
                              )
                              ),
                            width=15
                            )
      
    ),
    fluidRow(   
     box(
                    column(6,
                             h3("
                                This is an example of the path for COVID-19 Cofirmed cases  file: 

1-2. First I located the specific file in the 'archived_fime_series' folder:
https://github.com/CSSEGISandData/COVID-19/blob/master/archived_data/archived_time_series/time_series_19-covid-Confirmed_archived_0325.csv

2-2. Then I obtained the final URL using the “Raw” button. This allows the the download.file() function to download the file directly from the original URL location to my local machine
'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_19-covid-Confirmed_archived_0325.csv',

                              The Shiny app is structured into strong three sections: KPIs, Leaflet Map, Tables and Plotly charts")
                              ), 
                    column(6,
                           h3("The frst two tabs display grographical information alllowing usert to hover 
                              over country pop-up circle shapes to display 
                               tooltips on specific metircs for each country. Daily figures for each country are 
                               animated every five seconds")
                              ),
                             width=15
                            )
      ),
  fluidRow(   
    box(
      column(6,
             h3("The details of the Shiny R scripts can be cloned from this Github repository")
      ), 
      column(6,
             h3("Pablo-source, on this URL https://github.com/Pablo-source/Shiny-app-using-COVID-data/tree/main")
      ),
      width=15
    )
  )
)


