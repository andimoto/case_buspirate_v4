
// Draw a torus that results from rotating
// a rounded square of size side_h,side_w and corner radius r
module torus(r, turn_r = 0, side_h = 0, side_w = 0) {
  rotate_extrude(convexity = 2) 
    translate([r + turn_r + side_w, 0, 0]) hull() {
      circle(r);
      translate([0, -side_h, 0]) circle(r);
      translate([-side_w, 0, 0]) circle(r);
      translate([-side_w, -side_h, 0]) circle(r);
    }
}


// TODO: Test quarterTorus
module quarterTorus(r, turn_r = 0, side_h = 0) {
  total_r = turn_r + 2*r + side_h;
  difference() {
    torus(r, turn_r = turn_r, side_h = side_h);
    translate(-total_r * [1, 1, 1]) cube(total_r * [2,1,2]);
    translate(-[total_r, 0.1, total_r]) cube(total_r * [1,1,2]);
  }
}

module fillet(h, r) {
  difference() {
     cube([h, r, r]);
     translate([-0.1, r, r]) rotate([0, 90, 0]) cylinder(h = h+.2, r = r);
  }
}

module elongatedCylinder(h, r, side = 0) {
  linear_extrude(height=h, convexity=2) hull() {
    circle(r);
    translate([0,side,0]) circle(r);
  }
}


module roundedCube4(dim, r, center=false) {
  width = dim[0];
  height = dim[1];
  depth = dim[2];
  centerx = (center[0] == undef ? center : center[0]);
  centery = (center[1] == undef ? center : center[1]);
  centerz = (center[2] == undef ? center : center[2]);
  translate([centerx ? -width/2 : 0, centery ? -height/2 : 0, centerz ? -depth/2 : 0]) union() {
    translate([0, r, 0]) cube([width, height-2*r, depth]);
    translate([r, 0, 0]) cube([width-2*r, height, depth]);
    for (xy = [[r, r], 
               [r, height-r], 
               [width-r, r], 
               [width-r, height-r]]) {
      translate([xy[0], xy[1], 0]) cylinder(r = r, h = depth);
    }
  }
}

// TODO FIXME: dim[2] is not obeyed and top is filleted when dim[2] is >r but <2*r, because corner sphere diameter exceeds height  (should be a half-sphere, in principle)
module roundedCube6(dim, r, center=false) {
  width = dim[0];
  height = dim[1];
  depth = dim[2];
  centerx = (center[0] == undef ? center : center[0]);
  centery = (center[1] == undef ? center : center[1]);
  centerz = (center[2] == undef ? center : center[2]);
  translate([r - (centerx ? width/2 : 0), r - (centery ? height/2 : 0), r - (centerz ? depth/2 : 0)]) hull() {
    // Edges
    translate([0, 0, 0]) rotate([-90, 0, 0]) cylinder(h = height-2*r,r = r);
    translate([width-2*r, 0, 0]) rotate([-90, 0, 0]) cylinder(h = height-2*r,r = r);
    translate([0, 0, 0]) rotate([0, 90, 0]) cylinder(h = width-2*r, r = r);
    translate([0, height-2*r, 0]) rotate([0, 90, 0]) cylinder(h = width-2*r, r = r);
    translate([0, 0, 0]) cylinder(h = depth-r, r = r);
    translate([width-2*r, 0, 0]) cylinder(h = depth-r, r = r);
    translate([0, height-2*r, 0]) cylinder(h = depth-r, r = r);
    translate([width-2*r, height-2*r, 0]) cylinder(h = depth-r, r = r);

    // Corners
    translate([0,0,0]) sphere(r);
    translate([width-2*r, 0, 0]) sphere(r);
    translate([0, height-2*r, 0]) sphere(r);
    translate([width-2*r, height-2*r, 0]) sphere(r);
  }
}

