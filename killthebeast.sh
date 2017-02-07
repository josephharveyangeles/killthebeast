#!/bin/bash
# Suit mask/constants:
SUIT_N=4
SUIT_H=H
SUIT_D=D
SUIT_S=S
SUIT_C=C
CARD_N=13
P_DECK_MASK=()
DECK_MASK=()
# deck
deck=({0..51})
player_deck=()
discard_pile=()
discard_index=0
# move/turn counter
encounter=10
# setup init cards
player_card="x"
beast_card="x"
# player choice (Traverse, Dodge, Quit)
player_move="x"
# constant moves
TRVSE="TRAVERSE"
DDG="DODGE"
QQ="QUIT"
# flags
retain_flag="FALSE"
win_flag="FALSE"
# logs
log_journal=()
log_index=0
function main () {
   init_vars
   display_intro
   pause_wait
   start_game
   end_game
}

function start_game () {
   get_name
   log "The Beast versus ${player_name}"
   initialize_player_deck
   while [[ encounter -gt 0 ]] ; do
     
     check_deck # check if you still have no moves left

     #echo "encounter: ${encounter}" #DEBUG
     log "Remaining turns: ${encounter}"
     
     echo
     get_user_move
     log "player move: ${player_move}"
		
 
     if [[ ${retain_flag} == "TRUE" ]]; then 
        retain_flag="FALSE"		# you shouldn't draw another card	
     else				# if you dodged/traversed 'successfully' during your last turn	
     	draw_player_card		     
     fi

     draw_beast_card # by draw i meant, pick from deck not actually draw/display on screen
                     # just want to lay it out here to avoid confusion in the future
     
	  #echo "beast card: ${beast_card}" #DEBUG
     #echo "card on hand: ${player_card}" #DEBUG
     #echo "deck status: ${deck[@]}" #DEBUG
     #echo "your cards: ${player_deck[@]}" #DEBUG
     #echo "discard_pile: ${discard_pile[@]}" #DEBUG
     

     if [[ "${player_move}" == "${TRVSE}" ]]; then
     		display_drawn_cards
			traverse_operation
     elif [[ "${player_move}" == "${DDG}" ]]; then
 			display_drawn_cards
			dodge_operation
     else
        	 log "${player_name} is a quiter.."
			 quit_game
     fi
     
   done
   # player wins!
   echo
   change_color "blue_green"
   echo -e "\tYou win! Clap clap. You have managed to slay the Dragon, you're legendary! You're more beast than The Beast you motherhugging badass. ${player_name} is now a legendary 'Dragon No More' hero."
   log "${player_name} won! Woot! Nice, this is an achievement! Print this and frame it on your wall. Stare at it every night before going to sleep, you've done a good job."
   echo
	pause_wait
   display_epilogue
   win_flag="TRUE"
}

function display_drawn_cards () {
	display_cards
	echo
	display_vs_cards
	echo
}

function traverse_operation () {
   #echo "TRVSE operation commence" #DEBUG
   if [[ ${beast_card} -gt ${player_card} ]]; then
      display_lose_dialog
      log "${player_name} is dead. so dead.."
      end_game
		display_game_over
      exit 0 # create a function, there are things to do before exiting
   else
     echo "Nice, you have traversed the dragon succesfully.."
     log "${player_name} traversed successfully"
     turn_over
   fi
}

function display_lose_dialog () {
    # TODO should have a seperate prompts on diferrent levels of encounters
    change_color "red"
	 tput bold
		if [[ ${encounter} -ge 1 && ${encounter} -le 2 ]]; then
			echo -e "\tDarn it, you're so close yet so far away.. The dragon managed to shake you off around his neck. The Dragon ate you, your bones are crunchy."
		elif [[ ${encounter} -ge 3 && ${encounter} -le 4 ]]; then
			echo -e "\tClose fight. It's quite impressive, but the Dragon is really just that mighty. The Dragon opened it's wings showing the full breadth of its wingspan, flap them wings and apparently, the mighty Dragon's fire are hotter than the core of a neutron star when at the said stance. You died instantly."
		elif [[ ${encounter} -ge 5 && ${encounter} -le 6 ]]; then
			echo -e "\tThe mighty Dragon hit you with it's tail, while you're on the air, the dragon used fire spin, as you land to the ground, the Dragon stomped your lifeless body flattening it to ground evenly."
		elif [[ ${encounter} -ge 7 && ${encounter} -le 8 ]]; then
			echo -e "\tYou still have no match for the mighty dragon. The dragon bite your head off, spit it out then burn your body to cinders."
 		else
			echo -e "\tYou lose, you're just no match for the fiery dragon. The dragon is yawning with fire. A Flame yawn you can say of some sort." 
		fi
    reset_colors
}

