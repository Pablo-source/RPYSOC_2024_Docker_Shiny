# RPYSOC_2024 Docker Shiny

Deploying a Shiny app with Docker in a Raspberry pi. This project describes how to create a Shiny app that is Deployed inside a Docker Container running on a Raspbeery pi.

The aim of this project is to show a small example on how we can create Shiny apps in R and deploying it in Docker to share it and Manage using Docker containers. 

# Main topics covered in this presentation

In this project, I want to show a small example that can be useful when deploying R code in a cloud computing environment, now that most of the platforms we use to create and deploy apps in the NHS are migrated to the cloud. 

The advantage of using cloud services, it that they allow us run code workflows on a regular schedule,  and Docker complement it in several ways by allowing us to schedule a container that runs on a regular schedule that we setup. Also Dockerfile allows us to configure the content of the packages and applications running, so we can always rely on its behaviour and expected output. 

Below are the five main topics I will cover in my presentation:

- What is Docker
- Design and build your shiny app
- Create a Dockerfile
- Build the Docker image from Dockerfile previously created
- Deploy your Shiny app to a Docker container (using the Terminal)

Each of them will be explained in detail in the presentation slides I will present in the RPYSOC_2024 Conference. 
Also, before the conference I will make available my salides in this Repo.

One key element is the Dockerfile we will create. It is a text file that list instructions for the Docker to follow when building a container image. The Dockerfile contains the steps required to be executed to build the application image.


# Docker online resources 

This is a list of Docker related websites to start building apps using Docker

- Docker website
Docker helps developers build, share, run and verify applications anywhere.
<https://www.docker.com/>

- Docker Hub
Docker Hub is the world’s easiest way to create, manage, and deliver your team’s container applications
<https://hub.docker.com/>

- Install Docker Desktop 
<https://docs.docker.com/desktop/setup/install/linux/debian/>

- Install Docker Desktop on Windows
<https://docs.docker.com/desktop/setup/install/windows-install/>

# Docker images tailored to work with R and RStudio

- Docker Container for R Environment
The Rocker Project 
<https://rocker-project.org/>

- rocker image
<https://hub.docker.com/u/rocker/>

- rocker/rstudio
<https://hub.docker.com/r/rocker/rstudio>

- This is the r-base repository docker image
<https://hub.docker.com/r/rocker/r-base>

![03_rocker_r_base_image](https://github.com/user-attachments/assets/31b4c484-a1d1-4f6f-b15b-f2cb940188b3)

This is the command to pull the above rocker/r-base image: 
![05_docker_pull_r_base_image](https://github.com/user-attachments/assets/3b12718a-4ff9-4849-921a-aeebb81b495a)

Sometimes you might encounter this error when pulling a Docker image: 
![06_permission_denied_error](https://github.com/user-attachments/assets/b0cea689-6fb9-40a4-829d-142417c9c9c0)

Follow the steps detailed on this website to solve it: Method 3: Enable Non-Root User Access: <https://phoenixnap.com/kb/docker-permission-denied>
![07_permission_granted_fix](https://github.com/user-attachments/assets/2bad94e3-24f4-4c0e-8163-258bcf088f68)

Then if we type in the terminal **> docker run -it –rm rocker/r-base** and we obtain this output below: 
![08_Runnig_R_inside_a_Container](https://github.com/user-attachments/assets/9c8aaef8-d1d0-412c-b284-2546937db0b7)

This indicates that we are running R inside a Docker container: where the Terminal has turned into an R console. 

The next step will be to build our Dockerfile, and we use it to instruct Docker how to build our new image. A dockerfile is a text file that must be called “Dockerfile.txt” and it should be located in the project folder directory. 


# Shiny app designed for this talk
This is the basic shiny app I have prepared for this talk. All its scripts and related output and input files can be found inside the **Shiny_app** folder. It runsinside a Docker container. It shows how to use Plotly, ggpplot and standard tidyverse packages using a standard bootstrap grid layout.

![Docker_shiny_app_KPI_section](https://github.com/user-attachments/assets/98f867f7-772c-4c31-80b2-e65c061a8e11)

This image below show the running app including all three main sections: KPIs at the top, dynamic table and plotly line charts and drop down menu section displaying specific confirmed, recovered and death rates by 10,000 population: 

![COVID_19_final_app_docker_browser](https://github.com/user-attachments/assets/e8b62dc4-a7e1-49f8-9952-f35231d7e9d9)


# A more advanced Shiny app with extra features 

In the link below, you will find a fully built Shiny app that has been tailored to run as an isolated environment using {renv} and you can download and run on your machine following the steps below, it uses extra packages such as {laflet} to display **interactive maps** and **APIs** to obtain some live data such as lat and long country values: 

**Shiny app with extra features:**<https://github.com/Pablo-source/Basic-Shiny-app>


*Just leave some time for the API's to load the data, it will take just one minute of preprocessing until the enhanced Shiny app is displayed on your screen replicating these instructions below:*

To run this Shiny-app-using-COVID-data app locally, please follow these three steps below:

1-3. Clone Shiny-app-using-COVID-data repo using git on you IDE or your terminal using local Clone HTTPS option https://github.com/Pablo-source/Basic-Shiny-app.git

git clone https://github.com/Pablo-source/Basic-Shiny-app.git

Navigate to the cloned repo, then open Rproject by clicking on the Basic-Shiny-app.Rproj file. This will display the Shiny app files on your "Files" tab in RStudio.

2-3. Run renv::restore() in a new Rscript. The first time the app finshed running, I captured its final state using renv::snapshot() To ensure all required packages are loaded, we reinstall exact packages declared in the project lockfile renv.lock. Then we run renv::restore() to ensure we have all required packages loaded and ready in our R environment.

renv::restore()

If prompted, after running restore() function, choose "1: Activate the project and use the project library." from menu displayed in the R Console.

In the next step when using app_launch_TRIGGER.R script, we will have all required packages for the app loaded by the renv::restore() command.

3-3. Open “app_launch_TRIGGER.R script”

Then press "Source" button in RStudio to trigger the Shiny app.
This script triggers another script called "app_launch.R" containing runAPP() Shiny function to start the Shiny app.

## Previous talks

Find below the materials from RPYSOC 2023 Conference
  
**NHS-R/NHS.pycom Conference 2023** - *Create Quarto website using RStudio and GitHub*

-  Create Quarto website using RStudio and GitHub
Quarto presentation slides script:

<https://github.com/Pablo-source/Pablo-source.github.io/blob/main/NHS_R_Pycom_2023.qmd>

- Quarto Presentation slides available on GitHub pages:
  
<https://pablo-source.github.io/NHS_R_Pycom_2023.html#/title-slide>

- Adhoc Quarto Website created for the RPYSOC 2023 presentation
  
<https://github.com/Pablo-tester/Pablo-tester.github.io>

My *GitHub main website* designed with *Quarto*
Landing page: <https://pablo-source.github.io/about.html>
Post designing maps using OMS package: <https://pablo-source.github.io/City_maps.html>

## References

- statworkx - How to dockerize shinyapps -  <https://www.statworx.com/en/content-hub/blog/how-to-dockerize-shinyapps/>
  
- statworkx - Running your r scripts in docker -  <https://www.statworx.com/en/content-hub/blog/running-your-r-script-in-docker/>
