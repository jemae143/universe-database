#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only --quiet -c"

print_services() {
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
}

escape_sql() {
  printf '%s' "$1" | sed "s/'/''/g"
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
print_services

read SERVICE_ID_SELECTED
while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]] || [[ -z "$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")" ]]; do
  echo -e "\nI could not find that service. What would you like today?"
  print_services
  read SERVICE_ID_SELECTED
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_PHONE_SQL=$(escape_sql "$CUSTOMER_PHONE")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")

if [[ -z "$CUSTOMER_ID" ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=$(escape_sql "$CUSTOMER_NAME")
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME_SQL', '$CUSTOMER_PHONE_SQL')"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
SERVICE_TIME_SQL=$(escape_sql "$SERVICE_TIME")
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."