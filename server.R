#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#################################################
# Import Libraries
#################################################
library(shiny)
library(stringr)
library(LaF)
library(data.table)
library(wordcloud)
#################################################

variableNameArray <- c("1WordNgram", "2WordNgram", "3WordNgram", "4WordNgram", "5WordNgram", "6WordNgram")

#################################################
# Import Data
#################################################
# setwd("~/Desktop/final/Coursera_Data_Science_Capstone")


  
# If processed files do not yet exist
if (!file.exists('ngrams.Rda')) {
  
  print("Pre-processed files do not yet exist, please run createNgrams.R to create them.")
  
} else {
  
  print("Loading files from local storage")
  
  # Else we must be able to load files
  load("ngrams.Rda")
  
  print("Finished loading required files. Creating data tables")
  
  # Turn data into more efficient data.tables
  for (variableName in variableNameArray) {
    assign(variableName, as.data.table(get(variableName)))
    #Set key on predictor
    setkey(get(variableName), predictor, count)
  }
  
  print("Finished creating data tables")
  
}



# Function to process an input
processInput <- function(string) {
  
  
  ########
  # Set up
  ########
  
  # To lower case
  string <- tolower(string)
  
  # Remove punctuation
  string <- gsub('[[:punct:] ]+',' ',string)
  
  # Remove any white space
  string <- trimws(string, which = "both")
  
  # Create array of words
  inputArray <- strsplit(string, split=" ")[[1]]
  
  # Reverse input
  revInputArray <- rev(inputArray)
  
  # Get number of words
  numberOfWords <- length(inputArray)
  
  # If there is one word or more get the last word
  if (numberOfWords > 0) {
    lastWord <- revInputArray[1]
  } else {
    # Otherwise remove these variables
    if (exists("lastWord")) {rm(lastWord)}
  }
  
  # If there are more than one words get the second to last word
  if (numberOfWords > 1) {
    secondLastWord <- revInputArray[2]
    lastTwoWords <- paste(secondLastWord,lastWord)
  } else {
    # Otherwise remove these variables
    if (exists("secondLastWord")) {rm(secondLastWord)}
    if (exists("lastTwoWords")) {rm(lastTwoWords)}
  }
  
  
  # If there are more than three words get the third to last word
  if (numberOfWords > 2) {
    thirdLastWord <- revInputArray[3]
    lastThreeWords <- paste(thirdLastWord, secondLastWord, lastWord)
  } else {
    # Otherwise remove these variables
    if (exists("thirdLastWord")) {rm(thirdLastWord)}
    if (exists("lastThreeWords")) {rm(lastThreeWords)}
  }
  
  # If there are more than four words get the fourth to last word
  if (numberOfWords > 3) {
    fourthLastWord <- revInputArray[4]
    lastFourWords <- paste(fourthLastWord, thirdLastWord, secondLastWord, lastWord)
  } else {
    if (exists("fourthLastWord")) {rm(fourthLastWord)}
    if (exists("lastFourWords")) {rm(lastFourWords)}
  }
  
  # If there are more than four words get the fourth to last word
  if (numberOfWords > 4) {
    fifthLastWord <- revInputArray[5]
    lastFiveWords <- paste(fifthLastWord, fourthLastWord, thirdLastWord, secondLastWord, lastWord)
  } else {
    # Otherwise remove these variables
    if (exists("fifthLastWord")) {rm(fifthLastWord)}
    if (exists("lastFiveWords")) {rm(lastFiveWords)}
  }
  
  # If there are more than four words get the fourth to last word
  if (numberOfWords > 5) {
    sixthLastWord <- revInputArray[6]
    lastSixWords <- paste(sixthLastWord, fifthLastWord, fourthLastWord, thirdLastWord, secondLastWord, lastWord)
  } else {
    # Otherwise remove these variables
    if (exists("sixthLastWord")) {rm(sixthLastWord)}
    if (exists("lastSixWords")) {rm(lastSixWords)}
  }
  
  
  ###########################
  # Start getting predictions
  ###########################
  
  # If there are three words and there is a matching trigram
    
  print("Processing prediction")
  
  # Array of strings to check related to ngram size
  # I.E. for ngram size 4 we check "lastThreeWords"
  # This is because the fourth word in the ngram will be used as the prediction
  searchStringArray <- c("lastWord", "lastWord", "lastTwoWords", "lastThreeWords", "lastFourWords", "lastFiveWords")
  
  # Loop through the possible ngram sizes
  for (ngramSize in 6:1) {
    
    # If the a suitable string for that ngram size exists
    if (exists(searchStringArray[ngramSize])) {
      
      print(paste("Predicting using ", ngramSize, "word ngrams."))
      
      # Get the appropriate data table
      dataTableVariableName <- variableNameArray[ngramSize]
      
      # Get the appropriate search string
      searchStringVariableName <- searchStringArray[ngramSize]
      
      # Work out if there is a matching predictor
      # Could use like() here to search for word completion
      # See here https://stackoverflow.com/questions/14630335/how-to-select-r-data-table-rows-based-on-substring-match-a-la-sql-like
      
      predictionData <- get(dataTableVariableName)[get(searchStringVariableName)]
      
      if (!is.null(predictionData$prediction[[1]])) {
        return(predictionData)
      }
      
    }
    
  }
          
  # Else (there must be either no words or no prediction)
  # Return the top twenty commonest words
          
  print("Just returning commonest words")
  
  return(tail(get("1WordNgram")[order(get("1WordNgram")$count)], 20))
  
}


