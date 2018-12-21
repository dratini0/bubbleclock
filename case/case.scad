use <MCAD/regular_shapes.scad>
use <MCAD/boxes.scad>

// helper functions
function maxvector(vectors) = [for (index = [0:1:len(vectors[0]) - 1]) max([for (vector = vectors) vector[index]])];

function dotmul(a, b) = [for (index = [0:1:len(a) - 1]) a[index] * b[index]];

module box_between(a, b) {
    translate(a) cube(b - a);
}

// configuration
$fs = 0.05;
$fa = 1;

// unit: mm
mil = 0.0254;
wall = [1.2, 1.2, 1];
long_extension = 100;
cap_split = 20;

// BMS
bms_thickness = 1.1;
bms_length = 27.9;
bms_width = 17.2;
bms_parts = 2;
bms_back_parts = 0.5;
bms_usb_height = 3;
bms_usb_underhang = 0.3;
bms_usb_width = 8;
bms_porch = 0.5;
// ALSO USB PORT!
// FIND SPECS

// screen
screen_pcb_thickness = 1.6;
screen_pcb_length = 60.8;
screen_pcb_width = 18.4;
screen_pcb_end_porch = 1.5;
screen_pcb_top_porch = 1.6;
screen_bubble_thickness = 3.3;
screen_rail_thickness = 2.9;
screen_right_edge_to_last_connector_center = 4.9;
screen_bottom_edge_to_connector_center = 2.18;
screen_window_thickness = 2;
screen_window_lip = 1;
screen_window_bottom_porch = 3.5;

// connector
connector_pitch = 100 * mil;
connector_pins = 22;
connector_screen_center_to_driver_face = 100 * mil + 150 * mil;
// https://hu.mouser.com/datasheet/2/418/NG_CD_644694_E2-1257639.pdf
connector_driver_center_to_screen_face = 8.7 + 92 * mil / 2;
connector_width = 2.5;

// driver
driver_thickness = 0.8 + 0.1; // 1.6 +- 10%
driver_length = 57.15 + 0.2;
driver_width = 22.86 + 0.2;
driver_programming_connector_height = 4.4;
driver_programming_connector_extension = 2.5;
driver_top_component_height = 2.3 + 0.8;
// https://datasheet.lcsc.com/szlcsc/Ai-Thinker-ESP-12F-ESP8266MOD_C82891.pdf
driver_bottom_component_height = 2.7;
// http://www.ti.com/lit/ds/symlink/sn74hc595.pdf
driver_front_porch = 0.6;
driver_back_top_porch = 0.5;
// protrusion for switch, maybe add lever?
driver_back_bottom_porch = -1;
driver_right_edge_to_last_connector_center = 1.9;
driver_front_edge_to_connector_center = 1.9;
driver_switch_hole_position = 3 - 1;
driver_switch_hole_length = 4 + 2;
driver_switch_hole_width = 2;

// battery (standard 18650)
battery_dia = 18;
battery_len = 65;
battery_padding_len = 3;

// screw hole
screw_hole_dia = 3; // M3
screw_nut_dia = 6.4 + 0.2;
screw_nut_height = 2.4;
screw_hole_pos = [5, 5, 0];

module battery(){
    translate([battery_dia / 2, battery_dia / 2])
    cylinder(h = battery_len + battery_padding_len, d = battery_dia);
}

battery = [battery_dia, battery_dia, battery_len + battery_padding_len];

//battery();

module driver() {
    translate([0, - driver_front_edge_to_connector_center, -driver_right_edge_to_last_connector_center]) {
        // PCB
        translate([-driver_thickness, 0, 0])
        cube([driver_thickness, driver_width, driver_length]);
        // front componets
        translate([0, driver_front_porch, -driver_programming_connector_extension])
        cube([driver_programming_connector_height, driver_width - driver_front_porch - driver_back_top_porch, driver_length + driver_programming_connector_extension]);
        // back components
        translate([- driver_thickness - driver_bottom_component_height, driver_front_porch, 0])
        cube([driver_bottom_component_height, driver_width - driver_front_porch - driver_back_bottom_porch, driver_length]);
        // switch cutout
        translate([- driver_thickness - driver_switch_hole_width, driver_width - driver_back_bottom_porch, driver_switch_hole_position])
        cube([driver_switch_hole_width, long_extension, driver_switch_hole_length]);
    }
}