function dodge_operation () {
   #echo "DDG operation commence" #DEBUG
   if [[ ${beast_card} -lt ${player_card} ]]; then
      echo "You tripped over a hot flame, damn, you wasn't able to dogde.."
      log "${player_name} dodge failed."
      discard_cards
      retain_flag="FALSE"
   else
      echo "Cool, graceful dodge. The Dragon is coming in hot, be ready."
      log "${player_name} dodged quite gracefully."
      turn_over
   fi
}

function end_game () {
   pause_wait
   echo
   change_color "yellow"
   echob "Remaining cards on hand: "
   echo
   display_cards_on_hand
   change_color "yellow"
   echob "Remaining cards on Deck:"
   echo
   display_cards_on_deck
   change_color "yellow"
   echob "Discard pile: "
   echo
   display_discard_pile
   if [[ "${win_flag}" == "TRUE" ]]; then
      write_log "JournalOfHeroes.txt"
   else
      write_log "Obituary.txt"
   fi
   pause_wait
}

function write_log () {
  filename=${1}
  echo "---------- Log ------------" > "${filename}"
  for i in "${log_journal[@]}"; do
      echo "${i}" >> "${filename}"
  done
}

function display_cards_on_hand () {
  log "Remaining cards on hand:"
  for i in "${player_deck[@]}"; do
      if [[ ${i} == "x" ]]; then
         continue
      fi
      echo "$(get_card_text ${i})"
      log "$(get_card_text ${i})"
  done
}

function display_cards_on_deck () {
  log "Remaining cards on deck:"
  for i in "${deck[@]}"; do
      if [[ ${i} == "x" ]]; then
         continue
      fi
      echo "$(get_card_text ${i})"
      log "$(get_card_text ${i})"
  done
}

function display_discard_pile () {
  log "Discard pile:"
  for i in "${discard_pile[@]}"; do
      echo "$(get_card_text ${i})"
      log "$(get_card_text ${i})"
  done
}

function display_cards () {
   local p_suit=$( find_suit ${player_card} ) #player suit
   local b_suit=$( find_suit ${beast_card} ) #beast suit
   local p_card=$(convert_card_num "${player_card}")
   local b_card=$(convert_card_num "${beast_card}")
   echo
   change_color "blue"
   #display player card
   if [[ "${p_suit}" == "${SUIT_H}" ]]; then
      display_heart "${p_card}" "Your"
   elif [[ "${p_suit}" == "${SUIT_S}" ]]; then
      display_spade "${p_card}" "Your"
   elif [[ "${p_suit}" == "${SUIT_D}" ]]; then
      display_diamond "${p_card}" "Your"
   elif [[ "${p_suit}" == "${SUIT_C}" ]]; then
      display_club "${p_card}" "Your"
   fi
   change_color "blue"
   #display beast card
   if [[ "${b_suit}" == "${SUIT_H}" ]]; then
      display_heart "${b_card}" "The Beast's"
   elif [[ "${b_suit}" == "${SUIT_S}" ]]; then
      display_spade "${b_card}" "The Beast's"
   elif [[ "${b_suit}" == "${SUIT_D}" ]]; then
      display_diamond "${b_card}" "The Beast's"
   elif [[ "${b_suit}" == "${SUIT_C}" ]]; then
      display_club "${b_card}" "The Beast's"
   fi
}

function display_vs_cards () {
   local p_card_text=$(get_card_text ${player_card})
   local b_card_text=$(get_card_text ${beast_card})
   change_color "blue"
   echob "${p_card_text}"
   change_color "violet"
   echob " --> VERSUS <-- "
   change_color "blue"
   echob "${b_card_text}"
   echo 
   log "${player_name} card: ${p_card_text} versus The Beast's: ${b_card_text}"
}

