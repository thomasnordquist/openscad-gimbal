include <lib/gimbal.scad>

module gimbalUpperHalf() {
  enableBridgeSupport = false;
  upperHalf() {
    core();
    primaryRing();
    secondaryRing();
  }
}

gimbalUpperHalf();
