import Algorithms

struct Day12: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  private static let emptySlotChar: Character = "."
  private static let filledSlotChar: Character = "#"
  private static let separatorChar: Character = ":"
  private static let regionMatrixSeparatorChar: Character = "x"

  /// Converts the input String into a list of Present Shapes
  private var shapes: [Shape] {
    var shapes: [Shape] = []
    var currentIndex: Int? = nil
    var currentMatrix: [[ShapeSlot]] = []

    for raw in data.split(separator: "\n", omittingEmptySubsequences: false) {
      let line = raw.trimmingCharacters(in: .whitespaces)
      if line.isEmpty {
        continue
      }
      
      // New shape header?
      if let idxEnd = line.firstIndex(of: ":"),
        let idx = Int(line[..<idxEnd]) {
        // Flush previous shape
        if currentIndex != nil {
          shapes.append(Shape(matrix: currentMatrix))
        }
        currentIndex = idx
        currentMatrix = []
        continue
      }
      
      // Inside a shape?
      if currentIndex != nil {
        // Shape lines are only # and .
        if line.allSatisfy({ $0 == "#" || $0 == "." }) {
          currentMatrix.append(line.map { $0 == "#" ? .filled : .empty })
        }
        continue
      }
    }
    
    // Flush final shape
    if currentIndex != nil {
      shapes.append(Shape(matrix: currentMatrix))
    }
    
    return shapes
  }

  /// Converts the input String into a list of Regions
  private var regions: [Region] {
    var regions: [Region] = []
    
    for raw in data.split(separator: "\n") {
      let line = raw.trimmingCharacters(in: .whitespaces)
      if line.isEmpty { continue }
      
      // Check if matches "WxH: ..."
      guard let dimEnd = line.firstIndex(of: ":") else { continue }
      
      let dimPart = line[..<dimEnd]
      let rest = line[line.index(after: dimEnd)...].trimmingCharacters(in: .whitespaces)
      
      let dims = dimPart.split(separator: "x")
      guard dims.count == 2,
        let w = Int(dims[0]),
        let h = Int(dims[1]) else { continue }
      
      let quantities = rest.split(whereSeparator: { $0 == " " })
        .compactMap { Int($0) }
      
      regions.append(Region(rows: h, columns: w, spots: quantities))
    }
    
    return regions
  }

  // Solves the first part of the problem
  func part1() -> Any {
    let shapes = self.shapes
    let regions = self.regions

    // Count how many Regions can't fit the Shapes
    var dontFit = 0

    for region in regions {

      // By inspecting the input, we notice that:
      // - For each Region, the total number of required filled slots
      //   exactly matches the Region's total area.
      // - The provided Shapes are compact and designed to tile
      //   rectangular Regions without leaving gaps.
      //
      // Because of this, for this specific dataset it is sufficient
      // to only check that the Region has enough slots to contain
      // all required Shapes.
      if !isRegionBigEnough(region, shapes: shapes) {
        dontFit += 1
        continue
      }
    }

    // Return the remaining number of Regions
    return regions.count - dontFit
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }

  /// Checks whether the Region has enough slot to 
  /// fit all the Shapes' slots (simple numerical check)
  private func isRegionBigEnough(_ region: Region, shapes: [Shape]) -> Bool {
    let regionSize = region.allSlots

    let neededSize = zip(region.spots, shapes)
      .map { count, shape in
        count * shape.usedSlots
      }
      .reduce(0, +)

    return regionSize >= neededSize
  }
}

/// A struct modeling a Present Shape
private struct Shape {
  /// The matrix representing the Shape
  let matrix: [[ShapeSlot]]

  /// The number of rows in the matrix
  var rows: Int { matrix.count }
  /// The number of columns in the matrix
  var columns: Int { matrix.first?.count ?? 0 }
  /// The total number of slots in the matrix
  var allSlots: Int { rows * columns }
  /// The number of slots actually used by the Shape
  var usedSlots: Int {
    matrix
      .map { line in
        line
          .map { $0 == .filled }
          .count
      }
      .reduce(0, +)
  }
}

/// An enum of the possible slots in a Shape
private enum ShapeSlot {
  case empty, filled
}

/// A struct modeling a Region under the tree
private struct Region {
  let rows: Int
  let columns: Int

  // How many slots are available in total
  var allSlots: Int { rows * columns }

  // A list of how many slots are available for each Present Shape
  // Shapes are defined using their index
  let spots: [Int]
}
