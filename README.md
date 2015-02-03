###What!?!
This is my attempt at writing a battleships artificial intelligence agent for the platform 45 battle ships challenge. 
Specifications for the challenge are available [here](http://battle.platform45.com/).
This agent is okayish. The main problem with the game is that there are nefarious little ships called patrol boats which
are only one square in size. Lets just say that they are pretty difficult to track down.

###How?
The agent works by counting how many ships can be legally placed over each square. The square which can fit the highest
ammount of ships is the one which is chosen. There is a score weighting so that recently hit areas are prioritised for
shooting.

###Requirements
This project requires a ruby version greater than 2.0.0.
Also run ```bundle install``` for moar gems!

###How to Play?
A default server that plays randomly has been provided.
The server is a sinartra HTTP JSON server and can be started by running ```./bin/server```

Agent can play locally, again the random local server by running ./bin/p45battleships
To play against platform45s server, run ```./bin/p45battleships -h http://battle.platform45.com/```
To play more than once, run ```./bin/p45battleships -r times_to_run```
