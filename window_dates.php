<?php

/**
 * @file
 * Because manipulating dates on Mac in bash is BS.
 */

$date = !empty($argv[2]) ? strtotime($argv[2]) : time();

if ($argv[1] == 1) {
  $week = "first";
}
elseif ($argv[1] == 3) {
  $week = "third";
}

$window = strtotime("$week wednesday of this month", $date);
if ($date >= $window) {
  $window = strtotime("$week wednesday of next month", $date);
}
print date("Y-m-d", $window);