#################################################












#################################################
# Define server logic to process input
#################################################
shinyServer(function(input, output, session) {
  
  ###############
  # Create reactive predictions
  ###############
  
  # Get all predictions in table for word cloud
  allCurrentPredictions <- reactive({processInput(input$input)})
  
  # Get top four predictions for buttons as list
  topFourPredictions <- reactive({rev(tail(allCurrentPredictions()$prediction, 4))})
  
  
  ###############
  # Create reactive buttons
  ###############
  
  output$prediction_button_one <- renderUI({
    if (length(topFourPredictions()) > 0) {
      actionButton(
        "add_prediction_one", 
        label = topFourPredictions()[[1]]
        )
    }
  })
  
  output$prediction_button_two <- renderUI({
    if (length(topFourPredictions()) > 1) {
      actionButton(
        "add_prediction_two", 
        label = topFourPredictions()[[2]]
        ) 
    }
  })
  
  output$prediction_button_three <- renderUI({
    if (length(topFourPredictions()) > 2) {
      actionButton(
        "add_prediction_three", 
        label = topFourPredictions()[[3]]
        )
    }
  })
  
  output$prediction_button_four <- renderUI({
    if (length(topFourPredictions()) > 3) {
      actionButton(
        "add_prediction_four", 
        label = topFourPredictions()[[4]]
        )
    }
  })
  
  
  ##############
  # Create actions for buttons
  ##############
  
  observeEvent(input$add_prediction_one, {
    updateTextInput(
      session, 
      "input", 
      value = paste(input$input, topFourPredictions()[[1]])
      )
  })
  
  observeEvent(input$add_prediction_two, {
    updateTextInput(
      session, 
      "input", 
      value = paste(input$input, topFourPredictions()[[2]])
      )
  })
  
  observeEvent(input$add_prediction_three, {
    updateTextInput(
      session, 
      "input", 
      value = paste(input$input, topFourPredictions()[[3]])
      )
  })
  
  observeEvent(input$add_prediction_four, {
    updateTextInput(
      session, 
      "input", 
      value = paste(input$input, topFourPredictions()[[4]])
      )
  })
  
  
  
  ###########
  # Create output for word cloud
  ###########
  output$wordcloud <- renderPlot({
    wordcloud(
      allCurrentPredictions()$prediction, 
      allCurrentPredictions()$count,
      max.words=20
      )
  })
  
})
#################################################
