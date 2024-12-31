use <../scad-utils/scad/functions/sum.scad>
use <../void_switch/scad/sheath_negative.scad>

module BaseMagnetScaffold(
  height,
  magnetHeight,
  magnetRadius,
  wallThickness
) {
  difference() {
    cube([(magnetRadius + wallThickness) * 2, (magnetRadius + wallThickness) * 2, height], true);
    translate([0, 0, -(height - magnetHeight + 1) / 2]) // TODO: check hole depth
      cylinder(h = magnetHeight + 1, r = magnetRadius, center = true);
  }
};

module SwitchFrame(
  baseKeyWidth = 19,
  border = 8,
  frameHeight,
  keyDepth = 19,
  layout,
  plateHeight = 2,
  split,
  splitSection,
  switchCoverHeight,
  switchHeight,
  sheathMargin = 2, // TODO: find smarter way of doing this
  
  baseMagnetHeight = 2,
  baseMagnetRadius = 2,
  
  // void
  magnet_diameter,
  magnet_wall_thickness,
  stem_diameter,
  sheath_length,
  sheath_tolerance,
  stem_tolerance,
  sheath_clip_width
) {
  plateDepth = len(layout) * keyDepth;
  rowWidths = [ for(i = [0 : len(layout) -1]) sum(layout[i]) ];
  plateWidth = max(rowWidths) * baseKeyWidth;

  translate([-plateWidth / 2, -plateDepth / 2, 0])
    for(rowIndex = [0 : len(layout) - 1])
      let(
        rowOffset = (rowIndex + .5) * keyDepth,
        row = layout[rowIndex],
        firstKey = splitSection ? split[rowIndex][splitSection - 1] : 0,
        lastKey = (is_undef(splitSection) || is_undef(split[rowIndex][splitSection])) ? len(layout[rowIndex]) : split[rowIndex][splitSection],
        sectionLength = (sumTo(row, lastKey-1) - sumTo(row, firstKey - 1)) * baseKeyWidth,
        sideSectionLength = (sectionLength + ((is_undef(splitSection) || len(row) == 1) ? 2 * border : ((splitSection == 0 || splitSection == len(split[rowIndex])) ? border : 0))),
        sideSectionOffset = (is_undef(splitSection) || len(row) == 1) ? 0 : (splitSection == 0 ? -border / 2 : ((splitSection == len(split[rowIndex])) ? border / 2 : 0))
      ) {

        // SIDE PANELS
        // MAGNETS
        if(rowIndex == 0)
          translate([sumTo(row, firstKey - 1) * baseKeyWidth + sectionLength / 2, -border / 2, 0]) {
            cube([sectionLength, border, plateHeight], true);
            translate([sideSectionOffset, -(border - plateHeight) / 2, -(switchHeight - plateHeight) / 2])
              cube([sideSectionLength, plateHeight, switchHeight], true);
            translate([-sectionLength / 2 + baseMagnetRadius + plateHeight, 0, -(switchHeight - plateHeight) / 2])
              BaseMagnetScaffold(height = switchHeight, magnetRadius = baseMagnetRadius, magnetHeight = baseMagnetHeight, wallThickness = plateHeight);
            translate([sectionLength / 2 - baseMagnetRadius - plateHeight, 0, -(switchHeight - plateHeight) / 2])
              BaseMagnetScaffold(height = switchHeight, magnetRadius = baseMagnetRadius, magnetHeight = baseMagnetHeight, wallThickness = plateHeight);
          }
        if(rowIndex == len(layout) - 1)
          translate([sumTo(row, firstKey - 1) * baseKeyWidth + sectionLength / 2, plateDepth + border / 2, 0]) {
            cube([sectionLength, border, plateHeight], true);
            translate([sideSectionOffset, (border - plateHeight) / 2, -(switchHeight - plateHeight) / 2])
              cube([sideSectionLength, plateHeight, switchHeight], true);
            translate([-sectionLength / 2 + baseMagnetRadius + plateHeight, 0, -(switchHeight - plateHeight) / 2])
              BaseMagnetScaffold(height = switchHeight, magnetRadius = baseMagnetRadius, magnetHeight = baseMagnetHeight, wallThickness = plateHeight);
            translate([sectionLength / 2 - baseMagnetRadius - plateHeight, 0, -(switchHeight - plateHeight) / 2])
              BaseMagnetScaffold(height = switchHeight, magnetRadius = baseMagnetRadius, magnetHeight = baseMagnetHeight, wallThickness = plateHeight);
          }

        // SWITCH SLOTS
        for(colIndex = [0 : len(row) - 1])
          let(
            colOffset = baseKeyWidth * sumTo(row, colIndex),
            width = baseKeyWidth * row[colIndex]
          ) {
            if(colIndex >= firstKey && colIndex < lastKey)
              translate([colOffset - width / 2, rowOffset, 0]) // TODO: offsets are not right
                difference() {
                  cube([width, keyDepth, plateHeight], true);
                  translate([-sheathMargin, sheathMargin, -switchCoverHeight]) // TODO: double check height
                    cube([baseKeyWidth - sheathMargin, keyDepth - sheathMargin, plateHeight], true);
                  // TODO: add stabilizer for cells wider than 1.5
                  rotate([0, 0, 90])
                    void_sheath_negative(magnet_diameter, magnet_wall_thickness, plateHeight + 1, stem_diameter, sheath_length, sheath_tolerance, stem_tolerance, sheath_clip_width);
                }
          }
      }
   
  // maybe not needed
  // END PANELS
  if(!splitSection)
    translate([-(plateWidth + border) / 2, 0, 0]) {
      cube([border, plateDepth + 2 * border, plateHeight], true);
//      translate([-(border - plateHeight) / 2, 0, -(switchHeight - plateHeight) / 2]) // TODO check where switch height starts, eg should this start below the plate?
//        cube([plateHeight, plateDepth + 2 * border, switchHeight], true);
    }
  if(is_undef(splitSection) || splitSection == len(split[0]))
    translate([(plateWidth + border) / 2, 0, 0]) {
      cube([border, plateDepth + 2 * border, plateHeight], true);
//      translate([(border - plateHeight) / 2, 0, -(switchHeight - plateHeight) / 2]) // TODO check where switch height starts, eg should this start below the plate?
//        cube([plateHeight, plateDepth + 2 * border, switchHeight], true);
    }
};

