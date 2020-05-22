include <configuration.scad>

parts_separation = 0;

//D02 - Anemometer holder
D02_z0 = 0;
translate([0, 0, D02_z0])
    rotate([0, 0, 0])
        import("../doc/stl/WINDGAUGE_D02.stl");

//S02 - Extender
S02_z0 = D02_z0 + D02_total_height - D02_thread_height + parts_separation;
translate([0, 0, S02_z0])
    rotate([0, 0, 0])
        import("../doc/stl/WINDGAUGE_S02.stl");

//S01 - Bearings holder
S01_z0 = S02_z0 + S01_vyska + parts_separation;
translate([0, 0, S01_z0])
    rotate([180, 0, 0])
        import("../doc/stl/WINDGAUGE_S01.stl");

//R03 - Venturi tube
R03_y0 = -2*R03_venturi_tube_height + R03_slip_ring_offset + 6*R03_wide_D;
R03_z0 = S01_z0 + R03_wide_D/2 + 5 + parts_separation;
%translate([0, R03_y0, R03_z0])
    rotate([270, 0, 0]){
        import("../doc/stl/WINDGAUGE_R03.stl");
    }
echo("WINDGAUGE_R03 coordinates are: [0, ", R03_y0, R03_z0, "]");

//R04 - PCB lid
R04_y0 = R03_venturi_tube_height + R03_y0 - R03_wide_D/2;
R04_z0 = R03_z0 + R03_wide_D/2 + R03_wall_thickness + parts_separation;
%translate([0, R04_y0, R04_z0])
    rotate([0, 0, 0])
        import("../amf/WINDGAUGE_R04.amf");
echo("WINDGAUGE_R04 coordinates are: [0, ", R04_y0, R04_z0, "]");


//R05 - Fin
R05_y0 = - 2*R03_venturi_tube_height + R03_slip_ring_offset + 6*R03_wide_D
         - R03_fin_length/2 + R03_fin_holder_height - parts_separation;
R05_z0 = R03_z0;
%translate([0, R05_y0, R05_z0])
    rotate([90, 0, 270])
        import("../amf/WINDGAUGE_R05.amf");
echo("WINDGAUGE_R05 coordinates are: [0, ", R05_y0, R05_z0, "]");

// R04 Left Bolt
LLB_x0 = -R03_PCB_width/2 - M3_nut_diameter;
LLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
LLB_z0 = R03_z0 + R03_wide_D/2;
color([1, 1, 1])
translate([LLB_x0, LLB_y0, LLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("R04 Left Bolt coordinates are: [",LLB_x0, LLB_y0, LLB_z0,"]");

// R04 Right Bolt
RLB_x0 = R03_PCB_width/2 + M3_nut_diameter;
RLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
RLB_z0 = R03_z0 + R03_wide_D/2;
color([1, 1, 1])
translate([RLB_x0, RLB_y0, RLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("R04 Right Bolt coordinates are: [",RLB_x0, RLB_y0, RLB_z0,"]");

// R05 Upper Bolt
UFB_x0 = -R03_fin_holder_width/2 + M3_nut_height;
UFB_y0 = R03_y0 + R03_fin_holder_height/2;
UFB_z0 = R03_z0 + R03_fin_holder_depth - R03_fin_holder_height/2;
color([1, 1, 1])
translate([UFB_x0, UFB_y0, UFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("R05 Upper Bolt coordinates are: [",UFB_x0, UFB_y0, UFB_z0,"]");

// R05 Lower Bolt
LFB_x0 = -R03_fin_holder_width/2 + M3_nut_height;
LFB_y0 = R03_y0 + R03_fin_holder_height/2;
LFB_z0 = R03_z0 - R03_fin_holder_depth + R03_fin_holder_height/2;
color([1, 1, 1])
translate([LFB_x0, LFB_y0, LFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("R05 Lower Bolt coordinates are: [",LFB_x0, LFB_y0, LFB_z0,"]");

// R03 COG
translate([ 0.04049399999999537 , 4.4475359999999995 , 195.23960399999999 ])
    color([0, 1, 1]) sphere(3);
// R04 COG
translate([ -0.005365999999995097 , 35.445547000000005 , 228.80337 ])
    color([0, 1, 1]) sphere(3);
// R05 COG
translate([ -0.45247699999999885 , -105.47900200000001 , 198.008691 ])
    color([0, 1, 1]) sphere(3);
// R04 Left Bolt COG
translate([ -13.603174000000001 , 45.492947 , 222.008644 ])
    color([1, 0, 0]) sphere(3);
// R04 Right Bolt COG
translate([ 13.596825999999998 , 45.492947 , 222.008644 ])
    color([1, 0, 0]) sphere(3);
// R05 Upper Bolt COG
translate([ 1.358644 , -77.696826 , 222.30705300000002 ])
    color([1, 0, 0]) sphere(3);
// R05 Lower Bolt COG
translate([ 1.358644 , -77.696826 , 173.707053 ])
    color([1, 0, 0]) sphere(3);

// WINDGAUGE03_R* COG
translate([ 0.01871127753303648 , 0.03284153870358795 , 200.76083991441158 ])
    color([0, 0, 1]) sphere(3);

// Desired WINDGAUGE03_R* COG
translate([ 0, 0, R03_z0 ])
    color([1, 0, 1]) sphere(3);
