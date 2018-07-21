include <gimbal.scad>
mountBaseHeight = ringHeight;
mountDiameter = coreDiameter / 2.7;

m3HexNutOuterDiameter = 5.5;
couplingHeight = m3HexNutOuterDiameter+wallThickness;
couplingWidth = mountDiameter/2;
module coupling(couplingWidth=couplingWidth) {
  intersection() {
    scale([1, 4, 1]) rotate([0, 0, 45]) cylinder(r1=couplingWidth, r2=couplingWidth+wallThickness, h=couplingHeight, $fn=4, center=false);
    cylinder(r=mountDiameter, h=couplingHeight);
  }
}

// Cutout Dimensions
cutoutLength=16;
cutoutDiameter=3+2*play;

module cameraMount() {
   quarterInchScrewDiameter=5.5;
   cameraMountScrewHeight=10;
  
   // Slider
   difference() {
      union() {
        cylinder(r=mountDiameter, h=mountBaseHeight);
        
        hull() {
          translate([couplingWidth, -0.5*cutoutLength-1.5*wallThickness, 0]) cube([0.1, cutoutLength+3*wallThickness, mountBaseHeight-4]);
          translate([mountDiameter-wallThickness, -0.5*cutoutLength-0.5*wallThickness, 0]) cube([wallThickness, cutoutLength+wallThickness, couplingHeight]);
        }
      }
      translate([0, 0, -0.01]) scale([(couplingWidth+play)/couplingWidth, 2, (couplingHeight+play+0.02)/couplingHeight]) coupling();
      translate([0, 0, mountBaseHeight-cameraMountScrewHeight]) cylinder(r=quarterInchScrewDiameter/2, h=cameraMountScrewHeight+0.01);
      translatorShaftCutout();
      translate([mountDiameter/2-5, 0, 0.5*couplingHeight]) mirror([1, 0, 0]) rotate([0, -90, 0]) rotate([0, 0, 30]) Din934HexBolt(m=3, length=mountDiameter, headExtraPenetratingHeight=40);
   }

}

module mount() {
  clampRadius = mountDiameter/2+2;
  clampAngles = [
    90,
    270
  ];
  
  clampAngles2 = [
    0,
    180,
  ];

  difference() {
    // M8 Hex nut compartment
    union() {
      difference() {
        cylinder(r=mountDiameter, h=mountBaseHeight);
        ZFF() translate([0, 0, mountBaseHeight/2+hexNutDin934Thickness[8]/2]) mirror([0, 0, 1]) Din934HexBolt(8, 20, needsBridgeSupport=true);
      }
    
      // Slider
      translate([0, 0, mountBaseHeight]) {
        difference() {
          coupling(couplingHeight);
          
          // Setscrew
          hull() {
            translate([mountDiameter/2-1.8, -6, 0.5*couplingHeight]) rotate([0, -90, 0]) rotate([0, 0, 30]) Din934HexBolt(m=3, length=0, headExtraPenetratingHeight=1.8);
            translate([mountDiameter/2-1.8, +6, 0.5*couplingHeight]) rotate([0, -90, 0]) rotate([0, 0, 30]) Din934HexBolt(m=3, length=0, headExtraPenetratingHeight=1.8);
          }
          translate([-20, 0]) translatorShaftCutout(length=13);
        }
      }
    }
        
    // Screws
    for (angle=clampAngles) clampingBolt(3, mountBaseHeight, clampRadius, angle, headExtraPenetratingHeight=20);
    for (angle=clampAngles2) clampingBolt(3, mountBaseHeight, clampRadius, angle, headExtraPenetratingHeight=0);
  }
}

mount();
translate([0, 10, mountBaseHeight]) cameraMount();

module translatorShaftCutout(length=cutoutLength) {
   translate([0, -0.5*length, 0.5*couplingHeight]) rotate([90, 0, 90]) cutout(diameter=cutoutDiameter, length=length, depth=40);
}

module cutout(diameter=5, length=10, depth=3) {
   // Cutout Dimensions
   cutoutLength=16;
   cutoutDiameter=3+2*play;

  translate([0.5*diameter, 0]) { 
    cylinder(r=diameter/2, h=depth);
    translate([0.5*(length-diameter), 0, 0.5*depth]) cube([length-diameter, diameter, depth], center=true);
    translate([length-diameter, 0]) cylinder(r=diameter/2, h=depth);
  }
}