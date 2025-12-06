import Algorithms

struct Day06: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  static let sumSign = "+"
  static let productSign = "*"

  private var problems: [Problem] {
    let rows = data.trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")
      .map { row in
        row.split(separator: " ")
        .map { String($0) }
      }

    var problems: [Problem] = Array(repeating: Problem(), count: rows.first?.count ?? 0)

    // Scan row by row
    for r in 0..<rows.count {
      // Use the column index to refer to the individual problem
      for c in 0..<rows[r].count {
        let element: String = rows[r][c]

        // Check if the element is a number or a symbol
        if let number = Int(element) {
          // Element is a number
          problems[c].numbers.append(number)

        } else if let type = ProblemType.fromString(element) {
          // Element is an operation symbol
          problems[c].type = type
        }
      }
    }

    // Return the list of all Problems
    return problems
  }

  // Solves the first part of the problem
  func part1() -> Any {
    return problems
      .map { $0.result }
      .reduce(0, +)
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }
}

/// A struct representing a math problem
private struct Problem {
  /// The list of numbers
  var numbers: [Int]
  /// The type of problem
  var type: ProblemType

  init(
    numbers: [Int] = [],
    type: ProblemType = .sum
  ) {
    self.numbers = numbers
    self.type = type
  }


  /// Returns the result of the problem
  var result: Int {
      numbers.reduce(type.initialValue, type.function)
  }
}

/// An enum defining all the possible operations in the Problems
private enum ProblemType: CaseIterable {
  case sum, product

  /// Returns the String representation of the Problem type
  var symbol: String {
      switch self {
          case .sum: Day06.sumSign
          case .product: Day06.productSign
      }
  }

  /// Returns the function that can be used to calculate the Problem
  var function: (Int, Int) -> Int {
      switch self {
          case .sum: (+)
          case .product: (*)
      }
  }

  /// Returns the initial value from which to start the computation
  var initialValue: Int {
    switch self {
      case .product: 1
      default: 0
    }
  }

  static func fromString(_ string: String) -> ProblemType? {
    for type in ProblemType.allCases {
      if type.symbol == string {
        return type
      }
    }

    // No match
    return nil
  }
}
