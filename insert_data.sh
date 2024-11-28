#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

echo $($PSQL "TRUNCATE games, teams;")

echo -e "\nStart insert data into table teams:\n"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
    then

    # get team_one_id and team_two_id
    TEAM_ONE_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    TEAM_TWO_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # if team_one_id not found
    if [[ -z $TEAM_ONE_ID ]]
      then
        # insert team_one
        INSERT_TEAM_ONE_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")
        if [[ $INSERT_TEAM_ONE_RESULT == "INSERT 0 1" ]]
          then
            echo "Inserted a winner into teams, $WINNER"
        fi

        # get new team_one_id
        TEAM_ONE_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

    # if team_two_id not found
    if [[ -z $TEAM_TWO_ID ]]
      then
        # insert team_two
        INSERT_TEAM_TWO_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
        if [[ $INSERT_TEAM_TWO_RESULT == "INSERT 0 1" ]]
          then
            echo "Inserted an opponent into teams, $OPPONENT"
        fi

        # get new team_two_id
        TEAM_TWO_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
  fi
done
echo -e "\nInsertion into table teams completed\n"

echo -e "Start insert data into table games:\n"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
    then
      # get winner_id and opponent_id
      # both ids are there at this point
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      
      # get game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID;")

      # if not found
      if [[ -z $GAME_ID ]]
        then
          INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
          if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
            then
              echo "Inserted into games, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS"
          fi
      fi
  fi
done
echo -e "\n Insertion into table games completed\n"
