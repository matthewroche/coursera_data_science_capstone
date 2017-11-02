#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application
shinyUI(fluidPage(
  
  
  #####################################
  # Application title
  titlePanel("Coursera Data Science Capstone Project"),
  
  
  #####################################
  # Explanation text
  wellPanel(
    p("This Shiny app was created as a submission for the Coursera data science final 'Capstone' project."),
    p("Text entered into the textbox on the left will result in the top four word predictions being displayed on the buttons to the right."),
    p("The top result is found in the left hand button, then the likelihood decreases to the right. Clicking these buttons will add the text to the textbox and create a new prediction."),
    p("A word cloud of all possible predictions, with the likelihood represented by word size, is displayed below the predictions"),
    p("If there are less than four predictions available only these will be displayed."),
    p("A simlpified 'Katz Backoff' model is used. First 6-word Ngrams are searched for matches, then five, then four etc.")
  ),
  
  
  #####################################
  # Sidebar with a input for text
  sidebarLayout(
    sidebarPanel(
      textInput(
        # Input identifier
        "input",
        # Input title
        "Input")
    ),
    
    ###################################
    # Panel for predictions
    mainPanel(
      
      #Panel displayed when data has loaded
      conditionalPanel(
        
        # The condition for this panel to be displayed
        condition = "output.prediction_button_one",
        
        # Everything below is displayed if predictions are present
        # Title
        h3("Next word prediction:"),
        
        # Row of buttons
        fluidRow(
          column(width = 2,
                 uiOutput("prediction_button_one")
          ),
          column(width = 2,
                 uiOutput("prediction_button_two")
          ),
          column(width = 2,
                 uiOutput("prediction_button_three")
          ),
          column(width = 2,
                 uiOutput("prediction_button_four")
          )
        ),
        
        plotOutput("wordcloud")
        
      ),
      
      
      # Panel displayed if data is still loading
      conditionalPanel(
        condition = "!output.prediction_button_one",
        h3("Please wait, the data model is loading..."),
        h4("This can take up to twenty seconds")
      )
    )
  )
))
