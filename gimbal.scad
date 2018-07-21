include <lib/screw-and-nuts.scad>

// Print helper setting
play = 0.2;
enableBridgeSupport = false;
layerHeight = 0.20; // Layer height is used to create bridge support for holes

// Core bearing dimensions
coreBearingOuterDiameter = 22;
coreBearingHeight=7;

// Axle bearing dimensions
bearingOuterDiameter=10;
bearingRollerDiameter=bearingOuterDiameter-2;
bearingHeight=4;

// Space between core and primary ring, primary and secondary ring
ringSpacing = 3;

// Minimal thickness for walls
wallThickness = 3;

// Extra height for stability
ringExtraHeight = 1;
ringHeight = bearingOuterDiameter + 2*wallThickness + ringExtraHeight;

// Things mounted on the axle that has the potential of beeing wider then the ringSpacing
axleMountAdditionWidth = 1 /* washer */ + hexNutDin934Thickness[5];

// How much of the axle mount sticks into the ring
axleMountRingInset = max(axleMountAdditionWidth - ringSpacing, 0);
$fn=32;

module Din933Bolt(m, length, needsBridgeSupport=false) {
  innerRadius = hexNutWidthAcrossFlats[m]/2;
  outerRadius = outerHexDiameter(innerRadius*2)/2;

  threadOffset = needsBridgeSupport && enableBridgeSupport ? layerHeight : -0.01;
  color("lightgrey") union() {
    // Hex head
    cylinder(r=outerRadius + 0.5*play, h=hexHeadDin933Thickness[m]+play, $fn=6);

    // thread
    translate([0, 0, hexHeadDin933Thickness[m] + play + threadOffset]) cylinder(r=m/2 + 0.5 * play, h=length-threadOffset);
  }
}

module Din934HexBolt(m, length, needsBridgeSupport=false, headExtraPenetratingHeight=0) {
  // headExtraPenetratingHeight add height to the head so it can be subtracted to create deep pockets
  diameter = outerHexDiameter(hexNutWidthAcrossFlats[m]);
  threadOffset = needsBridgeSupport && enableBridgeSupport ? layerHeight : -0.01;

  color("lightgrey") {
    translate([0, 0, -headExtraPenetratingHeight]) cylinder(r=diameter / 2 + play / 2, h=hexNutDin934Thickness[m]+headExtraPenetratingHeight, $fn=6);
    translate([0, 0, hexNutDin934Thickness[m]+threadOffset]) cylinder(r=m/2+play/2, h=length-hexNutDin934Thickness[m]-threadOffset+0.02);
  }
}

module clampingBolt(m, length, radius, orientation, headExtraPenetratingHeight=0) {
  sinkHeight = headDin9771Thickness[m];
  color("lightgrey") rotate([0, 0, orientation]) translate([radius, 0, -0.01]) rotate([0, 0, 30]) {
    Din933Bolt(m, length-sinkHeight, needsBridgeSupport=true);
    translate([0, 0, length-sinkHeight-play]) cylinder(r1=m/2, r2=Din9771_d2[m]/2, h=sinkHeight+0.02);
    translate([0, 0, length-play]) cylinder(r=Din9771_d2[m]/2, h=sinkHeight+headExtraPenetratingHeight);
  }
}

module hole(diameter, radius, orientation, length) {
  rotate([0, 0, orientation]) translate([radius, 0, 0]) cylinder(r=diameter/2, h=length);
}

module lowerHalf() {
  difference() {
    union() {
      children();
    };
    translate([0, 0, ringHeight/2]) cylinder(r=1000, h=5*ringHeight);
  }
}

module upperHalf(mirrored=true) {
  translate([0, 0, mirrored ? ringHeight : 0]) mirror([0, 0, mirrored ? 1 : 0]) difference() {
    union() {
      children();
    };
    translate([0, 0, -5*ringHeight]) cylinder(r=1000, h=5*ringHeight+0.5*ringHeight+0.01);
  }
}

