#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Drop db if already exists

$($PSQL "DROP DATABASE worldcup;")

# Create new db

$($PSQL "CREATE DATABASE worldcup;")

# $($PSQL "\c worldcup")

$($PSQL "CREATE TABLE teams (
  team_id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL
);")

$($PSQL "CREATE TABLE games (
  game_id SERIAL PRIMARY KEY,
  year INT NOT NULL,
  round VARCHAR NOT NULL,
  winner VARCHAR NOT NULL,
  opponent VARCHAR NOT NULL,
  winner_goals INT NOT NULL,
  opponent_goals INT NOT NULL
  winner_id INT REFERENCES teams(team_id),
  opponent_id INT REFERENCES teams(team_id),
);")


$($PSQL "\copy games(year, round, winner, opponent, winner_goals, opponent_goals) FROM 'games.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');")
$($PSQL "INSERT INTO teams (name)
SELECT DISTINCT winner FROM games
UNION
SELECT DISTINCT opponent FROM games;");
$($PSQL "UPDATE games
SET winner_id = (SELECT team_id FROM teams WHERE name = games.winner),
    opponent_id = (SELECT team_id FROM teams WHERE name = games.opponent)
WHERE winner_id IS NULL OR opponent_id IS NULL;");
$($PSQL "ALTER TABLE games
ALTER COLUMN winner_id SET NOT NULL,
ALTER COLUMN opponent_id SET NOT NULL;");
# $($PSQL "DELETE FROM games WHERE game_id >= 34;");