#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?"
  fi

  echo "$($PSQL "select * from services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  #read service id
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "select * from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #search phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    #new customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    APPOINTMENT
  fi
}

APPOINTMENT(){
  CUSTOMER_NAME_TRIMMED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME_TRIMMED?"
  read SERVICE_TIME
  APPOINTMENT_INSERT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME_TRIMMED."
}

MAIN_MENU