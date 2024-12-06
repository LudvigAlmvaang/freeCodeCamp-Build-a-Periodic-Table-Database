#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

# This will receive the argument and check what it contains
# Afterwards it either passes the argument to another function or closes the program 
MAIN() {
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    FIND_ATOMIC_NUMBER $1
  elif [[ $1 =~ ^[[:alpha:]]+$ ]]
  then

    FIND_NAME_OR_SYMBOL $1
  else
    echo "Please provide an element as an argument."
  fi
}

# This is a messy query, but it will get all the element information
FIND_ATOMIC_NUMBER() {
  GET_ELEMENT=$($PSQL "SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
                      FROM elements
                      INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                      INNER JOIN types ON properties.type_id = types.type_id
                      WHERE elements.atomic_number = $1")
  if [[ -z $GET_ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    # After finding all the info, this will clean up the output from whitespace 
    CLEANED_OUTPUT=$(echo "$GET_ELEMENT" | sed 's/[|[:space:]]\+/ /g')
    IFS=$' ' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< "$CLEANED_OUTPUT"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

FIND_NAME_OR_SYMBOL() {
  GET_ELEMENT=$($PSQL "SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
                      FROM elements
                      INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                      INNER JOIN types ON properties.type_id = types.type_id
                      WHERE elements.symbol = '$1' OR elements.name = '$1'")
  if [[ -z $GET_ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    CLEANED_OUTPUT=$(echo "$GET_ELEMENT" | sed 's/[|[:space:]]\+/ /g')
    IFS=$' ' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< "$CLEANED_OUTPUT"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

# This will call the first function and pass the user argument :)
MAIN $1
