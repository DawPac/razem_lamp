to_render = "all"; // [text, lid, base, all]

text = "razem";
size = 300;
font = "Lato Black";

text_thickness = 50;
text_wall = 2;

lid_thickness = 0.4;
lip_height = 2;
lip_wall = 1;
clearance = 0.1;

base_wall = 2;
base_height = 10;
base_margin = 5;

pin_len = 5;
pin_wall = 1.5;
pin_grab = 0.2;
pin_clearance = 0.1;
przelot_over = 2;

explode = 50;

ref = 40;
tm_full = textmetrics(text, font = font, size = ref);
font_size = size * ref / tm_full.size[0];

function adv(i)  = textmetrics(text[i], font = font, size = font_size).advance[0];
function xpos(i) = i <= 0 ? 0 : xpos(i - 1) + adv(i - 1);
total_w = xpos(len(text));

function ma_atrament(i) =
    textmetrics(text[i], font = font, size = font_size).size[0] > 0;

module gliph(i) {
    translate([xpos(i), 0])
        text(text[i], font = font, size = font_size);
}

module foot(i) {
    if (ma_atrament(i))
        projection(cut = false)
            intersection() {
                rotate([90, 0, 0])
                    linear_extrude(height = text_thickness)
                        gliph(i);
                translate([-1e4, -text_thickness - 1, 0])
                    cube([2e4, text_thickness + 2, pin_grab]);
            }
}

module korytko(i) {
    linear_extrude(height = text_wall)
        gliph(i);
    linear_extrude(height = text_thickness)
        difference() {
            gliph(i);
            offset(delta = -text_wall) gliph(i);
        }
}

module litera(i) {
    difference() {
        union() {
            rotate([90, 0, 0]) korytko(i);
            translate([0, 0, -pin_len])
                linear_extrude(height = pin_len + text_wall + przelot_over)
                    foot(i);
        }
        translate([0, 0, -pin_len - 1])
            linear_extrude(height = pin_len + text_wall + przelot_over + 2)
                offset(delta = -pin_wall) foot(i);
    }
}

module pokrywka_flat(i) {
    linear_extrude(height = lid_thickness)
        gliph(i);
    translate([0, 0, lid_thickness])
        linear_extrude(height = lip_height)
            difference() {
                offset(delta = -(text_wall + clearance)) gliph(i);
                offset(delta = -(text_wall + clearance + lip_wall)) gliph(i);
            }
}

module pokrywka_stoja(i) {
    rotate([90, 0, 0]) {
        translate([0, 0, text_thickness])
            linear_extrude(height = lid_thickness)
                gliph(i);
        translate([0, 0, text_thickness - lip_height])
            linear_extrude(height = lip_height)
                difference() {
                    offset(delta = -(text_wall + clearance)) gliph(i);
                    offset(delta = -(text_wall + clearance + lip_wall)) gliph(i);
                }
    }
}

module podstawka() {
    ox = -base_margin;
    oy = -text_thickness - base_margin;
    bx = total_w + 2 * base_margin;
    by = text_thickness + 2 * base_margin;

    difference() {
        difference() {
            translate([ox, oy, -base_height])
                cube([bx, by, base_height]);
            translate([ox + base_wall, oy + base_wall, -base_height - 1])
                cube([bx - 2*base_wall, by - 2*base_wall, base_height - base_wall + 1]);
        }
        for (i = [0 : len(text) - 1])
            translate([0, 0, -pin_len])
                linear_extrude(height = pin_len + 0.01)
                    offset(delta = pin_clearance) foot(i);
    }
}

if (to_render == "text" || to_render == "all")
    for (i = [0 : len(text) - 1]) litera(i);

if (to_render == "base")
    podstawka();

if (to_render == "all")
    translate([0, 0, -explode]) podstawka();

if (to_render == "lid")
    for (i = [0 : len(text) - 1]) pokrywka_flat(i);

if (to_render == "all")
    for (i = [0 : len(text) - 1])
        translate([0, -explode, 0]) pokrywka_stoja(i);
