include <lib/gimbal.scad>

module gimbalLowerHalf() {
  enableBridgeSupport = true;
  lowerHalf() {
    core();
    primaryRing();
    secondaryRing();
  }
}

gimbalLowerHalf();