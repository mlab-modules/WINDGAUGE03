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
    rotate([270, 180, 0]){
        import("../doc/stl/WINDGAUGE_R03.stl");
    }
echo("WINDGAUGE_R03 coordinates are: [0, ", R03_y0, R03_z0, "]");

//R04 - PCB lid
R04_x0 = -R03_wide_D/2;
R04_y0 = R03_venturi_tube_height + R03_y0;
R04_z0 = R03_z0 + R03_wide_D/2 + R03_wall_thickness + parts_separation;
%translate([R04_x0, R04_y0, R04_z0 + 0])
    rotate([0, 0, 270])
        import("../amf/WINDGAUGE_R04.amf");
echo("WINDGAUGE_R04 coordinates are: [", R04_x0, R04_y0, R04_z0, "]");


//R05 - Fin
R05_y0 = - 2*R03_venturi_tube_height + R03_slip_ring_offset + 6*R03_wide_D
         - R03_fin_length/2 + R03_fin_holder_height - parts_separation;
R05_z0 = R03_z0;
%translate([0, R05_y0, R05_z0])
    rotate([90, 0, 270])
        import("../amf/WINDGAUGE_R05.amf");
echo("WINDGAUGE_R05 coordinates are: [0, ", R05_y0, R05_z0, "]");

// R03 Front Bolt
FTB_x0 = -M3_bolt_length/2 - M3_nut_height/2;
FTB_y0 = 6.5;
FTB_z0 = R03_z0 - R03_wide_D/2;
color([1, 1, 1])
translate([FTB_x0, FTB_y0, FTB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("R03 Front Bolt coordinates are: [",FTB_x0, FTB_y0, FTB_z0,"]");

// R03 Rear Bolt
RTB_x0 = M3_bolt_length/2 + M3_nut_height/2;
RTB_y0 = -6.5;
RTB_z0 = R03_z0 - R03_wide_D/2;
color([1, 1, 1])
translate([RTB_x0, RTB_y0, RTB_z0])
    rotate([0, 90, 180])
        import("../amf/BOLT_M3x12.amf");
echo("R03 Rear Bolt coordinates are: [",RTB_x0, RTB_y0, RTB_z0,"]");

// R04 Left Bolt
LLB_x0 = -R03_PCB_width/2 - M3_nut_diameter;
LLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
LLB_z0 = R03_z0 + R03_wide_D/2 - M3_nut_height;
color([1, 1, 1])
translate([LLB_x0, LLB_y0, LLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("R04 Left Bolt coordinates are: [",LLB_x0, LLB_y0, LLB_z0,"]");

// R04 Right Bolt
RLB_x0 = R03_PCB_width/2 + M3_nut_diameter;
RLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
RLB_z0 = R03_z0 + R03_wide_D/2 - M3_nut_height;
color([1, 1, 1])
translate([RLB_x0, RLB_y0, RLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("R04 Right Bolt coordinates are: [",RLB_x0, RLB_y0, RLB_z0,"]");

// R05 Upper Bolt
UFB_x0 = -R03_fin_holder_width/2;
UFB_y0 = R03_y0 + R03_fin_holder_height/2;
UFB_z0 = R03_z0 + R03_fin_holder_depth - R03_fin_holder_height/2;
color([1, 1, 1])
translate([UFB_x0, UFB_y0, UFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("R05 Upper Bolt coordinates are: [",UFB_x0, UFB_y0, UFB_z0,"]");

// R05 Lower Bolt
LFB_x0 = -R03_fin_holder_width/2;
LFB_y0 = R03_y0 + R03_fin_holder_height/2;
LFB_z0 = R03_z0 - R03_fin_holder_depth + R03_fin_holder_height/2;
color([1, 1, 1])
translate([LFB_x0, LFB_y0, LFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("R05 Lower Bolt coordinates are: [",LFB_x0, LFB_y0, LFB_z0,"]");

// R03 COG
translate([ -0.4670859999999942 , 6.640354000000002 , 192.837544 ])
    color([0, 1, 1]) sphere(3);
// R04 COG
translate([ 1.0312389999999922 , 36.146445 , 228.245272 ])
    color([0, 1, 1]) sphere(3);
// R05 COG
translate([ -0.4690809999999989 , -101.44978800000001 , 197.63449400000002 ])
    color([0, 1, 1]) sphere(3);
// R03 Front Bolt COG
translate([ 0.7782590000000003 , 6.506229000000005 , 179.993901 ])
    color([1, 0, 0]) sphere(3);
// R03 Rear Bolt COG
translate([ -0.7782590000000003 , -6.506229000000004 , 179.993901 ])
    color([1, 0, 0]) sphere(3);
// R04 Left Bolt COG
translate([ -13.606229000000004 , 45.506099000000006 , 221.42825900000003 ])
    color([1, 0, 0]) sphere(3);
// R04 Right Bolt COG
translate([ 13.593770999999995 , 45.506099000000006 , 221.42825900000003 ])
    color([1, 0, 0]) sphere(3);
// R05 Upper Bolt COG
translate([ 0.7782590000000003 , -75.693771 , 224.293901 ])
    color([1, 0, 0]) sphere(3);
// R05 Lower Bolt COG
translate([ 0.7782590000000003 , -75.693771 , 171.69390099999998 ])
    color([1, 0, 0]) sphere(3);

// WINDGAUGE03_R* COG
translate([ -0.351634926309725 , 0.0062762700057576596 , 195.56655708002305 ])
    color([0, 0, 1]) sphere(3);

// // Desired WINDGAUGE03_R* COG
// translate([ 0, 0, R03_z0 ])
//     color([1, 0, 1]) sphere(3);
