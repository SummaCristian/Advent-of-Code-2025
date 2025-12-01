import Algorithms

struct Day01: AdventDay {
  /// The data from the instructions file
  var data: String

  // Splits input data into its component parts and convert from string.
  var instructions: [(Character, Int)] {
    data.split(separator: "\n").map { line in
        let direction = line.first!
        let value = Int(line.dropFirst())!
        return (direction, value)
    }
  }

  // --- Constants ---

  /// The initial value the dial starts from
  private static let initialValue = 50
  /// The minimum value in the dial
  private static let minValue = 0
  /// The maximum value in the dial
  private static let maxValue = 99
  /// The value we want to track
  private static let targetValue = 0

  /// Solves the first part of the problem
  func part1() -> Any {
    // The Dial on which we will simulate the algorithm
    var dial = Dial(
      startsFrom: Self.initialValue,
      target: Self.targetValue,
      min: Self.minValue,
      max: Self.maxValue
    )

    // Iterate the moves on the dial
    for move in instructions {
      switch move.0 {
        case "R": dial.rotateRight(by: move.1)
        case "L": dial.rotateLeft(by: move.1)
        default: print("Invalid move: \(move.0)\(move.1)")
      }
    }

    // Return how many times the target value was selected
    return dial.timesTargetSelected
  }

  /// Solves the second part of the problem
  func part2() -> Any {
    print("Not implemented yet")
    
  }
}

/// A struct modeling the Dial from the problem
private struct Dial {
  /// The current value selected on the dial
  var currentValue: Int

  /// The minimum value in the dial
  let min: Int
  /// The maximum value in the dial
  let max: Int

  /// The target value
  let targetValue: Int

  /// The amount of times the target was selected
  var timesTargetSelected = 0

  init(
    startsFrom: Int = 0,
    target: Int = 0,
    min: Int = 0,
    max: Int = 99
  ) {
    self.currentValue = startsFrom
    self.targetValue = target
    self.min = min
    self.max = max
  }

  /// Rotates the dial to the RIGHT
  mutating func rotateRight(by amount: Int) {
    let finalPos = currentValue + amount

    if finalPos > max {
      currentValue = (currentValue + amount) % (max + 1)
    } else {
      currentValue = finalPos
    }

    // Check if the target is selected
    if currentValue == targetValue {
      timesTargetSelected += 1
    }
  }

  /// Rotates the dial to the LEFT
  mutating func rotateLeft(by amount: Int) {
    let finalPos = currentValue - amount

    if finalPos < min {
      currentValue = (currentValue - amount + (max + 1)) % (max + 1)

    } else {
      currentValue = finalPos
    }

    // Check if the target is selected
    if currentValue == targetValue {
      timesTargetSelected += 1
    }
  }
}