function check_deck () {
  p_deck_mask=${P_DECK_MASK[@]}
  p_deck=${player_deck[@]}
  if [ "$p_deck_mask" == "$p_deck" ]; then
     change_color "red"
     echo "You have no moves left. you're dead.. you were eaten alive, from anal orifice to head."
     reset_colors
     log "${player_name} has no moves left, he died in battle."
     end_game
     display_game_over
     exit 0 
  fi
  
  # *hypothetically, this could only happen in 1/41 * 1/40 * 1/n-1
  # if the player keeps dodging and somehow the beast's cards is always higher
  # imagine eating a spageti like a couple, player and beast end to end.
  b_deck_mask=${DECK_MASK[@]}
  b_deck=${deck[@]}
  if [ "$b_deck_mask" == "$b_deck" ]; then
     change_color "yellow"
     echo -e "\tYou lose. The beast ate you because of boredom. Dodging away problems was never really a good action. That's what get you killed. But you're lucky, that's for sure. You should have a medal."
     log="${player_name} loses by dodging until no more cards left for The beast to draw, which is pretty interesting, the probabilities of this occurence is pretty low. A medal should be given. You lose, but at least you could sleep at night wondering how lucky you are for this to happen, that's the marvel of the universe."
     reset_colors     
     exit 0 
  fi 
}

function log () {
   entry=${1}
   log_journal[$log_index]=${entry}
   (( log_index++ ))
}

function init_vars () {
  for (( i=0; i<10; i++ )); do
      P_DECK_MASK[$i]="x"
  done 
  for (( i=0; i<52; i++ )); do
      DECK_MASK[$i]="x"
  done
  #echo "PDECK: ${DECK_MASK[@]}" #DEBUG
  #echo "DECK: ${P_DECK_MASK[@]}" #DEBUG
}

function display_intro () {
   clear
   display_banner
   display_prologue
}

function display_banner () {
   change_color "red"
   echo
   echo "██ ▄█▀ ██▓ ██▓     ██▓      ▄▄▄█████▓ ██░ ██ ▓█████    ▄▄▄▄   ▓█████ ▄▄▄        ██████ ▄▄▄█████▓"
   echo "██▄█▒ ▓██▒▓██▒    ▓██▒      ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀   ▓█████▄ ▓█   ▀▒████▄    ▒██    ▒ ▓  ██▒ ▓▒"
   echo "▓███▄░ ▒██▒▒██░    ▒██░      ▒ ▓██░ ▒░▒██▀▀██░▒███    ▒██▒ ▄██▒███  ▒██  ▀█▄  ░ ▓██▄   ▒ ▓██░ ▒░"
   echo "▓██ █▄ ░██░▒██░    ▒██░      ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄  ▒██░█▀  ▒▓█  ▄░██▄▄▄▄██   ▒   ██▒░ ▓██▓ ░"
   echo "▒██▒ █▄░██░░██████▒░██████▒    ▒██▒ ░ ░▓█▒░██▓░▒████▒  ░▓█  ▀█▓░▒████▒▓█   ▓██▒▒██████▒▒  ▒██▒░"
   echo "▒ ▒▒ ▓▒░▓  ░ ▒░▓  ░░ ▒░▓  ░    ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░  ░▒▓███▀▒░░ ▒░ ░▒▒   ▓▒█░▒ ▒▓▒ ▒ ░  ▒ ░░"
   echo "░ ░▒ ▒░ ▒ ░░ ░ ▒  ░░ ░ ▒  ░      ░     ▒ ░▒░ ░ ░ ░  ░  ▒░▒   ░  ░ ░  ░ ▒   ▒▒ ░░ ░▒  ░ ░    ░"
   echo "░ ░░ ░  ▒ ░  ░ ░     ░ ░       ░       ░  ░░ ░   ░      ░    ░    ░    ░   ▒   ░  ░  ░    ░"
   echo "░  ░    ░      ░  ░    ░  ░             ░  ░  ░   ░  ░   ░         ░  ░     ░  ░      ░"
   reset_colors
}

