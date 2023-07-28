#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
    if [[ $1 ]]; then
        echo -e "\n$1"
    fi

    # Get salon services
    SALON_SERVICES=$($PSQL "SELECT * FROM services")

    # Display list of the services
    echo "$SALON_SERVICES" | while read SERVICE_ID SERVICE_NAME; do
        echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/ |//g'
    done

    # Service Selection
    read SERVICE_ID_SELECTED
    SALON_SERVICES=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # Test if the service exists
    if [[ -z $SALON_SERVICES ]]; then
        # References to the main menu
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        # Request phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # Check if the client already exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]; then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # Adding the client to the database
            INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi

        # Appointment time
        echo -e "\nWhat time would you like your $SALON_SERVICES, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # Customer_id retrieval
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # Addition of the appointment in the database
        INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SALON_SERVICES at $SERVICE_TIME, $CUSTOMER_NAME."

    fi

}

MAIN_MENU
