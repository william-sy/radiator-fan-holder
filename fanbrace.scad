// Rendersettings
$fa = 1;
$fs = 0.4;
// Radiator fan mount.
// Recommendations:
// rad type 33 = 120 mm (104.5)
// rad type 22 = 80  mm (71.5)
// rad type 21 = 40  mm (32)

// Imports
use <MCAD/boxes.scad>

// Variables
// specify fan type here, the rest should change!
fan = "m";
// specify true / false for mount holes at the end
mount_holes_at_end = false;
// The thickness of your fan
fan_thickness = 25;

rad_lip      = 4;
hole_radius  = 2;
br_height    = 3;
mount_with   = 10;
mount_length = 5;

// You can add or change fan sizes here
fan_size =
(fan == "s") ? 40:
(fan == "m") ? 80:
(fan == "l") ? 120:0;
// The hole locations of a fan (from google)
fan_hole_spacing =
(fan == "s") ? 32:
(fan == "m") ? 71.5:
(fan == "l") ? 104.5:0;
// The inner (removed) cube radius
inner_radius =
(fan == "s") ? 15:
(fan == "m") ? 17:
(fan == "l") ? 30:0;
// The ammount of fan brackets fit on a 220 bed
holder_on_bed =
(fan == "s") ? 3:
(fan == "m") ? 1:
(fan == "l") ? 0:0;
// The distance between the front bracket and the fan bracket
fr_brack_dist =
(fan == "s") ? 20:
(fan == "m") ? 0:
(fan == "l") ? -20:0;

module fan_holder(){
    // Main bracket
    difference(){
        cube([fan_size,fan_size, br_height], center = true);
        // Remove a rounded box from the center
        roundedBox(size=[fan_size-4,fan_size-4,br_height+5],radius=inner_radius,sidesonly=true);
        // Remove 4 holes for mounting
        //1
        translate([fan_hole_spacing/2,fan_hole_spacing/2,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
        //2
        translate([-fan_hole_spacing/2,-fan_hole_spacing/2,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
        //3
        translate([fan_hole_spacing/2,-fan_hole_spacing/2,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
        //4
        translate([-fan_hole_spacing/2,fan_hole_spacing/2,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
    }
    // mount bracket 1
    difference(){
        translate([fan_size/2-mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with,mount_length, br_height], center = true);
        translate([fan_size/2-mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with/2,mount_length/2, br_height+1], center = true);
    }
    // mount bracket 2
    difference(){
        translate([-fan_size/2+mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with,mount_length, br_height], center = true);
        translate([-fan_size/2+mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with/2,mount_length/2, br_height+1], center = true);
    }
    // glue brace 1
    translate([fan_size/2-mount_with,-fan_size/2-1,0])
        cube([mount_with,mount_length/2, br_height], center = true);
    // glue brace 2
    translate([-(fan_size/2-mount_with),-fan_size/2-1,0])
        cube([mount_with,mount_length/2, br_height], center = true);
}

module fan_brace (){
    difference(){
        // main brace
        translate([(fan_size/2)+(mount_length/2)-0.001,0,0])
            cube([mount_length,fan_size,br_height], center = true);
        // remove a mounting holes
        // mount hole 1
        translate([(fan_size/2)+(mount_length/2),mount_length,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
        // mount return hole
        translate([(fan_size/2)+(mount_length/2),-mount_length,0])
            cylinder(h=br_height+2 ,r= hole_radius, center = true);
    }
}

module front_plate (){
    difference(){
        // The faceplate
        translate ([0,-fan_size,0])
            cube([fan_size+mount_length,fan_thickness+br_height+rad_lip,br_height]);
        // Remove a piece for the bracket to sit in.
        translate ([0,-fan_size+rad_lip,br_height/2])
            cube([fan_size+mount_length,br_height,br_height+1]);
        // Remove some more material
        translate ([br_height/2,-fan_size+rad_lip*2,br_height/2])
            cube([fan_size+mount_length-br_height,fan_thickness/1.2,br_height+1]);
        }
        // Add braces to lean agains the fan
        // not sure it its really needed with this design, ill leave it for now
        // brace 1
        // brace 2
}

module connector () {
    difference(){
        translate([0,-mount_length+0.001,0])
        if (fan == "l"){
            cube([mount_with*3,mount_length, br_height], center = true);
        }else{
            cube([mount_with*2,mount_length, br_height], center = true);
        }
        translate([hole_radius+((fan_size-fan_hole_spacing)/2),-mount_length,0])
            cylinder(h=br_height+2 ,r=hole_radius, center = true);
        translate([-hole_radius-((fan_size-fan_hole_spacing)/2),-mount_length,0])
            cylinder(h=br_height+2 ,r=hole_radius, center = true);
    }
    difference(){
        //translate([-fan_size/2+mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with,mount_length, br_height], center = true);
        //translate([-fan_size/2+mount_with,fan_size/2+mount_length/2-0.001,0])
            cube([mount_with/2,mount_length/2, br_height+1], center = true);
    }
}

// Produce the actual fan holders
for (i=[0:1:holder_on_bed]) {
    // Fan holder + mounitng holes
    translate([i*(fan_size+mount_length)-0.001,0,0])
       fan_holder();
    // Add mounting holes in between brackets, but the last
    if (i<holder_on_bed){
        translate([i*(fan_size+mount_length)-0.001,0,0])
            fan_brace();
    }
    // Add mounting holes at the end
    if (mount_holes_at_end == true){
        translate([i*(fan_size+mount_length)-0.001,0,0])
            fan_brace();
    }
    // Front face plate
    translate ([i*(fan_size+mount_length-0.001)-fan_size/2,-fr_brack_dist,0])
        front_plate();
   // Add a botom connector
    translate ([i*(fan_size+mount_length),0,0])
        connector();
}