//driver();

module screen() {
    translate ([- screen_bottom_edge_to_connector_center, 0, - screen_right_edge_to_last_connector_center]) {
        // PCB
        translate([0, - screen_pcb_thickness, 0])
        cube([screen_pcb_width, screen_pcb_thickness, screen_pcb_length]);
        // Bubbles
        translate([0, - screen_pcb_thickness - screen_bubble_thickness, screen_pcb_end_porch])
        cube([screen_pcb_width - screen_pcb_top_porch, screen_bubble_thickness, screen_pcb_length - 2 * screen_pcb_end_porch]);
        // PMMA window
        translate([screen_window_bottom_porch, - screen_pcb_thickness - screen_bubble_thickness - screen_window_thickness, screen_pcb_end_porch])
        cube([screen_pcb_width - screen_pcb_top_porch - screen_window_bottom_porch, screen_window_thickness, screen_pcb_length - 2 * screen_pcb_end_porch]);
        // window cutout
        translate([screen_window_bottom_porch + screen_window_lip, - screen_pcb_thickness - screen_bubble_thickness - screen_window_thickness - long_extension, screen_pcb_end_porch])
        cube([screen_pcb_width - screen_pcb_top_porch - screen_window_bottom_porch - 2 * screen_window_lip, long_extension, screen_pcb_length - 2 * screen_pcb_end_porch]);
    }
}

//screen();

connector_length = connector_pitch * connector_pins;
module connector() {
    translate([0, 0, - connector_pitch / 2]) {
        //driver side
        translate([0, connector_driver_center_to_screen_face - connector_width / 2, 0])
        cube([connector_screen_center_to_driver_face + connector_width / 2, connector_width, connector_length]);
        //screen side
        translate([connector_screen_center_to_driver_face - connector_width / 2, 0, 0])
        cube([connector_width, connector_driver_center_to_screen_face + connector_width / 2, connector_length]);
    }
}

module screen_driver_assembly() {
    translate([driver_thickness + driver_bottom_component_height, screen_pcb_thickness + screen_bubble_thickness + screen_window_thickness, max(driver_right_edge_to_last_connector_center + driver_programming_connector_extension, screen_right_edge_to_last_connector_center)]) {
        translate([0, connector_driver_center_to_screen_face, 0]) driver();
        translate([connector_screen_center_to_driver_face, 0, 0]) screen();
        connector();
    }
}

screen_driver_assembly_usable_area_1 = [
driver_thickness + driver_bottom_component_height + driver_programming_connector_height,
screen_pcb_thickness + screen_bubble_thickness + screen_window_thickness + connector_driver_center_to_screen_face + connector_width / 2,
0,
];

screen_driver_assembly_usable_area_2 = [
driver_thickness + driver_bottom_component_height + connector_screen_center_to_driver_face + connector_width / 2,
screen_pcb_thickness + screen_bubble_thickness + screen_window_thickness,
0,
];

screen_driver_assembly = [
screen_pcb_width - screen_bottom_edge_to_connector_center + connector_screen_center_to_driver_face + driver_thickness + driver_bottom_component_height,
driver_width - min(0, driver_back_bottom_porch) - driver_front_edge_to_connector_center + connector_driver_center_to_screen_face + screen_pcb_thickness + screen_bubble_thickness + screen_window_thickness,
max(driver_right_edge_to_last_connector_center + driver_programming_connector_extension, screen_right_edge_to_last_connector_center) +
max(driver_length - driver_right_edge_to_last_connector_center, screen_pcb_length - screen_right_edge_to_last_connector_center),
];

//screen_driver_assembly();

