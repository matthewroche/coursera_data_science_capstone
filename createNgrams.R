#################################################
# Import Libraries
#################################################
library(stringr)
library(LaF)
library(slam)
library(methods)
library(Matrix)
library(quanteda)
library(data.table)
library(plyr)



#################################################
# Set Up
#################################################

set.seed(298)

# Create array of files to include
filesArray <- c("en_US.blogs", "en_US.twitter", "en_US.news")

# ngramSizeArray <- c(1)
ngramSizeArray <- c(1, 2, 3, 4, 5, 6)

# Define size of chunks
numberOfLinesInBatch <- 100000

# Sample fraction
sampleFraction <- 0.1




###########################
# Create Ngrams
###########################

# Loop through ngram sizes

for (ngramSize in ngramSizeArray) {
  
  
  # Create initial empty table
  ngramTable <- data.table()
  
  # Loop through files
  for (file in filesArray) {
    
    # Create connection to file
    con <- file(paste0(file,'.txt'), "r")
    
    # Check size of file
    noLines <- determine_nlines(paste0(file,'.txt'))
    
    # Determine how many loops are required to include all lines
    noLoops <- noLines/numberOfLinesInBatch
    
    # Loop through batches of lines
    for (lineMultiple in 1:noLoops) {
      
      print(paste("Reading file: ", file))
      
      # Print how far through file has been read so far
      lineStart <- (lineMultiple-1) * (numberOfLinesInBatch)
      print(paste("Reading from line: ", lineStart))
      
      # Read next batch of lines
      lines <- readLines(con, numberOfLinesInBatch)
      
      # Lower case
      lines <- char_tolower(lines)
      
      # Create corpus
      print("Creating corpus")
      corpus <- corpus(lines)
      
      # Sample corpus
      corpus <- corpus_sample(corpus, (sampleFraction * numberOfLinesInBatch))
      
      # Create DFM and remove appropriate features
      print(paste("Creating dfm with ngram size: ", ngramSize))
      dfm <- dfm(corpus, tolower = TRUE, ngrams = ngramSize, what="word", remove_numbers = TRUE, remove_punct = TRUE, remove_symbols = TRUE, remove_separators = TRUE, remove_twitter = TRUE, remove_hyphens = TRUE, remove_url = TRUE, concatenator = " ")
      
      
      # Create data table with sums from all documents for one word N-grams
      print("Creating data table")
      dfm <- data.table(string = featnames(dfm), count = colSums(dfm))
      
      
      # Merge previous data with new data table
      print("Merging data frames")
      ngramTable <- data.table(rbind(ngramTable, dfm, fill=T))
      
      # Sum common rows
      print("Summing common rows")
      ngramTable <- as.data.table(ngramTable[, sum(count, na.rm = TRUE),by = string])
      
      # Revert column names (Summing the rows changes the name of the count column)
      colnames(ngramTable) <- c("string", "count")
      
    } # For line
           
  } # For file
  
  # Ensure in format of data table
  ngramTable <- as.data.table(ngramTable)
  
  # Sum common rows
  print("Summing common rows")
  ngramTable <- as.data.table(ngramTable[, sum(count, na.rm = TRUE),by = string])

  
  # For larger ngrams we only want common phrases
  # There is more value in predicting a common word with no associations than a six-word ngram that was written only once
  # We retain ALL smaller ngrams so that we can always predict SOMETHING sensible
  if (ngramSize > 2) {
    print("Filtering for n-grams with sum > 1")
    
    # Filter ngrams to only those that occur more than once
    ngramTable <- ngramTable[V1 > 1]
  }
  
  # Create predictors (ie take all the words in the ngram except the last in order to search for them)
  print("Creating predictors")
  if (ngramSize > 1) {
    ngramTable$predictor <- gsub("\\s*\\w*$", "", ngramTable$string)
  } else {
    ngramTable$predictor <- ngramTable$string
  }
  
  
  # Create predictions (ie take the last word of the ngram, this will be the word we predict)
  print("Creating predictions")
  ngramTable$prediction <- lapply(ngramTable$string, function(x) {tail(strsplit(x,split=" ")[[1]],1)})
  
  # Rename rows
  print("Renaming rows")
  colnames(ngramTable) <- c("string", "count", "predictor", "prediction")
  
  # Remove string row as it is now superfluous
  print("Removing 'string' row")
  ngramTable <- ngramTable[, c("count", "predictor", "prediction")]
  
  # Rename variable
  variableName <- paste0(ngramSize, "WordNgram")
  assign(variableName, ngramTable)
  
  # Set key to enable fast subsetting in data.table.
  print("Setting key")
  setkey(get(variableName), predictor, count)
    
  # Save completed file
  print("Saving completed file")
  fileName <- paste0(variableName, ".Rda")
  save(list=c(variableName), file = fileName)
  # Clean up variables to save memory
  rm(list=ls()[sapply(ls(), function(x) {return(x != "filesArray" && x != "ngramSizeArray" && x != "numberOfLinesInBatch" && x != "sampleFraction")}, simplify = T, USE.NAMES = F)])
  
} # For ngram size


######################################
# Save full ngram data set
######################################

print("Starting to create ngrams.Rda")

# Create empty list
variableList <- c()

# For each ngram size
for (ngramSize in ngramSizeArray) {
  
  # Calculate variable and file name
  variableName <- paste0(ngramSize, "WordNgram")
  fileName <- paste0(variableName, ".Rda")
  
  # Load the file
  print(paste("Loading:", fileName))
  load(fileName)
  
  # Add to variable list
  variableList <- c(variableList, variableName)
}

# Save final file
print("Saving ngrams.Rda")
save(list = variableList, file="ngrams.Rda")