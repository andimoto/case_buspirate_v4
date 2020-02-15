include <util.scad>
/* include <fonts/major_shift3D_03.ttf> */

/* include  */
FontMajorShift3D02="Major Snafu:style=3D\\_03";
Font=FontMajorShift3D02;

mil = 25.4/1000;

// BPv4 dimensions (mm)
w = 63.5;
h = 36.84;
corner_r = 1;
hole_ofs = 3.18;
hole_r = 3.2/2;

pcb_thk = 1.6;


// Connectors and LEDs
// TODO: Currently hardcoded in lid module

// Fasteners
nut_d = 6.1 + 0.5;  // M3
nut_h = 2.25;  // M3 (normal: 2.25mm; jam nut: 1.8mm)
screw_d = 5.55 + 0.30;  // M3 cap
screw_h = 2.9 + 0.2;  // M3 cap

// Case parameters
thk = 2;
standoff_h = 1.5;
standoff_thk = 1.6;
top_h = 6;
slack = 0.5;
hole_slack = 0.2;

module usb_mini_inner_profile() {
  // TODO: fix 3.1*{0.6,0.4}
  polygon([[-6.9/2, 3.1], [6.9/2, 3.1],
           [6.9/2, 3.1*0.6], [5.87/2, 3.1*0.4], [5.87/2, 0],
           [-5.87/2, 0], [-5.87/2, 3.1*0.4], [-6.9/2, 3.1*0.6]]);
}

usb_mini_thick = 0.5;
usb_mini_ih = 3.1;

module usb_mini_profile(h, ext=0) {
  translate([0, usb_mini_thick+ext, 0])
    linear_extrude(height=h) minkowski() {
      usb_mini_inner_profile();
      circle(r = usb_mini_thick+ext, $fn=18);
    }
}


module case() {
  d = standoff_h + pcb_thk + top_h;
  difference() {
    union() {
      // Main shell
      difference() {
        translate([0, 0, -thk])
          roundedCube4([w + 2*slack + 2*thk,
                        h + 2*slack + 2*thk,
                        d + thk],
                       r = corner_r + thk,
                       center = [true, true, false],
                       $fn=36);
        roundedCube4([w + 2*slack, h + 2*slack, d+1],
                     r = 0,//corner_r,
                     center = [true, true, false],
                     $fn=36);
      }
      // Standoffs
      for (i = [-1,+1], j=[-1,+1])
        translate([i*(w/2-hole_ofs), j*(h/2-hole_ofs), -thk])
          cylinder(r = hole_r + hole_slack + standoff_thk,
                   h = thk + standoff_h, $fn=27);
    }
    // Standoff holes
    for (i = [-1,+1], j=[-1,+1])
      translate([i*(w/2-hole_ofs), j*(h/2-hole_ofs), -thk-1]) {
        cylinder(r = hole_r + hole_slack,
                 h = thk + standoff_h + 2, $fn=27);
        cylinder(r = nut_d/2 + hole_slack, h = 1 + nut_h, $fn=6);
      }
    // Mini-USB
    translate([-w/2-slack+1, 0, standoff_h + pcb_thk]) rotate([90, 0, -90]) usb_mini_profile(thk+2, ext = hole_slack);
  }
}

module lid(name=true) {
  difference() {
    union() {
      roundedCube4([w + 2*slack + 2*thk,
                    h + 2*slack + 2*thk,
                    thk],
                   r = corner_r + thk,
                   center = [true, true, false],
                   $fn=36);
      // Standoffs
      for (i = [-1,+1], j=[-1,+1]) {
        translate([i*(w/2-hole_ofs), j*(h/2-hole_ofs), (thk + top_h)/2])
          cube(size = [2*(hole_r + hole_slack + standoff_thk),
                       2*(hole_r + hole_slack + standoff_thk),
                            thk + top_h], center = true);
/*
          translate([i*(w/2-hole_ofs), j*(h/2-hole_ofs), 0])
          cylinder(r = hole_r + hole_slack + standoff_thk,
                   h = thk + top_h, $fn=27); */

      }

    }

    if(name==true)
    rotate([180,0,180]) translate([-32,-2.6,-thk-0.1]) linear_extrude(thk+0.2)
    text("BUSPIRATE4",size=6,font=Font);

    // Standoff holes
    for (i = [-1,+1], j=[-1,+1])
      translate([i*(w/2-hole_ofs), j*(h/2-hole_ofs), -1]) {
        cylinder(r = hole_r + hole_slack,
                 h = thk + top_h + 2, $fn=27);
        cylinder(r = screw_d/2 + hole_slack, h = 1 + screw_h, $fn=27);
      }
    // ICSP header hole (center is 2.54mm from board edge)
    translate([1.24/2 - 1.24,  -h/2 + 2.54, -1])
      roundedCube4([500*mil + 2*hole_slack,
                    100*mil + 2*hole_slack,
                    thk + 2],
                   r = 20*mil,
                   center = [true, true, false],
                   $fn = 18);
    // Main header hole (center is 7.6mm from board edge)
    translate([-w/2 + 7.6,  0, -1])
      roundedCube4([350*mil + 2*hole_slack,
                    900*mil + 2*hole_slack,
                    thk + 2],
                   r = 10*mil,
                   center = [true, true, false],
                   $fn = 18);
    // LED holes (0805 chip, 1.4mm (1.6, bonus) from top edge, spaced 10.8mm)
    for (i = [-3, -1, +1, +3])
      translate([i*10.8/2 + 1.91/2, h/2 - 1.6, -1])
        roundedCube4([80*mil + 2*hole_slack,
                      50*mil + 2*hole_slack,
                      thk+2],
                     r = 10*mil,
                     center = [true, true, false], $fn=18);
    // Button holes
    for (i = [-1, +1])
      translate([i*13.08, -h/2 + 4.83, -1])
        roundedCube4([5.08,
                      5.08,
                      thk+2],
                     r = 10*mil,
                     center = [true, true, false], $fn=18);
  }
}

