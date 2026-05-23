#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use BiciCalc;

BiciCalc::calc_all();

print "--- Core geometry ---\n";
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

print "\n--- Tube angles ---\n";
printf "dt_angle          : %.2f deg\n", $BiciCalc::calc{dt_angle};
printf "seatstay_length   : %.2f mm\n",  $BiciCalc::calc{seatstay_length};

print "\n--- Miter joint angles ---\n";
my $m = $BiciCalc::calc{miter};
printf "ht_top_tt  (TT/HT at HT top)    : %.2f deg\n", $m->{ht_top_tt};
printf "ht_bot_dt  (DT/HT at HT bottom) : %.2f deg\n", $m->{ht_bot_dt};
printf "st_top_tt  (TT/ST at ST top)    : %.2f deg\n", $m->{st_top_tt};
printf "bb_st      (ST at BB shell)     : %.2f deg\n", $m->{bb_st};
printf "bb_dt      (DT at BB shell)     : %.2f deg\n", $m->{bb_dt};
printf "bb_cs      (CS at BB shell)     : %.2f deg\n", $m->{bb_cs};
printf "ss_st      (SS/ST at seat tube) : %.2f deg\n", $m->{ss_st} if defined $m->{ss_st};
printf "ss_cs      (SS/CS at dropout)   : %.2f deg\n", $m->{ss_cs} if defined $m->{ss_cs};
