#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    TEAMS=( "$WINNER" "$OPPONENT" )

    for (( i=0; i<2; i++ ))
    do
      TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='${TEAMS[$i]}';")"

      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('${TEAMS[$i]}');")"

        if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
        then
          echo "Inserted into TEAMS", ${TEAMS[$i]}
        fi
      fi
    done

    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='${TEAMS[0]}';")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='${TEAMS[1]}';")"

    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into GAMES, ${TEAMS[0]} : ${TEAMS[1]}"
    fi
  fi
done
