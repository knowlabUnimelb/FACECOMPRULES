experiment-base.js
==================

Base experiment code for web experiments

### How does the code work?
Different sections of the experiment call each other in sequence. Currently the order is:  
1. collect demographics information  
2. provide instructions  
3. test instruction comprehension  
4. for each block within the experiment:  
    * display training trials  
    * display test trials  
5. display thank you message and feedback for MTurk users  

### How to run locally for testing (in Chrome)?
1. In a terminal type: python -m SimpleHTTPServer
2. point chrome to: http://localhost:8000/

### Known issues:
1. currently does not work with writing to mySQL server out of the box because permissions need to be configured for submit_data_mysql.php

### Notes for modifying this code
- all locations in experiment.js where the slider is referenced are marked with a comment SLIDER comment.
- all locations in experiment.js where between-subject conditions are referenced are marked with CONDITION comment.