function innerHexDiameter(outerDiameter) = (sqrt(3) / 2 * (outerDiameter/2)) * 2;
function outerHexDiameter(innerDiameter) = ((innerDiameter/2) / (sqrt(3) / 2)) * 2;

function aOfOctagonForDiameter(outerDiameter) = outerDiameter / sqrt(4+2*sqrt(2));
function aOfOctagonForInnerDiameter(innerDiameter) = innerDiameter / 2 * (1 + sqrt(2));

function innerOctDiameter(outerDiameter) = aOfOctagonForDiameter(outerDiameter) * (1 + sqrt(2));
function outerOctDiameter(innerDiameter) = aOfOctagonForInnerDiameter(innerDiameter) / 2 * sqrt(4+2*sqrt(2));

module ZFF() {
  translate([0,0,-0.1]) scale([1, 1, 1.1]) children(0);
}

module axleBearingNegative() {
  color("lightgrey") {
    cylinder(r=0.5*bearingOuterDiameter + 0.5*play, h=bearingHeight);
    bearingCasingWidth = 1.5;
    translate([0, 0, bearingHeight-0.01]) cylinder(r=0.5*bearingOuterDiameter - bearingCasingWidth, h=2*bearingHeight);
  }
  
  // M5 hex nut inset, does not bear any load
  m5NutDiameter = outerHexDiameter(hexNutWidthAcrossFlats[5])+2*play;
  color("grey") translate([0, 0, -2*bearingHeight+0.01]) cylinder(r=m5NutDiameter/2, h=bearingHeight*2);
}

module coreBearingNegative() {
  color("lightgrey") translate([0, 0, -0.5*coreBearingHeight]) {
    cylinder(r=0.5*coreBearingOuterDiameter + 0.5*play, h=coreBearingHeight);
    translate([0, 0, coreBearingHeight-0.01]) cylinder(r=0.5*coreBearingOuterDiameter-2, h=2*coreBearingHeight);
    translate([0, 0, -2*coreBearingHeight+0.01]) cylinder(r=0.5*coreBearingOuterDiameter-2, h=2*coreBearingHeight);
  }
}

coreDiameter = outerOctDiameter(hexHeadDin933Thickness[5] * 2 + wallThickness * 2) + coreBearingOuterDiameter;
module core(crosssection=false) {
  hexNutRadius = coreBearingOuterDiameter/2+wallThickness-1;

  clampAngles = [45+22.5, 180-22.5, -90-22.5, -22.5];
  clampingRadius = coreBearingOuterDiameter / 2 + wallThickness/2 + hexNutDin934Thickness[4]/2;

  cylinderHeight = crosssection ? ringHeight/2 : ringHeight;
  difference() {
    // Ring
    cylinder(r=0.5*coreDiameter, h=cylinderHeight, $fn=8);
    translate([0, 0, 0.5 *  ringHeight]) coreBearingNegative();

    // Axis bolts
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 22.5]) rotate([0, 90, 0]) translate([0, 0, hexNutRadius]) Din933Bolt(5, 20);
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 22.5]) rotate([0, 270, 0]) translate([0, 0, hexNutRadius]) Din933Bolt(5, 20);

    for (angle=clampAngles) clampingBolt(3, ringHeight, clampingRadius, angle);
  }
}

primaryRingInnerDiameter = coreDiameter + 2 * ringSpacing;
primaryRingOuterDiameter = primaryRingInnerDiameter + 4*wallThickness + 2*hexHeadDin933Thickness[5] + 2*axleMountRingInset;
module primaryRing(crosssection=false) {
  /* Washer + DIN-125 M5 Hex nut */
  bearingRadius = innerHexDiameter(coreDiameter) / 2 + ringSpacing + 1 /* FIXME: not-derived-constant */ + axleMountRingInset;
  boltRadius = innerOctDiameter(primaryRingOuterDiameter)/2 - hexHeadDin933Thickness[5] - wallThickness;

  clampRadius = (primaryRingOuterDiameter+primaryRingInnerDiameter) / 2 / 2 - 0.6 /* FIXME: not-derived-constant */;

  clampAngles = [
    22.5*0,
    22.5*2,
    22.5*4,
    22.5*6,
    22.5*8,
    22.5*10,
    22.5*12,
    22.5*14,
  ];