layout = [
  [1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1],
  [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.25],
  [1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2],
];

split = [
  [5, 6],
  [4, 9],
  [4, 10],
  [4, 10],
  [5, 10]
];

// move to separate file and reuse to render switches
switchCoverHeight = .6;
magnet_diameter = 4;
magnet_wall_thickness = 0.5;
stem_diameter = 5.35; // Copy from void_switch.scad (5.35 == Standard for 4x2mm magnets)
sheath_length = 0.2; // Copy from void_switch.scad
sheath_tolerance = 0.15; // Ditto
stem_tolerance = 0.11; // Ditto
sheath_clip_width = 1.5; // Ditto

//translate([0, 0, 0])
color([1, 0, 0])
SwitchFrame(
  frameHeight = 15,
  layout = layout,
  split = split,
  splitSection = 0,
  switchCoverHeight = switchCoverHeight,
  switchHeight = 18,
  magnet_diameter = magnet_diameter,
  magnet_wall_thickness = magnet_wall_thickness,
  stem_diameter = stem_diameter,
  sheath_length = sheath_length,
  sheath_tolerance = sheath_tolerance,
  stem_tolerance = stem_tolerance,
  sheath_clip_width = sheath_clip_width
);

//translate([0, 0, 1])
color([0, 1, 0])
SwitchFrame(
  frameHeight = 15,
  layout = layout,
  split = split,
  splitSection = 1,
  switchCoverHeight = switchCoverHeight,
  switchHeight = 18,
  magnet_diameter = magnet_diameter,
  magnet_wall_thickness = magnet_wall_thickness,
  stem_diameter = stem_diameter,
  sheath_length = sheath_length,
  sheath_tolerance = sheath_tolerance,
  stem_tolerance = stem_tolerance,
  sheath_clip_width = sheath_clip_width
);

//translate([0, 0, 2])
color([0, 0, 1])
SwitchFrame(
  frameHeight = 15,
  layout = layout,
  split = split,
  splitSection = 2,
  switchCoverHeight = switchCoverHeight,
  switchHeight = 18,
  magnet_diameter = magnet_diameter,
  magnet_wall_thickness = magnet_wall_thickness,
  stem_diameter = stem_diameter,
  sheath_length = sheath_length,
  sheath_tolerance = sheath_tolerance,
  stem_tolerance = stem_tolerance,
  sheath_clip_width = sheath_clip_width
);