module buttons(string="."){
  union(){
    translate([0,0,-1])
    roundedCube4([4.8,
                  4.8,
                 top_h+1],
                 r = 10*mil,
                 center = [true, true, false], $fn=18);
    translate([0,0,thk+thk/3])
    roundedCube4([6,
                 6,
                top_h-thk-thk/3],
                r = 10*mil,
                center = [true, true, false], $fn=18);
               }
    rotate([0,180,0])
    translate([-1.2,-1.2,.5])
    linear_extrude(1) text(string,size=3,font=Font);
}

module lightGuides(){
    roundedCube4([75*mil + 2*hole_slack,
          45*mil + 2*hole_slack,
         top_h-thk],
         r = 10*mil,
         center = [true, true, false], $fn=18);
    translate([0, 0, thk+0.1]) {
        roundedCube4([100*mil + 2*hole_slack,
            100*mil + 2*hole_slack,
            top_h-thk/2-0.1],
            r = 10*mil,
            center = [true, true, false], $fn=18);
    }
}


echo("M3 cap screw length: ", thk + standoff_h + pcb_thk + top_h + thk - screw_h);


/* ###################################################################### */
/* ###################################################################### */
/* ############################   MODULES   ############################# */
/* ###################################################################### */
/* ###################################################################### */
/*
call "setForPrint()" to position all parts
call "builtUp(open=5,cut=true,cutAt=10)" to show bus pirate case
call "setLightGuidesForPrint()" to set light guides for printing with transparent filament
*/
module builtUp(open=5,cut=true,cutAt=10){
difference() {
    union(){
        color("blue") rotate([180,0,180]) translate([13.1, 9.8, -13-open]) buttons("N");
        color("red") rotate([180,0,180]) translate([-13.1, 9.8, -13-open]) buttons("R");
        translate([0, h/2 + 5, thk]) case();
        rotate([180,0,180]) translate([0, h/2 + 5, -13-open]) lid(name=true);
        color("white") rotate([180,0,180]) translate([17.15, 40.25, -13-open]) lightGuides();
        color("white") rotate([180,0,180]) translate([6.35, 40.25, -13-open]) lightGuides();
        color("white") rotate([180,0,180]) translate([-4.45, 40.25, -13-open]) lightGuides();
        color("white") rotate([180,0,180]) translate([-15.25, 40.25, -13-open]) lightGuides();
    }
    /* draw cut-through */
    if(cut == true) translate([40-cutAt,-50,-5]) cube([40+cutAt,100,20]);
    }
}

module setForPrint(setLightGuides=false){
  rotate([0,180,0]) translate([-13.1, -13.6-40, -(top_h)]) buttons("R");
  rotate([0,180,0]) translate([13.1, -13.6-40, -(top_h)]) buttons("N");
  rotate([0,0,180]) translate([0, 25, 0]) lid(name=true);
  translate([0, h/2 + 5, thk]) case();
  if(setLightGuides==true) translate([0, -65, 0]) setLightGuidesForPrint();
}

module setLightGuidesForPrint(){
    color("white") rotate([180,0,180]) translate([17.15, 0, -(top_h)]) lightGuides();
    color("white") rotate([180,0,180]) translate([6.35, 0, -(top_h)]) lightGuides();
    color("white") rotate([180,0,180]) translate([-4.45, 0, -(top_h)]) lightGuides();
    color("white") rotate([180,0,180]) translate([-15.25, 0, -(top_h)]) lightGuides();
}
/* setLightGuidesForPrint(); */
/* setForPrint(setLightGuides=false); */
translate([0,50,0]) builtUp(open=0,cut=false,cutAt=25);