  cylinderHeight = crosssection ? ringHeight/2 : ringHeight;
  difference() {
    // Ring
    cylinder(r=primaryRingOuterDiameter/2, h = cylinderHeight, $fn=8);
    ZFF() cylinder(r=primaryRingInnerDiameter/2, h = cylinderHeight, $fn=8);

    // Bearings
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) axleBearingNegative();
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 180+22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) axleBearingNegative();

    // Axis bolts
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 90+22.5]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(5, 20);
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 270+22.5]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(5, 20);

    for (angle=clampAngles) clampingBolt(3, ringHeight, clampRadius, angle);
  }
}

secondaryRingInnerDiameter = primaryRingOuterDiameter + 2 * ringSpacing;
secondaryRingOuterDiameter = secondaryRingInnerDiameter + 4*wallThickness + bearingHeight+2 + axleMountRingInset*2;

module secondaryRing(crosssection=false) {
  bearingRadius = innerOctDiameter(secondaryRingInnerDiameter)/2 + axleMountRingInset;
  bearingLocations = [
    90+22.5,
    270+22.5
  ];
  
  clampRadius = bearingRadius+6;
  clampAngles = [
    22.5*0,
    22.5*2,
    22.5*4,
    22.5*6,
    22.5*8,
    22.5*10,
    22.5*12,
    22.5*14,
  ];
  
  boltRadius = innerOctDiameter(secondaryRingInnerDiameter)/2;
  boltLocations = [
    180+22.5,
    22.5
  ];

  cylinderHeight = crosssection ? ringHeight/2 : ringHeight;
  difference() {
    // Ring
    cylinder(r=secondaryRingOuterDiameter/2, h = cylinderHeight, $fn=8);
    ZFF() cylinder(r=secondaryRingInnerDiameter/2, h = ringHeight, $fn=8);

    // Bearings
    for (angle = bearingLocations) 
      translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, angle]) rotate([0, -90]) translate([0, 0, bearingRadius]) axleBearingNegative();

    for (angle=clampAngles) clampingBolt(3, ringHeight, clampRadius, angle);
    for (angle=boltLocations) rotate([0, 0, angle]) translate([boltRadius-0.01, 0, 0.5*ringHeight]) rotate([0, 90]) rotate([0, 0, 90]) Din933Bolt(5, 20);
  }
}

translate([0, 0, -ringHeight-5]) {
  //core();
  //cylinder(r=4, h=3*ringHeight);
}

module gimbalLowerHalf() {
  enableBridgeSupport = true;
  lowerHalf() {
    core();
    primaryRing();
    secondaryRing();
  }
}

module gimbalUpperHalf() {
  enableBridgeSupport = false;
  upperHalf() {
    core();
    primaryRing();
    secondaryRing();
  }
}

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

module handle() {
  angle = 70;
  mountHeight=ringHeight*1.25;
  mountWidth=mountHeight;
  difference() {
    cube([wallThickness+bearingHeight, mountWidth, mountHeight]);
    
    // Subtract bearing
    translate([wallThickness+bearingHeight, 0.5*mountHeight, 0.5*mountHeight]) rotate([0, -90, 0]) axleBearingNegative();
  }
  hull() {
    translate([0, -1, 0]) cube([wallThickness+bearingHeight, 1, mountHeight]);
    rotate([0, 0, -angle]) translate([0, -10, 0]) cube([wallThickness+bearingHeight, 1, mountHeight]);
  }
  //rotate([]) cylinder(r=15, h=20);

}

//handle();

module crosssection() {
  core(crosssection=true);
  primaryRing(crosssection=true);
  secondaryRing(crosssection=true);
}
//crosssection();
preview();
//rotate([0, 0, -22.5])crosssection();

//preview();
/*translate([0, 0, 25]) cube([1, 1, 1]);
translate([0, 0, 0]) {
  mount();
}*/

//enableBridgeSupport=true;
//upperHalf() secondaryRing();
//upperHalf(mirrored=false) mount();
