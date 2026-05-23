package BiciCalc;

use strict;
use warnings;
use POSIX qw();
use List::Util qw();

our $PI = 4 * atan2(1, 1);

sub deg2rad { $_[0] * $PI / 180 }
sub rad2deg { $_[0] * 180 / $PI }
sub asin    { atan2($_[0], sqrt(1 - $_[0]**2)) }

# ---------------------------------------------------------------------------
# Input data
# All dimensions in mm, angles in degrees.
# ---------------------------------------------------------------------------
our %input = (
    # Wheel
    wheel_rim_diameter  => 622,   # ETRTO bead seat diameter (622=700c, 584=650b, 559=26")
    tire_width          => 28,    # mm, used to compute rolling radius

    # Frame angles
    head_tube_angle     => 73.0,  # degrees
    seat_tube_angle     => 73.0,  # degrees

    # Frame dimensions
    head_tube_length    => 140,   # mm
    seat_tube_length    => 570,   # mm, interpreted per seat_tube_measure
    seat_tube_measure   => 'ctt', # 'ctt' (default) or 'ctc'
    top_tube_length     => 560,   # mm, actual length along tube
    top_tube_slope      => 0,     # degrees, 0 = horizontal, positive = sloping down to rear
    chainstay_length    => 415,   # mm, BB center to rear axle center
    bb_drop             => 70,    # mm, BB center below wheel axle centerline

    # Fork
    fork_rake           => 45,    # mm, perpendicular offset from steering axis to axle

    # Tube outer diameters (mm)
    head_tube_od        => 31.8,
    down_tube_od        => 31.8,
    top_tube_od         => 25.4,
    seat_tube_od        => 28.6,
    chainstay_od        => 22.2,
    seatstay_od         => 16.0,
);

# ---------------------------------------------------------------------------
# Calculated data
# Populated by the calc_* subs below.
# ---------------------------------------------------------------------------
our %calc = (
    # Wheel
    wheel_radius        => undef,   # mm, actual rolling radius

    # Seat tube (both measures always present)
    seat_tube_ctt       => undef,   # mm, BB center to top of seat tube
    seat_tube_ctc       => undef,   # mm, BB center to TT centerline

    # Core geometry
    bb_height           => undef,   # mm, BB center above ground
    trail               => undef,   # mm
    wheelbase           => undef,   # mm
    front_center        => undef,   # mm, BB center to front axle
    stack               => undef,   # mm, BB center to top of HT (vertical)
    reach               => undef,   # mm, BB center to top of HT (horizontal)
    effective_top_tube  => undef,   # mm, horizontal projection of TT
);

# ---------------------------------------------------------------------------
# Subs
# ---------------------------------------------------------------------------

sub calc_wheel_radius {
    $calc{wheel_radius} = $input{wheel_rim_diameter} / 2 + $input{tire_width} / 2;
}

sub calc_seat_tube {
    my $st  = $input{seat_tube_length};
    my $tt_od = $input{top_tube_od};
    my $slope = $input{top_tube_slope};

    # Vertical rise of TT radius at the seat tube junction
    my $tt_rise = ($tt_od / 2) * cos(deg2rad($slope));

    if ($input{seat_tube_measure} eq 'ctt') {
        $calc{seat_tube_ctt} = $st;
        $calc{seat_tube_ctc} = $st - $tt_rise;
    } else {
        $calc{seat_tube_ctc} = $st;
        $calc{seat_tube_ctt} = $st + $tt_rise;
    }
}

sub calc_bb_height {
    calc_wheel_radius() unless defined $calc{wheel_radius};
    $calc{bb_height} = $calc{wheel_radius} - $input{bb_drop};
}

sub calc_trail {
    my $r   = deg2rad($input{head_tube_angle});
    calc_wheel_radius() unless defined $calc{wheel_radius};
    $calc{trail} = ($calc{wheel_radius} * cos($r) - $input{fork_rake}) / sin($r);
}

sub calc_front_center {
    calc_bb_height() unless defined $calc{bb_height};
    # Front center: horizontal distance BB center to front axle
    # front_axle is at wheel_radius height; BB is at bb_height
    # vertical difference = wheel_radius - bb_height = bb_drop
    $calc{front_center} = sqrt(
        $input{chainstay_length}**2
        - $input{bb_drop}**2
    );
    # That gives rear_center; front_center needs fork/HT geometry.
    # Computed via wheelbase - chainstay horizontal projection.
    # Defer to calc_wheelbase which resolves all at once.
    _calc_frame_layout();
}

# Internal: resolves wheelbase, front_center, stack, reach, effective_top_tube
sub _calc_frame_layout {
    calc_wheel_radius() unless defined $calc{wheel_radius};
    calc_seat_tube()    unless defined $calc{seat_tube_ctc};

    my $hta   = deg2rad($input{head_tube_angle});
    my $sta   = deg2rad($input{seat_tube_angle});
    my $slope = deg2rad($input{top_tube_slope});
    my $ht_len = $input{head_tube_length};
    my $tt_len  = $input{top_tube_length};
    my $r       = $calc{wheel_radius};
    my $bb_drop = $input{bb_drop};
    my $rake    = $input{fork_rake};

    # BB is origin (0, 0). Y = vertical, X = horizontal toward front.

    # Seat tube top (c-t-c point = TT junction on seat tube)
    my $st_ctc = $calc{seat_tube_ctc};
    my $st_top_x = -$st_ctc * cos($sta);   # behind BB
    my $st_top_y =  $st_ctc * sin($sta);

    # Top tube runs from ST junction at slope angle toward HT
    # slope is positive downward toward rear, so TT goes up toward front
    my $tt_dx =  $tt_len * cos($slope);    # horizontal (toward front)
    my $tt_dy = -$tt_len * sin($slope);    # vertical (negative = going down toward front if slope>0)

    # HT bottom (TT junction on HT side) — TT end
    my $ht_bot_x = $st_top_x + $tt_dx;
    my $ht_bot_y = $st_top_y + $tt_dy;

    # HT runs along head_tube_angle; top is above bottom
    my $ht_top_x = $ht_bot_x + $ht_len * cos($hta);
    my $ht_top_y = $ht_bot_y + $ht_len * sin($hta);

    # Stack and reach from BB to top of HT
    $calc{stack} = $ht_top_y;
    $calc{reach} = $ht_top_x;

    # Effective top tube = horizontal distance ST junction to HT junction
    $calc{effective_top_tube} = $ht_bot_x - $st_top_x;

    # Front axle: extends from HT bottom along steering axis, then fork rake perpendicular
    # Fork rake is perpendicular to steering axis, offset toward front
    my $axle_x = $ht_bot_x + $rake * sin($hta);
    my $axle_y = $ht_bot_y - $rake * cos($hta);

    $calc{front_center} = $axle_x;   # BB is at x=0, axle is forward
    $calc{wheelbase}    = $axle_x + $input{chainstay_length} * cos(
        asin($bb_drop / $input{chainstay_length})
    );
}

sub calc_all {
    calc_wheel_radius();
    calc_bb_height();
    calc_seat_tube();
    calc_trail();
    _calc_frame_layout();
}

1;
