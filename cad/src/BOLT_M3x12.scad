include <../configuration.scad>
$fn=200;

cylinder(h = M3_bolt_length, d = M3_bolt_diameter, $fn=50);
cylinder(h = M3_nut_height, d = M3_nut_diameter, $fn=6);
translate([0, 0, M3_bolt_length])
    cylinder(h = M3_bolt_head_height, d = M3_nut_diameter);
