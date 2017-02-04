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
dodge_flag="FALSE"
win_flag="FALSE"
# logs
log_journal=()
log_index=0
function main () {
   init_vars
   display_intro
   wait
   start_game
   end_game
}

function start_game () {
   get_name
   log "Beast versus ${player_name}"
   initialize_player_deck
   while [[ encounter -gt 0 ]] ; do
     
     check_deck # check if you still have no moves left

     echo "encounter: ${encounter}" #DEBUG
     log "Remaining turns: ${encounter}"
     
     echo
     get_user_move
     log "player move: ${player_move}"
      
     if [[ ${dodge_flag} == "FALSE" ]]; then 
     	draw_player_card		     
     else				# if you dodged during your last turn	
        dodge_flag="FALSE"		# you shouldn't draw another card	
     fi

     draw_beast_card
     echo "beast card: ${beast_card}" #DEBUG
     echo "card on hand: ${player_card}" #DEBUG
     echo "deck status: ${deck[@]}" #DEBUG
     echo "your cards: ${player_deck[@]}" #DEBUG
     echo "discard_pile: ${discard_pile[@]}" #DEBUG
     
     display_cards
     display_vs_cards
     
     if [[ "${player_move}" == "${TRVSE}" ]]; then
	traverse_operation
     elif [[ "${player_move}" == "${DDG}" ]]; then
	dodge_operation
     else
        log "${player_name} is a quiter.."
	quit_game
     fi
   done
   echo "You win! Clap clap. You have managed to slay the Dragon, you're legendary! You're more beast than The Beast you motherhugging badass."
   log "${player_name} won! Woot! Nice, this is an achievement! Print this and frame it on your wall. Stare at it every night before going to sleep, you've done a good job."
   win_flag="TRUE"
}

function traverse_operation () {
   echo "TRVSE operation commence" #DEBUG
   # should also display cards here
   if [[ ${beast_card} -gt ${player_card} ]]; then
      echo "you lose.."
      log "${player_name} is dead. so dead.."
      end_game
      exit 0 # create a function, there are things to do before exiting
   else
     echo "you have traversed the dragon succesfully"
     log "${player_name} traversed successfully"
     turn_over
   fi
}

function dodge_operation () {
   echo "DDG operation commence" #DEBUG
   if [[ ${beast_card} -lt ${player_card} ]]; then
      echo "Your dodge failed. You lost a turn.."
      log "${player_name} dodge failed."
      discard_beast_card
      dodge_flag="TRUE"
   else
      echo "you have managed to dodge the beast attacks."
      log "${player_name} dodged quite gracefully."
      turn_over
   fi
}

function end_game () {
   #TODO check win_flag write to file
   echob "Remaining cards on hand: "
   echo
   display_cards_on_hand
   echob "Remaining cards on Deck:"
   echo
   display_cards_on_deck
   echob "Discard pile: "
   echo
   display_discard_pile
}

function display_cards_on_hand () {
  for i in "${player_deck[@]}"; do
      if [[ ${i} == "x" ]]; then
         continue
      fi
      echo "$(get_card_text ${i})"
  done
}

function display_cards_on_deck () {
  for i in "${deck[@]}"; do
      if [[ ${i} == "x" ]]; then
         continue
      fi
      echo "$(get_card_text ${i})"
  done
}

function display_discard_pile () {
  for i in "${discard_pile[@]}"; do
      echo "$(get_card_text ${i})"
  done
}

function display_cards () {
   local p_suit=$( find_suit ${player_card} ) #player suit
   local b_suit=$( find_suit ${beast_card} ) #beast suit
   local p_card=$(convert_card_num "${player_card}")
   local b_card=$(convert_card_num "${beast_card}")
   echo
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
   echo -n "${p_card_text}"
   echob " --> VERSUS <-- "
   echo "${b_card_text}"
   log "${player_name} card: ${p_card_text} versus The Beast's: ${b_card_text}"
}

function check_deck () {
  p_deck_mask=${P_DECK_MASK[@]}
  p_deck=${player_deck[@]}
  if [ "$p_deck_mask" == "$p_deck" ]; then
     echo "you have no moves left. you're dead.. you were eaten alive, from anal orifice to head."
     log "${player_name} has no moves left, he died in battle."
     end_game
     exit 0 # still do some logging
  fi
  
  # approximately, this could only happen in 1/41 * 1/40 *1/n-1
  # if the player keeps dodging and somehow the beast's cards is always higher
  # imagine eating a spageti like a couple, player and beast end to end.
  b_deck_mask=${DECK_MASK[@]}
  b_deck=${deck[@]}
  if [ "$b_deck_mask" == "$b_deck" ]; then
     echo "You lose. The beast ate you because of boredom. Dodging away problems was never really a good action. That's what get you killed. But you're lucky, that's for sure. You should have a medal."
     log="${player_name} loses by dodging until no more cards left for The beast to draw, which is pretty interesting, the probabilities of this occurence is pretty low. A medal should be given. You lose, but at least you could sleep at night wondering how lucky you are for this to happen, that's the marvel of the universe."
     exit 0 # still do some logging
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
   display_banner
   display_prologue
}

