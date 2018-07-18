play=0.25;
layerHeight=0.25;
enableBridgeSupport=false;

coreBearingOuterDiameter = 22;
coreBearingHeight=7;

bearingOuterDiameter=10;
bearingRollerDiameter=bearingOuterDiameter-2;
bearingHeight=4;

ringSpacing=6;

wallThickness = 3;
bottomThickness = 3;
innerThreadDiameter = 5;
ringHeight = bearingOuterDiameter+2*wallThickness;
$fn=32;

headDin9771Thickness = [
  0,
  0, // M1
  0, //
  1.86,
  2.48,
  3.1,
  3.72,
  0, // NO M7
  4.96,
];

Din9771_d2 = [
  0,
  0, // M1
  0, //
  6.72,
  8.96,
  10.2,
  13.44,
  0, // NO M7
  17.92,
];

hexHeadDin933Thickness=[
  0,
  0, // M1
  1.3,
  2,
  2.8,
  3.5,
  4,
  4.8,
  5.3,
];

hexNutDin934Thickness=[
  0,
  0, // M1
  1.6,
  2.4,
  3.2,
  4,
  5,
  0, // M7 not found
  6.5
];

hexNutWidthAcrossFlats=[
  0,
  0, //M1
  4,
  5.5,
  7,
  8,
  10,
  11,
  13
];

module Din933Bolt(m, length, needsBridgeSupport=false) {
  innerRadius = hexNutWidthAcrossFlats[m]/2;
  outerRadius = outerHexDiameter(innerRadius*2)/2;

  threadOffset = needsBridgeSupport && enableBridgeSupport ? layerHeight : -0.01;
  union() {
    // Hex head
    cylinder(r=outerRadius + 0.5*play, h=hexHeadDin933Thickness[m], $fn=6);

    // thread
    translate([0, 0, hexHeadDin933Thickness[m] + threadOffset]) cylinder(r=m/2 + 0.5 * play, h=length-threadOffset);
  }
}

module Din934HexBolt(m, length) {
  diameter = outerHexDiameter(hexNutWidthAcrossFlats[m]);
  cylinder(r=diameter / 2 + play / 2, h=hexNutDin934Thickness[m], $fn=6);
  translate([0, 0, hexNutDin934Thickness[m]-0.01]) cylinder(r=m/2+play/2, h=length-hexNutDin934Thickness[m]+0.02);
}

module clampingBolt(m, length, radius, orientation) {
  sinkHeight = headDin9771Thickness[m];
  rotate([0, 0, orientation]) translate([radius, 0, -0.01]) rotate([0, 0, 30]) {
    Din933Bolt(m, length-sinkHeight, needsBridgeSupport=true);
    translate([0, 0, length-sinkHeight]) cylinder(r1=m/2, r2=Din9771_d2[m]/2, h=sinkHeight+0.02);
  }
}

module lowerHalf() {
  difference() {
    union() {
      children();
    };
    translate([0, 0, ringHeight/2]) cylinder(r=1000, h=0.5*ringHeight+0.01);
  }
}

module upperHalf() {
  translate([0, 0, ringHeight]) mirror([0, 0, 1]) difference() {
    union() {
      children();
    };
    translate([0, 0, -0.1]) cylinder(r=1000, h=0.5*ringHeight+0.01);
  }
}

function innerHexDiameter(outerDiameter) = (sqrt(3) / 2 * (outerDiameter/2)) * 2;
function outerHexDiameter(innerDiameter) = ((innerDiameter/2) / (sqrt(3) / 2)) * 2;

function aOfOctagonForDiameter(outerDiameter) = outerDiameter / sqrt(4+2*sqrt(2));
function aOfOctagonForInnerDiameter(innerDiameter) = innerDiameter / 2 * (1 + sqrt(2));

function innerOctDiameter(outerDiameter) = aOfOctagonForDiameter(outerDiameter) / 2 * (1 + sqrt(2));
function outerOctDiameter(innerDiameter) = aOfOctagonForInnerDiameter(innerDiameter) / 2 * sqrt(4+2*sqrt(2));

module ZFF() {
  translate([0,0,-0.1]) scale([1, 1, 1.1]) children(0);
}

module bbNegative() {
  translate([0, 0, -0.5*bearingHeight]) {
    cylinder(r=0.5*bearingOuterDiameter + 0.5*play, h=bearingHeight);
    translate([0, 0, bearingHeight-0.01]) cylinder(r=0.5*bearingOuterDiameter-2, h=2*bearingHeight);
    translate([0, 0, -2*bearingHeight+0.01]) cylinder(r=0.5*bearingOuterDiameter-2, h=2*bearingHeight);
  }
}