function change_color () {
   local color=${1}
   local color_code=0
   case "${color}" in
     "black") color_code=0 ;;
       "red") color_code=1 ;;
     "green") color_code=2 ;;
    "yellow") color_code=3 ;;
      "blue") color_code=4 ;;
    "violet") color_code=5 ;;
 "bluegreen") color_code=6 ;;
      "gray") color_code=7 ;;
           *) color_code=8 ;;
   esac
   tput setaf "${color_code}"
}

function reset_colors () {
   tput sgr0
}

function display_prologue () {
   echo
   change_color "blue"
   tput bold
   echo "PROLOGUE:"
   reset_colors
   echo -e "\tIn a land far far far away, far away but not too far, far enough that you wouldn't travel there without purpose but close enough that you wouldn't get killed because of tiredness when you went there. There was a land called Peacefulandia. Peacefulandia was once, true to its name, peaceful. Green meadows, lush plains, cold breeze not too cold though, let's just it's just the right breeze, people are nice, there are no bullies, good food. Let's just say it's really a pretty dope place to live."
   pause_wait
   echo;
   echo -e "\tBut, everything changed when the fire nation attacked. I meant, when a huge collossal titan appeared from the sky and broke the wall-no sorry, I meant, when a huge dragon appeared from the sky. Its wingspan stretches along the land, the shadows from its wings cast a shade that covers the whole land making everything pitch black. It was dark that you would think you're inside a black hole, way past the event horizon and closer to singularity, until the dragon vomits fire and lava both at the same time. Suddenly, it was bright again, because of the scorching fire that burns everything, if you look in your far left you could see the sheriff burning while yelling 'Help! Help!'. The dragon laid waste on Peacefulandia, it was now called 'Dragon was here.. xoxo' since it's what was clearly written on the burning ground."
   pause_wait
   echo
   echo -e "\t'Dragon was here.. xoxo'-landia has now become the dragon's lair. But there was once a prophecy, that the town sheriff said on his dying breath, (the same sheriff that you would saw burning a while back, if you're following the narration). He said, 'One day, a young adventurer will encounter this land of ours, and he will defeat the dragon by stabbing the dragon on it's heart but he can only do so when he manages to traverses his way up there by drawing 10 cards on a standard texas holdem deck and comparing it to dragon's card, drawn from the same deck (he might have to help the dragon reading the cards since the dragon's to big), this adventurer who will defeat the dragon will be regarded as a hero and the whole Peacefulandia will call him: Dragon no more hero'"
}

function display_epilogue () {
   clear 
	echo
	change_color "blue"
	echob "Epilogue"
	echo
   echo -e "\tThanks for heroic acts of 'Dragon no more' hero, 'Dragon was here.. xoxo'-landia was now free from The Dragon and was peaceful again, but the former sheriff's son, now the current sheriff decided to not revert back to the original name 'Peacefulandia', 'Dragon-was-here..-xoxo'-landia will be kept as the new name for the town as a reminder that once a mighty beast, in the form of a dragon has laid waste on the town, despite this, a courageous hero was still able to defaut the said dragon by believing in himself and by believing that the beast would draw the wrong card as well."
	echo -e "\tAnd thus, the Age of the Beasts is born. People learned to be courageous and always have a deck of texas holdem cards at hand anytime, they are now hunting dragons and other beasts to challenge them in a game of cards. Perfecting their traversing, dodging and probability skills as well as the most important skill of imagining that you have traversed or dodged the beast by drawing a better card."
	echo -e "\t'Dragon-was-here-xoxo-landia' was peaceful again and yet exciting. Although, people has always believed, especially the sheriff's ancestry, that one day, their beloved town will be once again threatened by a new kind of beast. A beast who's much stronger and mighty than the dragon who does not play silly cards but they weren't afraid. Because they also believed that another hero will emerged from the ashes and will defeat the beast by challenging him to a different game. If there was something the sheriff's bloodline was afraid of, it was that their town would become a concoction of 'Dragon-was-here-xoxo-< insert new beast here >-was-here-.....-landia."
}

function echob () {
   tput bold
   echo -n "${1}"
   tput sgr0
}

