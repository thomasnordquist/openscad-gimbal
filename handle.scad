include <lib/gimbal.scad>

module handle() {
  angle = 70;
  mountHeight=ringHeight*1.25;
  mountWidth=mountHeight;
  difference() {
    cube([wallThickness+bearingHeight, mountWidth, mountHeight]);
    
    // Subtract bearing
    //translate([wallThickness+bearingHeight, 0.5*mountHeight, 0.5*mountHeight]) rotate([0, -90, 0]) axleBearingNegative();
    translate([wallThickness+bearingHeight, 0.5*mountHeight, 0.5*mountHeight]) rotate([0, -90, 0]) cylinder(r=2.8, h=20);
  }
    gripDiameter=30;
  hull() {
    translate([0, -1, 0]) cube([wallThickness+bearingHeight, 1, mountHeight]);
    rotate([0, 0, -angle]) translate([0, -10, 0]) cube([wallThickness+bearingHeight, 1, mountHeight]);
    rotate([0, 0, -40]) translate([0, -10, gripDiameter/2]) rotate([90, 0, 0]) cylinder(r=gripDiameter/2, h=10);
  }
  rotate([0, 0, -40]) translate([0, -10, gripDiameter/2]) rotate([90, 0, 0]) translate([0, 0, 10]) cylinder(r=gripDiameter/2, h=140);
}

handle();
