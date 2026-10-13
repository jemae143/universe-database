#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TEAM_VALUES=$(awk -F, 'NR > 1 { printf "(%c%s%c),(%c%s%c),\n", 39, $3, 39, 39, $4, 39 }' games.csv | sed '$ s/,$//')
$PSQL "INSERT INTO teams (name) VALUES $TEAM_VALUES ON CONFLICT (name) DO NOTHING;"

GAME_VALUES=$(awk -F, 'NR > 1 { printf "(%s,%c%s%c,%c%s%c,%c%s%c,%s,%s),\n", $1, 39, $2, 39, 39, $3, 39, 39, $4, 39, $5, $6 }' games.csv | sed '$ s/,$//')
$PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT csv.year, csv.round, winner.team_id, opponent.team_id, csv.winner_goals, csv.opponent_goals
FROM (VALUES $GAME_VALUES) AS csv(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winner ON winner.name = csv.winner
JOIN teams AS opponent ON opponent.name = csv.opponent;"
