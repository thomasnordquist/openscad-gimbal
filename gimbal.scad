play=0.25;
layerHeight=0.25;
enableBridgeSupport=false;

bearingOuterDiameter=22;
bearingInnerDiameter=8;
bearingRollerDiameter=bearingInnerDiameter+2*2;
bearingHeight=7;

ringSpacing=12;

$fn=32;

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

hexNutThickness=[
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
  translate([0, 0, -0.5 * hexNutThickness[m]]) union() {
    // Hex head
    cylinder(r=outerRadius + 0.5*play, h=hexNutThickness[m], $fn=6);
    
    // thread
    translate([0, 0, hexNutThickness[m] + threadOffset]) cylinder(r=m/2 + 0.5 * play, h=length-threadOffset);
  }
}

wallThickness = 3.5;
bottomThickness = 3;
innerThreadDiameter = 5;
ringHeight = hexNutWidthAcrossFlats[8]+bottomThickness*2;

primaryRingDiameter = outerHexDiameter(hexNutThickness[8] * 2 + wallThickness * 4) + bearingOuterDiameter;

function innerHexDiameter(outerDiameter) = (sqrt(3) / 2 * (outerDiameter/2)) * 2;
function outerHexDiameter(innerDiameter) = ((innerDiameter/2) / (sqrt(3) / 2)) * 2;

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

module primaryRing() {
  hexNutRadius = innerHexDiameter(primaryRingDiameter)/2 - 2 * wallThickness;
  
  clampAngles = [80, 160, -100, -20];
  module clampingBolt(orientation) {
    ringRadius = innerHexDiameter(primaryRingDiameter)/2-wallThickness - hexNutThickness[4];
    rotate([0, 0, orientation]) translate([ringRadius, 0, -0.01]) Din933Bolt(4, ringHeight, needsBridgeSupport=true);
  }

  difference() {
    // Ring
    cylinder(r=0.5*primaryRingDiameter, h=ringHeight, $fn=6);
    translate([0, 0, 0.5 *  ringHeight]) bbNegative();
    
    // Axis bolts
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 30]) rotate([0, 90, 0]) translate([0, 0, hexNutRadius]) Din933Bolt(8, 20);
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 30]) rotate([0, 270, 0]) translate([0, 0, hexNutRadius]) Din933Bolt(8, 20);
    
    for (angle=clampAngles) clampingBolt(angle);
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

secondaryRingInnerDiameter = primaryRingDiameter + ringSpacing;
secondaryRingOuterDiameter = secondaryRingInnerDiameter + 5*wallThickness + 2*bearingHeight; 
module secondaryRing() {
  bearingRadius = (innerHexDiameter(secondaryRingOuterDiameter)+innerHexDiameter(secondaryRingInnerDiameter)) / 2 / 2;
  boltRadius = (secondaryRingOuterDiameter+secondaryRingInnerDiameter) / 2 / 2 - 0.75*wallThickness;

  innerClampRadius = bearingRadius+1;
  clampRadius = bearingRadius + wallThickness +1;

  module clampingBolt(orientation) {
    ringRadius = innerHexDiameter(primaryRingDiameter)/2-wallThickness - hexNutThickness[4];
    rotate([0, 0, orientation[0]]) translate([orientation[1], 0, -0.01]) rotate([0, 0, 30]) Din933Bolt(4, ringHeight, needsBridgeSupport=true);
  }
  
  clampAngles = [
    [0, clampRadius], 
    [60, clampRadius], 
    [100, innerClampRadius], // inner
    [140,innerClampRadius], // inner
    [180, clampRadius],
    [240, clampRadius],
    [280, innerClampRadius],// inner
    [320, innerClampRadius]// inner
  ];

  difference() {
    // Ring
    cylinder(r=secondaryRingOuterDiameter/2, h = ringHeight, $fn=6);
    ZFF() cylinder(r=secondaryRingInnerDiameter/2, h = ringHeight, $fn=6);
    
    // Bearings
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 30]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
    translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 210]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
    
    // Axis bolts
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 120]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(8, 20);
    translate([0, 0, ringHeight*0.5]) rotate([30, 0, 300]) rotate([0, -90, 0]) translate([0, 0, boltRadius]) Din933Bolt(8, 20);

    for (angle=clampAngles) clampingBolt(angle);
  }
}

tertiaryRingInnerDiameter = secondaryRingOuterDiameter + ringSpacing*1.2;
tertiaryRingOuterDiameter = tertiaryRingInnerDiameter + 6*wallThickness + 2*bearingHeight; 

module tertiaryRing() {
  bearingRadius = (tertiaryRingOuterDiameter+tertiaryRingInnerDiameter) / 2 / 2 - 1*wallThickness;

  innerClampRadius = bearingRadius-4;
  clampRadius = bearingRadius+1.5;

  module clampingBolt(orientation) {
    rotate([0, 0, orientation[0]]) translate([orientation[1], 0, -0.01]) rotate([0, 0, 30]) Din933Bolt(4, ringHeight, needsBridgeSupport=true);
  }
  
  clampAngles = [
    [0, clampRadius], 
    [60, clampRadius], 
    [100, innerClampRadius], // inner
    [140,innerClampRadius], // inner
    [180, clampRadius],
    [240, clampRadius],
    [280, innerClampRadius],// inner
    [320, innerClampRadius]// inner
  ];

  difference() {
    // Ring
    difference() {
      union() {
        difference() {
          cylinder(r=tertiaryRingOuterDiameter/2, h = ringHeight, $fn=6);
          ZFF() cylinder(r=tertiaryRingInnerDiameter/2, h = ringHeight, $fn=6);
        }
        rotate([0, 0, -60]) translate([-0.5*tertiaryRingOuterDiameter+0.5*bearingOuterDiameter, 0, 0.5*ringHeight]) cube([0.65*bearingOuterDiameter, bearingOuterDiameter, ringHeight], center=true);
        rotate([0, 0, -60]) translate([0.5*tertiaryRingOuterDiameter-0.5*bearingOuterDiameter, 0, 0.5*ringHeight]) cube([0.65*bearingOuterDiameter, bearingOuterDiameter, ringHeight], center=true);
      }
      
      ZFF() rotate([0, 0, -60]) translate([0.5*tertiaryRingOuterDiameter-0.5*bearingOuterDiameter+0.7*bearingOuterDiameter, 0, 0.5*ringHeight]) cube([0.75*bearingOuterDiameter, bearingOuterDiameter, ringHeight], center=true);
      ZFF() rotate([0, 0, -60]) translate([-0.5*tertiaryRingOuterDiameter+0.5*bearingOuterDiameter-0.7*bearingOuterDiameter, 0, 0.5*ringHeight]) cube([0.75*bearingOuterDiameter, bearingOuterDiameter, ringHeight], center=true);
    
      // Bearings
      translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 120]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
      translate([0, 0, 0.5 * ringHeight ]) rotate([0, 0, 300]) rotate([0, -90]) translate([0, 0, bearingRadius]) bbNegative();
      
      for (angle=clampAngles) clampingBolt(angle);
    }
  }
}

//lowerHalf() primaryRing();
lowerHalf() secondaryRing();
//upperHalf() tertiaryRing();