function get_name () {
   echo
   echo -en "\tWelcome, young adventurer! What is thy name, of whom who dares to slay the mighty dragon?"
   echo
   change_color "green"
   echob "Your name is? "
   read player_name
   echo
   echo -en "\tVery well "
   change_color "bluegreen"
   echob "$player_name"
   echo ", I wish you the best of luck. May the force be with odds of mass times acceleration ever be in your favor. Long live and prosper."
}

function prompt_user_input () {
   change_color "green"
   echob "Traverse, Dodge, Quit ? ) "
   read player_move
   player_move="${player_move^^}"
}

function get_user_move () {
   get_status_prompt
   prompt_user_input
   while [[ "${player_move}" != "${TRVSE}" && "${player_move}" != "${DDG}" && "${player_move}" != "${QQ}" ]]
   do
      echo "Bloody hell, that's not even in the choices. Goddamnit, aren't you a stupid bonkers."
      prompt_user_input
   done
}

function get_status_prompt () {
   #TODO should display different prompts for different encounters
   change_color "yellow"
	case ${encounter} in
		10) echo "The fiery Dragon is in your path, what would you do?" ;;
		9) echo "The Dragon's tail is also flaming, make your move, quick?" ;;
		8) echo "You are at least halfway the dragon's tail, what are you gonna do?" ;;
		7) echo "You have reached the Dragon's femur, make your move?" ;;
		6) echo "\tSacral region of the Dragon's spine, halfway to the beast but the beast getting angry, what you're gonna do?" ;;
	   5) echo "You have reached the lumbar spine, the Dragon's getting annoyed, take your shot?" ;;
		4) echo "You're still on the back of the Dragon, holding on to real life, the Dragon's getting serious." ;;
		3) echo "Still clinging on the back of the Dragon, the Dragon is aiming for an attack." ;;
	   2) echo "You've reached the thoracic spine, it's too late to back off now, pray for your dear life.." ;;
	   1) echo "At last, you're at his throat but the Dragon is ready to hit you with his tail, this is the final showdown, take your shot?" ;;
           *) echo "The fiery Dragon is in your path, what would you do?" ;;
   esac

   reset_colors
}

function quit_game () {
   echo
   echo "Ohh. You're a quitter! Shame! Shame! Shame!"
   echo -ne "\tVery well, "
   change_color "bluegreen"
   echob "${player_name}"
   echo ". I don't have any interest for the likes of you. Go back to wherever critter cave you came from. Coward."
   end_game
   display_game_over
   exit 0
}

function initialize_player_deck () {
   change_color "yellow"
   echo ; echob "Initializing your deck..." echo ;
   pause_wait
   local index=$(( RANDOM % 52 ))
   local temp="x"
   for (( i=0; i<10; i++ )); do
       temp=${deck[$index]}
       while [[ ${temp} == "x" ]]; do
         index=$(( RANDOM % 52 ))
         temp=${deck[$index]}
       done
       deck[$index]="x" # mark as already used.
       player_deck[$i]=${temp}
   done
   #echo "your cards: ${player_deck[@]}" #DEBUG
}

function draw_player_card () {
   local index=$(( RANDOM % 10 ))
   player_card=${player_deck[$index]}
   #echo "card: ${player_card}" #DEBUG
   while [[ $player_card == "x" ]]; do
      index=$(( RANDOM % 10 ))
      player_card=${player_deck[$index]}
      #echo "dups! new card: ${player_card}"  #DEBUG
   done
   player_deck[$index]="x" # mark as already used
}

function draw_beast_card () {
   local index=$(( RANDOM % 52 ))
   beast_card=${deck[$index]}
   while [[ $beast_card == "x" ]]; do
      index=$(( RANDOM % 52 ))
      beast_card=${deck[$index]}
      #echo "dups! new card: ${beast_card}"  #DEBUG
   done
   deck[$index]="x" # mark as already used
}

function discard_beast_card {
   discard_pile[$discard_index]=${beast_card} # dump to discard pile
   (( discard_index++ ))
}

function discard_cards () {
   discard_pile[$discard_index]=${player_card} # dump to discard pile
   (( discard_index++ ))
   discard_beast_card
}

