import Algorithms

struct Day02: AdventDay {
  /// The data from the instructions file
  var data: String

  // Splits input data into its component parts and convert from string.
  var instructions: [String] {
    data.split(separator: "\n").map( { line in 
            String(line)
        }
    )
  }

  // --- Constants ---

  /// Solves the first part of the problem
  func part1() -> Any {
    // The Dial on which we will simulate the algorithm
    return "Not implemented yet"
  }

  /// Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }
}