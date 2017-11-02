Capstone Project - Text Prediction
========================================================
author: Matthew Roche
date: 02/11/17
autosize: true

Presentation for the final capstone project in the Coursera Data Science specialisation.

Final Shiny App link [here](https://matthew-roche.shinyapps.io/Coursera_Data_Science_Capstone/)

Please click 'Hide Toolbars' below if you are unable to see all the text.

Project Aims
========================================================

The aim of this project was to use text taken from a variety of blogs, news sites and twitter to create an algorithm capable of predicting the next word in a sentance.

This slide deck presents the algorithm I have created and the accompanying app.



Algorithm
========================================================

The raw data is converted into a series of data tables. Each table has a predictor phrase, a count of how often that phrase occured in the text and a prediction. Tables were created with 'predictor' phrases with lengths from one to six words. Only a 10% sample of the entire text corpus was used to create these tables. This limits memory requirements, and has a relatively minor impact on prediction accuracy.

A modified Katz 'backoff' model is used to predict the next word. The input text is first cleaned then ngrams are created up to five words if available. A search is then performed for matching ngrams in the relevant data tables. If a match occurs then the prediction for that phrase is extracted. First we look for matching six-word ngrams, then five, then four etc. If no predictions are found then the commonest words are simply returned in order.


Using The App
========================================================

The app has a variety of functions. Text is entered into the textbox on the left-hand side.

The top four predictions are displayed in buttons on the right-hand side. If less than four predictions are available then only these are displayed. The most likely prediction is on the right,  the least likely on the right.

Clicking the buttons will add the predictions to the text in the input box and create new predictions based on this new input.

A word cloud of the top twenty predictions is displayed below the buttons. Word size is related to their predicted likelihood of being correct. Larger words are more likely.


References
========================================================

Code: 

https://github.com/matthewroche/coursera_data_science_capstone

Shiny App: 

https://matthew-roche.shinyapps.io/Coursera_Data_Science_Capstone/

Quanteda Package Reference:

https://cran.r-project.org/web/packages/quanteda/vignettes/quickstart.html