function turn_over () {
   retain_flag="TRUE"
   discard_beast_card
   (( encounter-- )) # decrement remaining encounter/move/turn
}

function get_card_text () {
   local cards=$(find_suit ${1})
   local cardr=$(convert_card_num ${1})
   if [[ "${cards}" == "${SUIT_H}" ]]; then
      echo "${cardr}♥ - ${cardr} of Heart"
   elif [[ "${cards}" == "${SUIT_S}" ]]; then
      echo "${cardr}♠ - ${cardr} of Spade"
   elif [[ "${cards}" == "${SUIT_D}" ]]; then
      echo "${cardr}♦ - ${cardr} of Diamond"
   elif [[ "${cards}" == "${SUIT_C}" ]]; then
      echo "${cardr}♣ - ${cardr} of Club"
   fi
}

function find_suit () {
   local card=${1}
   if [ ${card} -ge 0 -a ${card} -le 12 ]; then
      echo "C"
   elif [ ${card} -ge 13 -a ${card} -le 25 ]; then
      echo "S"
   elif [ ${card} -ge 26 -a ${card} -le 38 ]; then
      echo "D"
   elif [ ${card} -ge 39 -a ${card} -le 51 ]; then
      echo "H"
   fi
}

function convert_card_num () {
   local n=$(( ${1} % CARD_N ))
   (( n++ ))
   if [[ ${n} -eq 1 ]]; then 
     echo "A"
   elif [[ ${n} -eq 10 ]]; then 
     echo "T"
   elif [[ ${n} -eq 11 ]]; then 
     echo "J"
   elif [[ ${n} -eq 12 ]]; then 
     echo "Q"
   elif [[ ${n} -eq 13 ]]; then 
     echo "K"
   else
     echo $n
   fi
}

function display_spade () {
   tput bold
   echo ".------."
   echo "|$1.--. |"
   echo "| :/\: | ----> ${2}"
   echo -e "| (__) |\t card"
   echo "| '--'$1|"
   echo "\`------'";
   tput sgr0
}

function display_heart () {
   tput bold
   echo ".------.";
   echo "|$1.--. |";
   echo "| (\/) | ----> ${2}";
   echo -e "| :\/: |\t card";
   echo "| '--'$1|";
   echo "\`------'";
   tput sgr0
}

function display_diamond () {
  tput bold
  echo ".------.";
  echo "|$1.--. |";
  echo "| :/\: | ----> ${2}"
  echo -e "| :\/: |\t card";
  echo "| '--'$1|";
  echo "\`------'";
  tput sgr0
}

function display_club () {
	tput bold
   echo ".------.";
   echo "|$1.--. |";
   echo "| :(): | ----> ${2}"
   echo -e "| ()() |\t card";
   echo "| '--'$1|";
   echo "\`------'";
	tput sgr0
}

function display_game_over () {
   #TODO
 	clear
   change_color "red"
   echo
	echo
	echo -e "\t\t ▄▄ •  ▄▄▄· • ▌ ▄ ·. ▄▄▄ .           ▌ ▐·▄▄▄ .▄▄▄  ";
	echo -e "\t\t▐█ ▀ ▪▐█ ▀█ ·██ ▐███▪▀▄.▀·    ▪     ▪█·█▌▀▄.▀·▀▄ █·";
	echo -e "\t\t▄█ ▀█▄▄█▀▀█ ▐█ ▌▐▌▐█·▐▀▀▪▄     ▄█▀▄ ▐█▐█•▐▀▀▪▄▐▀▀▄ ";
	echo -e "\t\t▐█▄▪▐█▐█ ▪▐▌██ ██▌▐█▌▐█▄▄▌    ▐█▌.▐▌ ███ ▐█▄▄▌▐█•█▌";
	echo -e "\t\t·▀▀▀▀  ▀  ▀ ▀▀  █▪▀▀▀ ▀▀▀      ▀█▄▀▪. ▀   ▀▀▀ .▀  ▀";
   echo
	echo
   reset_colors
}

function pause_wait () {
  echo
  read -sp "< ... press any key to continue ... >" -n1 -s
  echo
}


# run main function
main
