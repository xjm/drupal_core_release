<?php

/**
 * @file
 * Because manipulating dates on Mac in bash is BS.
 *
 * The script expects two CLI arguments:
 * - An integer for which week of the month to use (either 1 or 3).
 * - (optional) Y-m-d date to use as "now" (pick the windows after that date).
 */

// Default to the current date if none was provided.
$date = !empty($argv[2]) ? strtotime($argv[2]) : time();

// Normal windows are either the first or third week of the month.
if ($argv[1] == 1) {
  $week = "first";
}
elseif ($argv[1] == 3) {
  $week = "third";
}

// Calculate the specified window for this month.
$window = strtotime("$week wednesday of this month", $date);

// If this month's window is already past, calculate the next one.
if ($date >= $window) {
  $window = strtotime("$week wednesday of next month", $date);
}

// Print the Y-m-d date.
print date("Y-m-d", $window);
