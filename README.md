# killthebeast
> a text-based card guessing game written in bash

I was learning bash scripting and thought of making this is a nice way to practice and glue things together.

## About the Game
Kill the Beast is a chance game wherein the player is testing his/her luck in taking down the Beast. The player possesses a great speed but is no match for the Beast. The Beast on the other hand is invincible due to its massive size rendering the players minuscule size and weapons useless. Although the Beast is indomitable, it has a weak spot: the throat. The player must dodge the Beasts attack, traverse the monsters body, then stab the weak spot in order to take down the Beast.

## Mechanics
* There should be 10 encounters in which the player must survive.
* Each encounters are  represented by face down cards from a standard deck (52 cards, ace – king of all suits)
* The player will then be given a card which determines his/her luck in fighting the Beast.
* Once the card has been give, the player will now start the battle with the beast.
* The player will input the command “traverse”, “dodge”, or “quit” in order dictate his/her fate. The player card will be compared to the encounter card and his/her decision will decide what happens:
 * If the player decides to traverse the beast, he/she should have a card higher than the encounter or else he/she will die and the game will end.
 * If the player decides to dodge the beast, the beast should have a card higher than the player or else it will do nothing. The encounter will then be discarded and replaced with another card from the remaining cards (41 cards at the start). This means that the player missed an opportunity to traverse the beast.
 * If the player decides to quit, the game ends.
 * If the player success fully traverses or dodges the beast, the current encounter card will be discarded then the encounters will be decremented.
* When the game ends, all of the remaining cards, encounter cards, and the discard pile will be displayed.
* The battle and all of its information (based from above transactions) should be logged in a text file. If the player wins, the battle should be logged in the JournalOfHeroes.txt. But if the player fails, it should be logged in the Obituary.txt

### Notes
* If the rank of the card is equal, the suits should come in to play. Hearts > Diamonds > Spades > Clubs
* The user input should be case insensitive
* If the input is invalid, it should notify the player then ask for another input.
* The deck should be a regular deck (52 cards, ace - king of all suits)
* There should be no cards repeating.

## Release History
* 2/4/2017 
  * Uploaded to github
* 10/13/2015
  * Completed
  
## Authors
* [**Joseph Harvey Angeles**](https://github.com/josephharveyangeles)
  
  
## License

[![NCSA4](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)