module bms() {
    translate([0, bms_back_parts, 0]) {
        // PCB
        cube([bms_width, bms_thickness, bms_length]);
        // back "parts"
        translate([bms_porch, - bms_back_parts, 0])
        cube([bms_width - 2 * bms_porch, bms_back_parts, bms_length]);
        // front parts
        translate([bms_porch, bms_thickness, 0])
        cube([bms_width - 2 * bms_porch, bms_parts, bms_length]);
        // USB port
        translate([(bms_width - bms_usb_width) / 2, bms_thickness, - long_extension])
        cube([bms_usb_width, bms_usb_height + bms_usb_underhang, long_extension + bms_length]);
    }
}

bms = 
[
bms_width,
bms_back_parts + bms_thickness + max(bms_usb_height, bms_parts),
bms_length,
];

//bms();

screen_driver_assembly_placement = wall;
bms_placement = screen_driver_assembly_placement + screen_driver_assembly_usable_area_2 + dotmul(wall, [1, 1, 0]);
// we don't have assert yet here
// which is stupid!
echo(bms_placement + bms);
echo(screen_driver_assembly_placement + screen_driver_assembly_usable_area_1);
echo((bms_placement + bms).y < (screen_driver_assembly_placement + screen_driver_assembly_usable_area_1).y);

battery_placement = screen_driver_assembly_placement + screen_driver_assembly_usable_area_1 + dotmul(wall, [1, 1, 0]);

totalboxsize = maxvector([
battery_placement + battery,
bms_placement + bms,
screen_driver_assembly_placement + screen_driver_assembly,
]) + wall;

echo(totalboxsize);

module screw(){
    cylinder(h = long_extension, d = screw_hole_dia);
    translate([0, 0, totalboxsize.z - screw_nut_height])
    linear_extrude(long_extension)
    reg_polygon(6, screw_nut_dia / 2);
}

module box_with_battery_hole() {
    module rib() {
        translate([0, - wall[1] / 2, 0])
        cube([sqrt(battery[0] * battery[0] + battery[1] * battery[1]), wall[1], battery[2]]);
    }
    union(){
        difference(){
            translate(totalboxsize / 2)
            roundedBox(totalboxsize, wall.x, sidesonly = true);
            translate(battery_placement) cube(battery);
        }
        translate(battery_placement){
            rotate([0, 0, atan2(battery[0], battery[1])]) rib();
            translate([0, battery[1], 0])
            rotate([0, 0, - atan2(battery[0], battery[1])]) rib();
        }
    }
}

module box_with_holes(){
    difference(){
        box_with_battery_hole();

        translate(screen_driver_assembly_placement) screen_driver_assembly();
        translate(bms_placement) bms();
        translate(battery_placement) battery();
        translate(screw_hole_pos) screw();
    }
}

module lower_part() {
    difference(){
        // take off the top of the box
        intersection(){
            box_with_holes();
            cube(totalboxsize - [0, 0, cap_split]);
        }
        // cut a hole for the insertion of the BMS
        translate(bms_placement + dotmul(bms, [0, 0, 1]))
        linear_extrude(long_extension, convexity = 2)
        projection()
        bms();
        // wiring hole
        translate(screen_driver_assembly_placement + screen_driver_assembly_usable_area_2 + [0, wall.y + bms_back_parts + bms_thickness + bms_parts, 0])
        cube([wall.x + (bms_width - bms_usb_width) / 2, battery_placement.y - bms_placement.y - bms_back_parts - bms_thickness - bms_parts, long_extension]);
    }
}

lower_part();

module cap() {
    union(){
        // take off bottom of the box
        intersection(){
            box_with_holes();
            translate([0, 0, totalboxsize.z - cap_split])
            cube([totalboxsize.x, totalboxsize.y, cap_split]);
        }
        // add some retention to the BMS. I have no idea how that will print, but worst comes to worst,
        // I will just break it off, an replace it with PMMA.
        translate(bms_placement + dotmul(bms, [0, 0, 1]))
        linear_extrude((totalboxsize - bms_placement - bms).z - cap_split, convexity = 2)
        projection()
        bms();
    }
}

translate(dotmul(totalboxsize, [2.1, 0, 1]))
rotate([0, 180, 0])
cap();