function display_banner () {
   echo "██ ▄█▀ ██▓ ██▓     ██▓       ▄▄▄█████▓ ██░ ██ ▓█████    ▄▄▄▄   ▓█████ ▄▄▄        ██████ ▄▄▄█████▓"
   echo "██▄█▒ ▓██▒▓██▒    ▓██▒       ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀   ▓█████▄ ▓█   ▀▒████▄    ▒██    ▒ ▓  ██▒ ▓▒"
   echo "▓███▄░ ▒██▒▒██░    ▒██░       ▒ ▓██░ ▒░▒██▀▀██░▒███    ▒██▒ ▄██▒███  ▒██  ▀█▄  ░ ▓██▄   ▒ ▓██░ ▒░"
   echo "▓██ █▄ ░██░▒██░    ▒██░       ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄  ▒██░█▀  ▒▓█  ▄░██▄▄▄▄██   ▒   ██▒░ ▓██▓ ░ "
   echo "▒██▒ █▄░██░░██████▒░██████▒    ▒██▒ ░ ░▓█▒░██▓░▒████▒  ░▓█  ▀█▓░▒████▒▓█   ▓██▒▒██████▒▒  ▒██▒ ░ "
   echo "▒ ▒▒ ▓▒░▓  ░ ▒░▓  ░░ ▒░▓  ░    ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░  ░▒▓███▀▒░░ ▒░ ░▒▒   ▓▒█░▒ ▒▓▒ ▒ ░  ▒ ░░   "
   echo "░ ░▒ ▒░ ▒ ░░ ░ ▒  ░░ ░ ▒  ░      ░     ▒ ░▒░ ░ ░ ░  ░  ▒░▒   ░  ░ ░  ░ ▒   ▒▒ ░░ ░▒  ░ ░    ░    "
   echo "░ ░░ ░  ▒ ░  ░ ░     ░ ░       ░       ░  ░░ ░   ░      ░    ░    ░    ░   ▒   ░  ░  ░    ░      "
   echo "░  ░    ░      ░  ░    ░  ░             ░  ░  ░   ░  ░   ░         ░  ░     ░  ░      ░           "
}

function display_prologue () {
   tput bold
   echo -e "\tlorem ipsum lorem ipsum"
   tput sgr0
   echo "lorem ipsum lorem ipsum"
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
   echob "Your name is? "
   read player_name
   echo
   echo -en "\tVery well "
   echob "$player_name"
   echo ", I wish you the best of luck. May the force be with odds of mass times acceleration ever be in your favor. Long live and prosper."
}

function prompt_user_input () {
   echob "Traverse, Dodge, Quit ? ) "
   read player_move
   player_move="${player_move^^}"
}

function get_user_move () {
   # this should be random or differs depending on the remaining encounters
   echo "Dragon's fiery breath is in your path, what would you do?"
   prompt_user_input
   while [[ "${player_move}" != "${TRVSE}" && "${player_move}" != "${DDG}" && "${player_move}" != "${QQ}" ]]
   do
      echo "Bloody hell, that's not even in the choices. Goddamnit, stupid bonkers."
      prompt_user_input
   done
}

function quit_game () {
   echo "HAHAHAHAHAHA. You're a quitter! Shame!"
   echo -n "Very well, "
   echob "${player_name}"
   echo ". I don't have any interest for the likes of you. Go back to wherever critter cave you came from. Coward."
   end_game
   exit 0
}

function initialize_player_deck () {
   echo ; echob "Initializing your deck..." ; echo
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
   discard_cards # cards are already used
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
   echo ".------."
   echo "|$1.--. |"
   echo "| :/\: | ----> ${2}"
   echo -e "| (__) |\t card"
   echo "| '--'$1|"
   echo "\`------'";
}

function display_heart () {
   echo ".------.";
   echo "|$1.--. |";
   echo "| (\/) | ----> ${2}";
   echo -e "| :\/: |\t card";
   echo "| '--'$1|";
   echo "\`------'";
}

function display_diamond () {
  echo ".------.";
  echo "|$1.--. |";
  echo "| :/\: | ----> ${2}"
  echo -e "| :\/: |\t card";
  echo "| '--'$1|";
  echo "\`------'";
}

function display_club () {
  echo ".------.";
  echo "|$1.--. |";
  echo "| :(): | ----> ${2}"
  echo -e "| ()() |\t card";
  echo "| '--'$1|";
  echo "\`------'";
}

function wait () {
  echo
  read -sp "... press any key to continue ... " -n1 -s
  echo
}


# run main function
main