module coreBearingNegative() {
  translate([0, 0, -0.5*coreBearingHeight]) {
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

primaryRingInnerDiameter = coreDiameter + ringSpacing;
primaryRingOuterDiameter = primaryRingInnerDiameter + 4*wallThickness + 2*hexHeadDin933Thickness[5];
module primaryRing(crosssection=false) {
  bearingRadius = innerHexDiameter(primaryRingInnerDiameter) / 2 + bearingHeight-0.6;
  boltRadius = innerOctDiameter(primaryRingOuterDiameter) - hexHeadDin933Thickness[5] - wallThickness;

  clampRadius = primaryRingInnerDiameter / 2 + wallThickness -0.66;

  clampAngles = [
    [22.5*3, clampRadius], 
    [22.5*7, clampRadius], 
    [22.5*11, clampRadius], 
    [22.5*15, clampRadius], 
  ];

  cylinderHeight = crosssection ? ringHeight/2 : ringHeight;
  difference() {
    // Ring
    cylinder(r=primaryRingOuterDiameter/2, h = cylinderHeight, $fn=8);
    ZFF() cylinder(r=primaryRingInnerDiameter/2, h = ringHeight, $fn=8);

    // Bearings
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 180+22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();

    // Axis bolts
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 90+22.5]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(5, 20);
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 270+22.5]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(5, 20);

    for (tuple=clampAngles) clampingBolt(3, ringHeight, tuple[1], tuple[0]);
  }
}

secondaryRingInnerDiameter = primaryRingOuterDiameter + ringSpacing;
secondaryRingOuterDiameter = secondaryRingInnerDiameter + 4*wallThickness + bearingHeight+2;

module secondaryRing(crosssection=false) {
  bearingRadius = innerHexDiameter(secondaryRingInnerDiameter) / 2 + bearingHeight+0.4;

  innerClampRadius = bearingRadius+2;
  outerClampRadius = bearingRadius+3.7;
  clampRadius = bearingRadius+1.5;

  clampAngles = [
    [22.5*4.3, outerClampRadius],
    [22.5*5.7, outerClampRadius],
    [22.5*4.3 + 180, outerClampRadius],
    [22.5*5.7 + 180, outerClampRadius],

    [22.5*3, innerClampRadius], 
    [22.5*7, innerClampRadius], 
    [22.5*11, innerClampRadius], 
    [22.5*15, innerClampRadius], 
  ];

  cylinderHeight = crosssection ? ringHeight/2 : ringHeight;
  difference() {
    // Ring
    cylinder(r=secondaryRingOuterDiameter/2, h = cylinderHeight, $fn=8);
    ZFF() cylinder(r=secondaryRingInnerDiameter/2, h = ringHeight, $fn=8);

    // Bearings
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 90+22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 270+22.5]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();

    for (tuple=clampAngles) clampingBolt(3, ringHeight, tuple[1], tuple[0]);
  }
}

translate([0, 0, -ringHeight-5]) {
  //core();
  //cylinder(r=4, h=3*ringHeight);
}

mountBaseHeight = wallThickness+hexNutDin934Thickness[8];
module mount() {
  difference() {
    cylinder(r=coreDiameter/3, h=mountBaseHeight);
    ZFF() translate([0, 0, mountBaseHeight]) mirror([0, 0, 1]) Din934HexBolt(8, 20);
  }
}

module mountPlate() {
  difference() {
    cylinder(r=coreDiameter/3, h=wallThickness);
    ZFF() cylinder(r=4+play/2, h=wallThickness);
  }
}

module preview() {
  rotate([0, 0, -45]) union() {
    rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) core();
    rotate([20, 0, 0]) rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) primaryRing();
    rotate([2.8, 25, 10]) rotate([20, 0, 0]) rotate([0, 0, -22.5]) translate([0, 0, -0.5 * ringHeight]) secondaryRing(); 
  }
}

module crosssection() {
  core(crosssection=true);
  primaryRing(crosssection=true);
  secondaryRing(crosssection=true); 
}

//preview();
rotate([0, 0, -22.5])crosssection();

translate([0, 0, 25]) {
  /*mount();
  translate([0, 0, mountBaseHeight]) mountPlate();
  translate([0, 0, mountBaseHeight+wallThickness]) mountPlate();
*/
}