use <MCAD/boxes.scad>

$fs = 0.05;
$fa = 1;

// unit: mm
wall = [1.2, 1.2, 1];
intersection() {
    translate([5,5,5])
    roundedBox([10, 10, 10], wall.x);
    cube([10,10,2]);
}

