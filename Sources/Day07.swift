import Algorithms

struct Day07: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  fileprivate static let startChar = "S"
  fileprivate static let emptyyChar = "."
  fileprivate static let splitterChar = "^"
  fileprivate static let beamChar = "|"

  /// Converts the input string into a TachyonManifold instance
  fileprivate var manifold: TachyonManifold {
    let matrix = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")
      .map { row in
        row.compactMap {
          CellType.fromString(String($0))
        }
      }
    
    return TachyonManifold(matrix: matrix)
  }

  // Solves the first part of the problem
  func part1() -> Any {
    var tachyonManifold = self.manifold

    tachyonManifold.simulate()

    return tachyonManifold.splitTimes
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }
}

/// A struct modeling the Tachyon Manifold
private struct TachyonManifold {
  /// A matrix of cells representing the entire manifold
  var matrix: [[CellType]]

  /// The number of times a beam has been split
  var splitTimes = 0

  /// Runs the simulation until the beam reaches the end,
  /// modifying the matrix in the process.
  /// Increments splitTimes each time a beam is split.
  mutating func simulate() -> Void {
    /// Number of rows to look at (each time we look
    /// at one row and the one below, so count - 2 avoids looking 
    /// below the last one)
    let depth = matrix.count - 2
    
    /// Start from level 1, because level 0 only has the starting point
    var currentLevel = 0

    repeat {
      // At each iteration, parse the current row's slots one by one,
      // looking at the slot above to decide how to update the current one
      let nextLevel = currentLevel + 1

      for i in 0 ..< matrix[currentLevel].count {
        switch matrix[currentLevel][i] {
          case .start, .beam :
            // A starting point generates a beam, and a beam generates another one below
            // Check what is below to decide what to do
            switch matrix[nextLevel][i] {
              case .splitter:
                // Split the beam into the bottom cell's neighbours,
                // UNLESS one of them is also a splitter
                let offsets = [-1, +1]
                for offset in offsets {
                  let offsetIndex = i + offset
                  if offsetIndex >= 0 && offsetIndex < matrix[nextLevel].count {
                    if matrix[nextLevel][offsetIndex] != .splitter {
                      matrix[nextLevel][offsetIndex] = .beam
                    }
                  }
                }

                // Increment the counter
                splitTimes += 1
              default: 
                // Continue the beam below this one
                matrix[nextLevel][i] = .beam
            }
          default: continue
        }
      }

      currentLevel += 1

    } while currentLevel <= depth

  }
}

/// An enum of all possible slot components inside each cell 
/// of the Tachyon Manifold
private enum CellType: CaseIterable {
  case start
  case empty
  case splitter
  case beam

  /// Returns an instance of this enum matching the character, if it exists
  static func fromString(_ string: String) -> CellType? {
    for type in CellType.allCases {
      if type.string == string { return type }
    }

    return nil
  }

  /// The String representation of the cell type
  var string: String {
    switch self {
      case .start: Day07.startChar
      case  .empty: Day07.emptyyChar
      case .splitter: Day07.splitterChar
      case .beam: Day07.beamChar
    }
  }
}