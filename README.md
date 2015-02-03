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

###What to do?
To launch a test server that will mimic the actual platform45, run ```rake server```. 
Running ```rake test_game``` will then start a game against the local server which you should have started ;) 
has been started. 
To run specs, just run ```rake spec```.

To launch a game against the actual platform45 battleship just run 
```ruby launch.rb -h http://battle.platform45.com/```
