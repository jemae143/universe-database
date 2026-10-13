#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
TEST_USERNAME="number_guess_'user_123"
TEST_USERNAME_ESCAPED=${TEST_USERNAME//\'/\'\'}
trap "$PSQL \"DELETE FROM users WHERE username = '$TEST_USERNAME_ESCAPED'\" > /dev/null" EXIT

$PSQL "DELETE FROM users WHERE username = '$TEST_USERNAME_ESCAPED'" > /dev/null
FIRST_OUTPUT=$({ printf '%s\n' "$TEST_USERNAME" 'not-an-integer'; seq -f '%04g' 1 1000; } | ./number_guess.sh)
grep -Fq "Welcome, $TEST_USERNAME! It looks like this is your first time here." <<< "$FIRST_OUTPUT"
grep -Fq 'That is not an integer, guess again:' <<< "$FIRST_OUTPUT"
grep -Eq '^You guessed it in [0-9]+ tries\. The secret number was [0-9]+\. Nice job!$' <<< "$FIRST_OUTPUT"

USER_STATS=$($PSQL "SELECT games_played || '|' || best_game FROM users WHERE username = '$TEST_USERNAME_ESCAPED'")
[[ $USER_STATS == 1\|* ]]
BEST_GAME=${USER_STATS#*|}

SECOND_OUTPUT=$({ printf '%s\n' "$TEST_USERNAME"; seq -f '%04g' 1 1000; } | ./number_guess.sh)
grep -Fq "Welcome back, $TEST_USERNAME! You have played 1 games, and your best game took $BEST_GAME guesses." <<< "$SECOND_OUTPUT"
[[ $($PSQL "SELECT games_played FROM users WHERE username = '$TEST_USERNAME_ESCAPED'") == 2 ]]

printf 'Number guessing game checks passed.\n'