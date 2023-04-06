#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#### v2 ####

# # Drop db if already exists

# $($PSQL "DROP DATABASE worldcup;")

# # Create new db

# $($PSQL "CREATE DATABASE worldcup;")

# Truncate Tables

# $($PSQL "TRUNCATE TABLE games, teams")

# Create teams table & columns

$($PSQL "CREATE TABLE teams (
  team_id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL
);")

# Create games table and columns

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

# Read Data from CSV

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

if [[ $YEAR != year ]]
then
#echo $YEAR $ROUND $WINNER $WINNER_GOALS;
TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
fi

done

# Modify games table columns winner_id & opponent_id to set NOT NULL

$($PSQL "ALTER TABLE games
ALTER COLUMN winner_id SET NOT NULL,
ALTER COLUMN opponent_id SET NOT NULL;");

#### v1 ####

# # Drop db if already exists

# $($PSQL "DROP DATABASE worldcup;")

# # Create new db

# $($PSQL "CREATE DATABASE worldcup;")

# # Connect to worldcup DB

# # $($PSQL "\c worldcup")

# $($PSQL "CREATE TABLE teams (
#   team_id SERIAL PRIMARY KEY,
#   name VARCHAR UNIQUE NOT NULL
# );")

# $($PSQL "CREATE TABLE games (
#   game_id SERIAL PRIMARY KEY,
#   year INT NOT NULL,
#   round VARCHAR NOT NULL,
#   winner VARCHAR NOT NULL,
#   opponent VARCHAR NOT NULL,
#   winner_goals INT NOT NULL,
#   opponent_goals INT NOT NULL
#   winner_id INT REFERENCES teams(team_id),
#   opponent_id INT REFERENCES teams(team_id),
# );")


# $($PSQL "\copy games(year, round, winner, opponent, winner_goals, opponent_goals) FROM 'games.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');")
# $($PSQL "INSERT INTO teams (name)
# SELECT DISTINCT winner FROM games
# UNION
# SELECT DISTINCT opponent FROM games;");
# $($PSQL "UPDATE games
# SET winner_id = (SELECT team_id FROM teams WHERE name = games.winner),
#     opponent_id = (SELECT team_id FROM teams WHERE name = games.opponent)
# WHERE winner_id IS NULL OR opponent_id IS NULL;");
# $($PSQL "ALTER TABLE games
# ALTER COLUMN winner_id SET NOT NULL,
# ALTER COLUMN opponent_id SET NOT NULL;");

# Delete additional entries
# # $($PSQL "DELETE FROM games WHERE game_id >= 34;");