module roundedCube8(dim, r, center=false) {
  width = dim[0];
  height = dim[1];
  depth = dim[2];
  centerx = (center[0] == undef ? center : center[0]);
  centery = (center[1] == undef ? center : center[1]);
  centerz = (center[2] == undef ? center : center[2]);
  translate([r - (centerx ? width/2 : 0), r - (centery ? height/2 : 0), r - (centerz ? depth/2 : 0)]) hull() {
    // Edges (bottom)
    translate([0, 0, 0]) rotate([-90, 0, 0]) cylinder(h = height-2*r,r = r);
    translate([width-2*r, 0, 0]) rotate([-90, 0, 0]) cylinder(h = height-2*r,r = r);
    translate([0, 0, 0]) rotate([0, 90, 0]) cylinder(h = width-2*r, r = r);
    translate([0, height-2*r, 0]) rotate([0, 90, 0]) cylinder(h = width-2*r, r = r);
    // Edges (vertical)
    translate([0, 0, 0]) cylinder(h = depth-2*r, r = r);
    translate([width-2*r, 0, 0]) cylinder(h = depth-3*r, r = r);
    translate([0, height-2*r, 0]) cylinder(h = depth-2*r, r = r);
    translate([width-2*r, height-2*r, 0]) cylinder(h = depth-2*r, r = r);
    // Edges (top): not needed with hull()

    // Corners (bottom)
    translate([0, 0, 0]) sphere(r);
    translate([width-2*r, 0, 0]) sphere(r);
    translate([0, height-2*r, 0]) sphere(r);
    translate([width-2*r, height-2*r, 0]) sphere(r);
    // Corners (top)
    translate([0, 0, depth-2*r]) sphere(r);
    translate([width-2*r, 0, depth-2*r]) sphere(r);
    translate([0, height-2*r, depth-2*r]) sphere(r);
    translate([width-2*r, height-2*r, depth-2*r]) sphere(r);

  }
}

module hollowCube(inner_dim, thickness) {
  in_w = inner_dim[0];
  in_h = inner_dim[1];
  in_d = inner_dim[2];
  t = thickness;
  difference() {
    translate([-t, -t, -t])
      cube([in_w+2*t, in_h+2*t, in_d+t]);
    cube([in_w, in_h, in_d+t+.2]);
  }
}

// r is inner radius
module hollowCube4(inner_dim, thickness, r = -1) {
  in_w = inner_dim[0];
  in_h = inner_dim[1];
  in_d = inner_dim[2];
  t = thickness;
  rad = (r < 0) ? thickness : r;
  difference() {
    translate([-t, -t, -t])
      roundedCube4([in_w+2*t, in_h+2*t, in_d+t], 2*rad);
    roundedCube4([in_w, in_h, in_d+t+.2], rad);
  }
}

module hollowCube6(inner_dim, thickness, r = -1) {
  in_w = inner_dim[0];
  in_h = inner_dim[1];
  in_d = inner_dim[2];
  t = thickness;
  rad = (r < 0) ? thickness : r;
  difference() {
    translate([-t, -t, -t])
      roundedCube6([in_w+2*t, in_h+2*t, in_d+t], 2*rad);
    roundedCube6([in_w, in_h, in_d+t+.2], rad);
  }
}


module roundedSquare(dim, r, center=false) {
  width = dim[0];
  height = dim[1];
  centerx = (center[0] == undef ? center : center[0]);
  centery = (center[1] == undef ? center : center[1]);
  translate([r - (centerx ? width/2 : 0), r - (centery ? height/2 : 0), 0]) hull() {
    // Corners
    translate([0, 0, 0]) circle(r = r); 
    translate([width-2*r, 0, 0]) circle(r = r);
    translate([0, height-2*r, 0]) circle(r = r);
    translate([width-2*r, height-2*r, 0]) circle(r = r);
  }
}

module roundedCylinder(r, h, r2, center=false, fn2=18) {
  rotate_extrude() 
    intersection() {
      roundedSquare([2*r, h], r=r2, center=[true, center], $fn=fn2);
      translate([0, -1-(center ? h/2 : 0), 0]) square([r+1, h+2]);
    }
}

module standoffHole(r, thick, height, screw_depth = height) {
  difference() {
    cylinder(r=r+thick, h=height);
    if (screw_depth < height) {
      translate([0, 0, height-screw_depth]) cylinder(r=r, h=screw_depth+1);
    } else {
      translate([0, 0, -1]) cylinder(r=r, h=height+2);
    }
  }
}

module standoffPeg(r, height = 5, raise = 5, thick = 1.5) {
  union() {
    cylinder(r=r+thick, h=raise);
    translate([0,0,raise-.05]) cylinder(r=r-0.2, h=height+.05);
  }
}

