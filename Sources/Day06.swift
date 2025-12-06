import Algorithms

struct Day06: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  static let sumSign = "+"
  static let productSign = "*"

  // Returns a list of Problems using Part 1 rules
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

  private var part2Problems: [Problem] {
    let matrix = data
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { line in line.map { String($0) } }

    // Find max number of columns among all rows
    let maxColumns = matrix.map { $0.count }.max() ?? 0

    // One column -> One Problem
    var problems: [Problem] = Array(repeating: Problem(), count: maxColumns)
    var currentIndex = 0

    // Scan right to left
    for col in stride(from: maxColumns-1, through: 0, by: -1)  {
      var columnChars: [String] = []

        // Scan top to bottom
        for row in 0..<matrix.count {
            guard col < matrix[row].count else { continue }
            columnChars.append(matrix[row][col])
        }

        // Separator column → new Problem
        if columnChars.allSatisfy({ $0 == " " }) {
            if !problems[currentIndex].numbers.isEmpty {
                problems.append(Problem())
                currentIndex += 1
            }
            continue
        }

        // Fuse together the characters into a single String
        let columnString = columnChars.joined()

        // Remove spaces
        let trimmed = columnString.trimmingCharacters(in: .whitespaces)

        // Keep only number characters
        let digits = trimmed.filter { $0.isNumber }

        if !digits.isEmpty, let number = Int(digits) {
            problems[currentIndex].numbers.append(number)
        }

        // Check for ProblemType
        if let op = trimmed.first(where: { !$0.isNumber && $0 != " " }) {
            problems[currentIndex].type = ProblemType.fromString(String(op)) ?? .sum
        }
    }

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
    return part2Problems
      .map { $0.result }
      .reduce(0, +)
  }
}

/// A struct representing a math problem
private struct Problem : Hashable {
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
