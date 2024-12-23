#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ salon ~~~~~\n"
echo  "Welcome to My Salon, how can I help you?"

SERVICES_MENU() {
  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # display services
  echo "$SERVICES" | while read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}








SERVICES_MENU