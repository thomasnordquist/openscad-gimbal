include <lib/gimbal.scad>

module preview() {
  rotate([0, 0, -45]) union() {
    rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) {
      core();
    }
    rotate([39, 0, 0]) rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) primaryRing();
    rotate([2.8, 25, 10]) rotate([20, 0, 0]) rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) {
      lowerHalf() secondaryRing();
      %upperHalf(mirrored=false) secondaryRing();
    }
  }
}

preview();