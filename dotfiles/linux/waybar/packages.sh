#!/usr/bin/env bash

PACKAGES=$(dnf check-update 2> /dev/null | grep -c '^[[:alnum:]]' | tr -d '\n')

if [[ $PACKAGES == 0 ]]
then
  exit 0
fi

echo "$PACKAGES "
