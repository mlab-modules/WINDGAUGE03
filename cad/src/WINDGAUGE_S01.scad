include <../configuration.scad>
include <./lib/polyScrewThread_r1.scad>

draft = true;
$fn = draft ? 20 : 100; // model faces resolution
PI=3.141592;

//Držák ložisek, rotoru, senzoru
module WINDGAUGE01A_S01(draft = true)
{
    //valec se zavitem
    union()
    {
        difference()
        {
            union()
            {
                translate([0, 0, S01_sila_materialu])
                    if (draft)
                        cylinder(h = S01_vyska_horni_zavit,
                                 d = S01_prumer_vnitrni + S01_tolerance_zavit);
                    else
                        screw_thread((S01_prumer_vnitrni-S01_tolerance_zavit),
                                     S01_hloubka_zavitu, 55, S01_vyska_horni_zavit,
                                     PI/2, 2);
                //spodní doraz
                cylinder(h = S01_sila_materialu,
                         r=S01_prumer_vnitrni/2 + 5/2*S01_sila_materialu);
                //krycí ovál - usnadnění povolení
                difference()
                {
                    cylinder(h = R01_vyska_prekryti_statoru + 5,
                             r=S01_prumer_vnitrni/2 + 5/2*S01_sila_materialu);
                    cylinder(h = R01_vyska_prekryti_statoru + 5 + 0.01,
                             r = S01_prumer_vnitrni/2 + 3/2*S01_sila_materialu);
                }
            }
        //odstranění vnitřní výplně
        translate([0, 0, S01_sila_materialu])
            cylinder(h = S01_vyska_horni_zavit + 0.01,
                     r = (S01_prumer_vnitrni/2 - S01_hloubka_zavitu/2
                          - S01_sila_materialu));
        //otvor na ložisko s vodiči
        translate([0, 0, S01_sila_materialu/2])
            cylinder(h = slip_ring_body_height, d = slip_ring_mount_diameter, center = true);
        }
        //držák ložiska
        difference()
        {
            cylinder(h = slip_ring_body_height, d = slip_ring_body_diameter + 4*S01_sila_materialu);

            //otvor na ložisko
            translate([0, 0, slip_ring_mount_height])
                cylinder(h = slip_ring_body_height, d = slip_ring_body_diameter);

            //otvor na zasunuti loziska do ohradky
            cylinder(h = slip_ring_body_height, d = slip_ring_mount_diameter);
        }
    }
}

difference()
{
    // If not draft -> move to print position.
    if (!draft)
        translate([0, 0, 0])
            rotate([0, 0, 0])
                WINDGAUGE01A_S01(false);
    else
        WINDGAUGE01A_S01();
    // Cut-out cube
    if (draft)
        translate([0, 0, 0])
            cube(10*R01_vyska_prekryti_statoru);
}
