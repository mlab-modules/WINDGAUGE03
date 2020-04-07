include <../configuration.scad>

cylinder(h = M3_bolt_length, d = M3_bolt_diameter, $fn=50);
translate([0, 0, -M3_nut_height])
    cylinder(h = M3_nut_height, d = M3_nut_diameter, $fn=6);
translate([0, 0, M3_bolt_length - M3_nut_height])
    cylinder(h = M3_bolt_head_height, d = M3_nut_diameter);
