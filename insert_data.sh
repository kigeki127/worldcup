#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear teams and games tables 
echo $($PSQL "truncate teams, games")

# Read CSV file and process each row
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Skip header row
  if [[ $winner != "winner" ]]
  then
    # Check and insert winner team
    wteam_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $wteam_id ]]
    then
      insert_team=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      if [[ $insert_team == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, '$winner'"
      fi
    fi
  fi
  # Skip header row
  if [[ $opponent != "opponent" ]]
  then
    # Check and insert opponent team
    oteam_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $oteam_id ]]
    then
      insert_team=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      if [[ $insert_team == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, '$opponent'"
      fi
    fi
  fi

# Skip header row
  if [[ $year != "year" ]]
  then
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    # Ensure both teams exist before inserting into games
    if [[ -n $winner_id && -n $opponent_id ]]
    then
      insert_games=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
      
      if [[ $insert_games == "INSERT 0 1" ]]
      then
        echo "Inserted into games: $year, '$round', $wteam_id, $oteam_id, $winner_goals, $opponent_goals"
      fi
    else
      echo "Skipping game entry: missing team ID(s) for $winner vs $opponent"
    fi
  fi

done
