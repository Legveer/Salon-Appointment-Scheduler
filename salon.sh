#!/bin/bash

# Database connection details
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Display services list
show_services() {
  echo "\nServices offered:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt for appointment
book_appointment() {
  # Show services and get the service_id
  show_services
  echo -e "\nEnter the service ID you'd like to book:"
  read SERVICE_ID_SELECTED

  # Check if the service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service ID. Please try again."
    book_appointment
  else
    # Get customer phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]; then
      # New customer, get their name
      echo -e "\nYou are not in our system. What's your name?"
      read CUSTOMER_NAME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      # Existing customer, fetch their name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    fi

    # Get the appointment time
    echo -e "\nEnter the appointment time:"
    read SERVICE_TIME

    # Insert the appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirm the appointment
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\nThere was an error scheduling your appointment. Please try again."
    fi
  fi
}

# Start the script
book_appointment
