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
library(dplyr)
#################################################
# Import Data
#################################################
setwd("~/Desktop/final/en_US")

# Create array of files to include
filesArray <- c("en_US.blogs", "en_US.twitter", "en_US.news")

ngamSizeArray <- c(4,5,6)

# Define size of chunks
numberOfLinesInBatch <- 100000

# Loop through ngram sizes

for (ngramSize in ngamSizeArray) {
  
  # Loop through files
  for (file in filesArray) {
    
    ngramTable <- data.table()
    
    # Create connection to file
    con <- file(paste0(file,'.txt'), "r")
    
    # Check size of file
    noLines <- determine_nlines(paste0(file,'.txt'))
    
    # Determine how many loops are required to include all lines
    noLoops <- noLines/numberOfLinesInBatch
    
    # Loop through batches of lines
    for (lineMultiple in 1:noLoops) {
      
      print(paste("Reading file: ", file))
      
      # Print how far through file has been read
      lineStart <- (lineMultiple-1) * (numberOfLinesInBatch)
      print(paste("Reading from line: ", lineStart))
      
      # Read next batch of lines
      lines <- readLines(con, numberOfLinesInBatch)
      
      # Sample lines - *******TESTING ONLY*********
      # lines <- head(lines, 10)
      
      # Lower case
      lines <- char_tolower(lines)
      
      print("Creating corpus")
      
      corpus <- corpus(lines)
      
      print(paste("Creating dfm with ngram size: ", ngramSize))
      
      # Create DFM
      dfm <- dfm(corpus, tolower = TRUE, ngrams = ngramSize, what="fastestword", remove_numbers = TRUE, remove_punct = TRUE, remove_symbols = TRUE, remove_separators = TRUE, remove_twitter = TRUE, remove_hyphens = TRUE, remove_url = TRUE, concatenator = " ")
      
      print("Creating data table")
      
      # Create data frame with sums from all documents for one word N-grams
      dfm <- data.table(word = featnames(dfm), count = colSums(dfm))
      
      print("Merging data frames")
      
      # Merge data frames
      ngramTable <- data.table(rbind(ngramTable, dfm, fill=T))
      
      print("Summing common rows")
      
      # Sum common rows
      ngramTable <- as.data.table(ngramTable[, sum(count, na.rm = TRUE),by = word])
      # oneWordNgram <- as.data.table(aggregate(count~word, data = oneWordNgram, FUN = sum))
      
    } # For line
    
    print("Sorting n-grams by count")
    
    # Sort ngrams by count
    ngramTable <- ngramTable[order(-rank(V1))]
    
    print("Filtering for n-grams with sum > 1")
    
    # Filter ngrams to only those that occur more than once
    ngramTable <- ngramTable[V1 >1]
    
    print("Saving ngrams")
    fileName <- paste0(file, "-ngrams-" , ngramSize, '.Rda')
    save(ngramTable, file=fileName)
    
    rm(ngramTable, dfm, corpus, lines)
    
    
  } # For file
  
} # For ngram size


