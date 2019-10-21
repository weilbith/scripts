#!/bin/bash
#
# Print a ICS calendar item with Khal.

if command -v khal>/dev/null; then
  khal printics --format "
  +-------------------+
  | ICS Calendar Item |
  +-------------------+
  Title:       {repeat-symbol}{title}
  Start:       {start-date-long} {start-time-full}
  End:         {end-date-long} {end-time-full}
  Location:    {location}
  Status:      {status}
  Description:
  {description}
  -------- END --------
  " "${1}" | awk '{if (NR>2) print}'

else
  echo "Error: Khal not available!"
fi

