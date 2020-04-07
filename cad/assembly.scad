include <configuration.scad>

parts_separation = 0;

 //D02 - Anemometer holder
 D02_z0 = 0;
 translate([0, 0, D02_z0])
     rotate([0, 0, 0])
         import("../amf/WINDGAUGE_D02.stl");
 
 //S02 - Extender
 S02_z0 = D02_z0 + D02_total_height - D02_thread_height + parts_separation;
 translate([0, 0, S02_z0])
     rotate([0, 0, 0])
         import("../amf/WINDGAUGE_S02.stl");
 
 //S01 - Bearings holder
 S01_z0 = S02_z0 + S01_vyska + parts_separation;
 translate([0, 0, S01_z0])
     rotate([180, 0, 0])
         import("../amf/WINDGAUGE_S01.stl");

//R03 - Venturi tube
R03_y0 = -2*R03_venturi_tube_height + R03_slip_ring_offset + 6*R03_wide_D;
R03_z0 = S01_z0 + R03_wide_D/2 + 5 + parts_separation;
translate([0, R03_y0, R03_z0])
    rotate([270, 0, 0])
        import("../amf/WINDGAUGE_R03.stl");
echo("WINDGAUGE_R03 coordinates are: [0, ", R03_y0, R03_z0, "]");

//R04 - PCB lid
R04_y0 = R03_venturi_tube_height + R03_y0 - R03_wide_D/2;
R04_z0 = R03_z0 + R03_wide_D/2 + R03_wall_thickness + parts_separation;
translate([0, R04_y0, R04_z0])
    rotate([0, 0, 0])
        import("../amf/WINDGAUGE_R04.amf");
echo("WINDGAUGE_R04 coordinates are: [0, ", R04_y0, R04_z0, "]");


//R05 - Fin
R05_y0 = (-R03_fin_length/2 - R03_venturi_tube_height/2
          + M3_nut_diameter/2 - parts_separation);
R05_z0 = R03_z0;
translate([0, R05_y0, R05_z0])
    rotate([90, 0, 270])
        import("../amf/WINDGAUGE_R05.amf");
echo("WINDGAUGE_R05 coordinates are: [0, ", R05_y0, R05_z0, "]");

// Left lid bolt
LLB_x0 = -R03_PCB_width/2 - M3_nut_diameter;
LLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
LLB_z0 = R03_z0 + R03_wide_D/2;
translate([LLB_x0, LLB_y0, LLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("LLB coordinates are: [",LLB_x0, LLB_y0, LLB_z0,"]");

// Right lid bolt
RLB_x0 = R03_PCB_width/2 + M3_nut_diameter;
RLB_y0 = R03_y0 + R03_venturi_tube_height - R03_PCB_height/2;
RLB_z0 = R03_z0 + R03_wide_D/2;
translate([RLB_x0, RLB_y0, RLB_z0])
    rotate([0, 0, 90])
        import("../amf/BOLT_M3x12.amf");
echo("RLB coordinates are: [",RLB_x0, RLB_y0, RLB_z0,"]");

// Upper fin bolt
UFB_x0 = -R03_fin_holder_width/2 + M3_nut_height;
UFB_y0 = R03_y0 + R03_fin_holder_height/2;
UFB_z0 = R03_z0 + R03_fin_holder_depth - R03_fin_holder_height/2;
translate([UFB_x0, UFB_y0, UFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("UFB coordinates are: [",UFB_x0, UFB_y0, UFB_z0,"]");

// Lower fin bolt
LFB_x0 = -R03_fin_holder_width/2 + M3_nut_height;
LFB_y0 = R03_y0 + R03_fin_holder_height/2;
LFB_z0 = R03_z0 - R03_fin_holder_depth + R03_fin_holder_height/2;
translate([LFB_x0, LFB_y0, LFB_z0])
    rotate([0, 90, 0])
        import("../amf/BOLT_M3x12.amf");
echo("LFB coordinates are: [",LFB_x0, LFB_y0, LFB_z0,"]");

//// W03 COG
//translate([ 0.08079047492694258 , 4.796862038974993 , 192.0796628905032 ])
//    color([0, 1, 1]) sphere(3);
//// W04 COG
//translate([ -0.05056794282057808 , 35.29610353726689 , 228.8396918364447 ])
//    color([0, 1, 1]) sphere(3);
//// W05 COG
//translate([ -0.4711450041209755 , -106.43251387036916 , 198.03346008413925 ])
//    color([0, 1, 1]) sphere(3);
//// LLB
//translate([ -14.705410919003347 , 41.94640679612685 , 221.7185967348921 ])
//    color([1, 0, 0]) sphere(3);
//// RLB
//translate([ 12.494589080996652 , 41.94640679612685 , 221.7185967348921 ])
//    color([1, 0, 0]) sphere(3);
//// UFB
//translate([ 1.0685967348920924 , -76.59458908099666 , 225.85359320387317 ])
//    color([1, 0, 0]) sphere(3);
//// LFB
//translate([ 1.0685967348920924 , -76.59458908099666 , 177.25359320387315 ])
//    color([1, 0, 0]) sphere(3);
//
//// Assembly COG
//translate([ 0.020334835231563774 , 0.11862847838485871 , 197.83173437060938 ])
//    color([0, 0, 1]) sphere(3);
//
//// Desired COG
//translate([ 0, 0, R03_z0 ])
//    color([1, 0, 1]) sphere(3);
