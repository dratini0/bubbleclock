function maxvector(vectors) = [for (index = [0:1:len(vectors[0]) - 1]) max([for (vector = vectors) vector[index]])];

function dotmul(a, b) = [for (index = [0:1:len(a) - 1]) a[index] * b[index]];

// unit: mm
mil = 0.0254;
wall = [-1, 1, 1];
long_extension = 10;

// BMS
bms_thickness = 1.1;
bms_length = 27.9;
bms_width = 17.2;
bms_parts = 1.4;
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
// protrusion for switch, still needs hole, maybe lever?
driver_back_bottom_porch = -1;
driver_right_edge_to_last_connector_center = 1.9;
driver_front_edge_to_connector_center = 1.9;

// battery (standard 18650)
battery_dia = 18;
battery_len = 65;
battery_padding_len = 3;

module battery(){
    translate([- battery_dia / 2, battery_dia / 2])
    cylinder(h = battery_len + battery_padding_len, d = battery_dia);
}

battery = [- battery_dia, battery_dia, battery_len + battery_padding_len];

module driver() {
    translate([- driver_width + driver_front_edge_to_connector_center, 0, -driver_right_edge_to_last_connector_center]) {
        // PCB
        translate([0, -driver_thickness, 0])
        cube([driver_width, driver_thickness, driver_length]);
        // front componets
        translate([driver_back_top_porch, 0, -driver_programming_connector_extension])
        cube([driver_width - driver_front_porch - driver_back_top_porch, driver_programming_connector_height, driver_length + driver_programming_connector_extension]);
        // back components
        translate([driver_back_bottom_porch, - driver_thickness - driver_bottom_component_height, 0])
        cube([driver_width - driver_front_porch - driver_back_bottom_porch, driver_bottom_component_height, driver_length]);
    }
}

//driver();

module screen() {
    translate ([0, - screen_bottom_edge_to_connector_center, - screen_right_edge_to_last_connector_center]) {
        cube([screen_pcb_thickness, screen_pcb_width, screen_pcb_length]);
        translate([screen_pcb_thickness, 0, screen_pcb_end_porch])
        cube([screen_bubble_thickness, screen_pcb_width - screen_pcb_top_porch, screen_pcb_length - 2 * screen_pcb_end_porch]);
    }
}

//screen();

module connector() {
    translate([0, 0, - connector_pitch / 2]) {
        //driver side
        translate([- connector_driver_center_to_screen_face - connector_width / 2, 0, 0])
        cube([connector_width, connector_screen_center_to_driver_face + connector_width / 2, connector_pitch * connector_pins]);
        //screen side
        translate([- connector_driver_center_to_screen_face - connector_width / 2, connector_screen_center_to_driver_face - connector_width / 2, 0])
        cube([connector_driver_center_to_screen_face + connector_width / 2, connector_width, connector_pitch * connector_pins]);
    }
}

module screen_driver_assembly() {
    //translate([connector_driver_center_to_screen_face + connector_width / 2, - driver_programming_connector_height, max(driver_right_edge_to_last_connector_center + driver_programming_connector_extension, screen_right_edge_to_last_connector_center)]) {
    translate([- screen_pcb_thickness - screen_bubble_thickness, driver_thickness + driver_bottom_component_height, max(driver_right_edge_to_last_connector_center + driver_programming_connector_extension, screen_right_edge_to_last_connector_center)]) {
        translate([- connector_driver_center_to_screen_face, 0, 0]) driver();
        translate([0, connector_screen_center_to_driver_face, 0]) screen();
        connector();
    }
}

screen_driver_assembly_usable_area_1 = [
- screen_pcb_thickness - screen_bubble_thickness - connector_driver_center_to_screen_face - connector_width / 2,
driver_thickness + driver_bottom_component_height + driver_programming_connector_height,
0,
];

screen_driver_assembly_usable_area_2 = [
- screen_pcb_thickness - screen_bubble_thickness,
driver_thickness + driver_bottom_component_height + connector_screen_center_to_driver_face + connector_width / 2,
0,
];

screen_driver_assembly = [
- (driver_width - min(0, driver_back_bottom_porch) - driver_front_edge_to_connector_center + connector_driver_center_to_screen_face + screen_pcb_thickness + screen_bubble_thickness),
screen_pcb_width - screen_bottom_edge_to_connector_center + connector_screen_center_to_driver_face + driver_thickness + driver_bottom_component_height,
max(driver_right_edge_to_last_connector_center + driver_programming_connector_extension, screen_right_edge_to_last_connector_center) +
max(driver_length - driver_right_edge_to_last_connector_center, screen_pcb_length - screen_right_edge_to_last_connector_center),
];

//screen_driver_assembly();

module bms() {
    translate([-bms_back_parts, 0, 0]) {
        translate([- bms_thickness, 0, 0])
        cube([bms_thickness, bms_width, bms_length]);
        translate([0, bms_porch, 0])
        cube([bms_back_parts, bms_width - 2 * bms_porch, bms_length]);
        translate([- bms_thickness - bms_parts, bms_porch, 0])
        cube([bms_parts, bms_width - 2 * bms_porch, bms_length]);
        translate([- bms_thickness - bms_usb_height, (bms_width - bms_usb_width) / 2, - long_extension])
        cube([bms_usb_height + bms_usb_underhang, bms_usb_width, long_extension + bms_length]);
    }
}

bms = 
[
- (bms_back_parts + bms_thickness + max(bms_usb_height, bms_parts)),
bms_width,
bms_length,
];

//bms();

screen_driver_assembly_placement = wall;
bms_placement = screen_driver_assembly_placement + screen_driver_assembly_usable_area_2 + dotmul(wall, [1, 1, 0]);
// we don't have assert yet here
// which is stupid!
echo((bms_placement + bms)[0] > (screen_driver_assembly_placement + screen_driver_assembly_usable_area_1)[0]);

battery_placement = screen_driver_assembly_placement + screen_driver_assembly_usable_area_1 + dotmul(wall, [1, 1, 0]);

totalboxsize = maxvector([
battery_placement + battery,
bms_placement + bms,
screen_driver_assembly_placement + screen_driver_assembly,
]);

echo(totalboxsize);

//difference(){
//translate(dotmul(totalboxsize, [1, 0, 0])) cube(dotmul(totalboxsize, [-1, 1, 1]));
    
translate(screen_driver_assembly_placement) screen_driver_assembly();
translate(bms_placement) bms();
translate(battery_placement) battery();
    
//}