#!/bin/bash

PSQL="psql -U freecodecamp guessing_game -t --no-align -c"

GUESS_LOOP() {
read USER_ANSWER

if [[ $USER_ANSWER =~ ^[0-9]+$ ]]
then
  if [[ $USER_ANSWER -eq $RANDOM_NUM ]]
    then 
      echo -e "\nYou guessed it in $USER_GUESSES tries. The secret number was $RANDOM_NUM. Nice job!\n"
          
      #Update # guesses
      if [[ $GUESSES_QUERY -eq 0 ]] && [[ $GAMES_QUERY -eq 0 ]]
      then
        UPDATE_GUESSES_RESULT=$($PSQL "UPDATE users SET best_guess_score = $USER_GUESSES WHERE name = '$USERNAME'")
      
      elif [[ $GUESSES_QUERY -gt $USER_GUESSES  ]]
      then
        UPDATE_GUESSES_RESULT=$($PSQL "UPDATE users SET best_guess_score = $USER_GUESSES WHERE name = '$USERNAME'")
      fi  

      #Update #games
      UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET number_of_games = $GAMES_QUERY+1 WHERE name = '$USERNAME'")

  #If input is greater than answer  
  elif [[ $USER_ANSWER -gt $RANDOM_NUM ]]
  then
    echo "It's lower than that, guess again:"
    let USER_GUESSES=USER_GUESSES+1
    GUESS_LOOP
  
  #if input is lower than answer
  elif [[ $USER_ANSWER -lt $RANDOM_NUM ]]
  then
    echo "It's higher than that, guess again:"
    let USER_GUESSES=USER_GUESSES+1
    GUESS_LOOP
  fi

else
  echo "That is not an integer, guess again:"
  let USER_GUESSES=USER_GUESSES+1
  GUESS_LOOP
fi
}


echo -e "\nEnter your username:\n"
read USERNAME

if [[ -z $USERNAME ]]
then
  echo -e "\nInsert a valid input."
else
  #Check if username is already in the database
  NAME_QUERY=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")

  #if -z NAME_QUERY, insert username
  if [[ $NAME_QUERY ]]
  then
    # Query # of games and guesses
    GAMES_QUERY=$($PSQL "SELECT number_of_games FROM users WHERE name = '$USERNAME'")
    GUESSES_QUERY=$($PSQL "SELECT best_guess_score FROM users WHERE name = '$USERNAME'")
    
    echo -e "$GAMES_QUERY"

    #Welcome back message
    echo -e "\nWelcome back, $NAME_QUERY! You have played $GAMES_QUERY games, and your best game took $GUESSES_QUERY guesses."
    
  else
    # Insert new user to db
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, number_of_games, best_guess_score) VALUES('$USERNAME', 1, 0)")

    #Welcome message
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
   fi 
fi

RANDOM_NUM=$((RANDOM%1000 + 1))

#Starting game
echo -e "\nGuess the secret number between 1 and 1000:"

#User counter
USER_GUESSES=1

GUESS_LOOP