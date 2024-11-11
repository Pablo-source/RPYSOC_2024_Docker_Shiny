# Script: renv project setup.R 

## Using {renv} package setup environment for this project
library(renv)

# 1. Initialise environment for this specific project 
# Call renv::init() to start using renv in the current project. This will
## Setup project infrastructure
## Dicover packages and install them into a project library
## Create a lockfile that records the state of the project
renv::init()