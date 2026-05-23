#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use BiciCalc;

BiciCalc::calc_all();

printf "wheel_radius      : %.2f mm\n",  $BiciCalc::calc{wheel_radius};
printf "bb_height         : %.2f mm\n",  $BiciCalc::calc{bb_height};
printf "seat_tube_ctt     : %.2f mm\n",  $BiciCalc::calc{seat_tube_ctt};
printf "seat_tube_ctc     : %.2f mm\n",  $BiciCalc::calc{seat_tube_ctc};
printf "trail             : %.2f mm\n",  $BiciCalc::calc{trail};
printf "front_center      : %.2f mm\n",  $BiciCalc::calc{front_center};
printf "wheelbase         : %.2f mm\n",  $BiciCalc::calc{wheelbase};
printf "stack             : %.2f mm\n",  $BiciCalc::calc{stack};
printf "reach             : %.2f mm\n",  $BiciCalc::calc{reach};
printf "effective_top_tube: %.2f mm\n",  $BiciCalc::calc{effective_top_tube};
