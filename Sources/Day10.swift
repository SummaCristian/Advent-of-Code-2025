import Algorithms
import HeapModule

struct Day10: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  fileprivate static let indicatorOnChar: Character = "#"
  fileprivate static let indicatorOffChar: Character = "."
  fileprivate static let startIndicatorsSection: Character = "["
  fileprivate static let endIndicatorsSection: Character = "]"
  fileprivate static let startButtonSchematic: Character = "("
  fileprivate static let endButtonSchematic: Character = ")"
  fileprivate static let startJoltageSection : Character = "{"
  fileprivate static let endJoltageSection: Character = "}"

  /// Converts the input String into an array of Machine objects
  private var machines: [Machine] {
    let lines = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")

    var machines: [Machine] = []

    for line in lines {
      var indicators: [Indicator] = []
      var buttons: [Button] = []
      var joltageReq: [Int] = []

      let parts = line.split(separator: " ")

      for part in parts {
        guard let firstChar = part.first else { continue }

        switch firstChar {

          // -------------------------------------------
          // INDICATORS SECTION:  [.#.#.]
          // -------------------------------------------
          case Day10.startIndicatorsSection:
            let inner = part.dropFirst().dropLast()   // Remove [ ]

            for ch in inner {
              switch ch {
                case Day10.indicatorOnChar:  indicators.append(.init(isOn: true))
                case Day10.indicatorOffChar: indicators.append(.init(isOn: false))
                default: fatalError("Invalid indicator character: \(ch)")
              }
            }

          // -------------------------------------------
          // BUTTON SECTION:  (1,2,4)
          // -------------------------------------------
          case Day10.startButtonSchematic:
            let inside = part.dropFirst().dropLast()   // Remove ( )
            let buttonIndices = inside
              .split(separator: ",")
              .compactMap { Int($0) }

            buttons.append(.init(indicatorIndices: buttonIndices))

          // -------------------------------------------
          // JOLTAGE SECTION: {3,5,4,7}
          // -------------------------------------------
          case Day10.startJoltageSection:
            // TODO: parse joltage here
            // Example:
            let inside = part.dropFirst().dropLast()  // Remove { }
            joltageReq = inside.split(separator: ",").compactMap { Int($0) }
            continue

          default:
            fatalError("Unknown format in line: \(part)")
        }
      }

      // Add the parsed machine
      machines.append(
        Machine(goalIndicators: indicators, buttons: buttons, joltage: joltageReq)
      )
    }

    return machines
  }

  // Solves the first part of the problem
  func part1() -> Any {
    let machines = self.machines

    let solutions = machines
      .map { getMinButtonCombination(for: $0) }

    return solutions
      .map { $0.count }
      .reduce(0, +)
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }

  /// Returns the minimum sequence of Buttons to press
  /// in order to turn the Indicators in their final state,
  /// using the Button schematics from the given Machine.
  /// Buttons are returned through their index from Machine.buttons
  fileprivate func getMinButtonCombination(for machine: Machine) -> [Int] {

    /// Heuristic function
    /// Returns the number of indicators that still need to be toggled
    /// to reach the goal state.
    /// Lower is better (0 is goal)
    func missingIndicators(in machine: Machine) -> Int {
      var missing = 0

      for i in machine.goalIndicators.indices {
        if machine.goalIndicators[i].isOn != machine.indicators[i].isOn {
          missing += 1
        }
      }

      return missing
    }

    /// Admissible heuristic:
    /// Lower bound on the number of presses needed.
    /// If one press can fix at most `maxTogglesPerButton`,
    /// then h = ceil(missing / maxTogglesPerButton) is guaranteed admissible.
    let maxTogglesPerButton = max(1, machine.buttons.map { $0.indicatorIndices.count }.max() ?? 1)
    
    /// Returns the heuristic function from the given state
    func heuristic(_ m: Machine, maxToggles: Int) -> Int {
      let miss = missingIndicators(in: m)
      return (miss + maxToggles - 1) / maxToggles
    }

    /// State in the A* search
    struct State: Comparable, Equatable {
      var machine: Machine
      var path: [Int]
      var cost: Int

      let maxToggles: Int

      static func < (lhs: State, rhs: State) -> Bool { 
        let lhsF = lhs.cost + heuristic(lhs.machine, maxToggles: lhs.maxToggles)
        let rhsF = rhs.cost + heuristic(rhs.machine, maxToggles: rhs.maxToggles)
        return lhsF < rhsF
      }

      static func == (lhs: State, rhs: State) -> Bool {
        lhs.machine.indicators.map(\.isOn) == rhs.machine.indicators.map(\.isOn)
        && lhs.cost == rhs.cost
      }
    }


    // Saves the States in a Set acting as a Priority Queue
    var openSet = Heap<State>()
    openSet.insert(State(machine: machine, path: [], cost: 0, maxToggles: maxTogglesPerButton))

    var visited: Set<Int> = []

    /// Encodes the indicator values to make comparison faster (max 32 indicators)
    func encode(_ machine: Machine) -> Int {
      var value = 0
      for (i, indicator) in machine.indicators.enumerated() {
        if indicator.isOn {
          value |= (1 << i)
        }
      }
      
      return value
    }

    // Performs the A* algorithm to find the best 'path'
    // towards the goal state. Path = Sequence of Button presses
    while !openSet.isEmpty {
      // Pick state with lowest f = g + h
      guard let current = openSet.popMin() else { break }

      let key = encode(current.machine)

      // Since buttons can be pressed more than once,
      // check if the configuration has already been
      // visited, to avoid loops
      if visited.contains(key) { continue }
      // Add the configuration to the list of visited ones
      visited.insert(key)

      // Check if we reached the goal state
      if heuristic(current.machine, maxToggles: maxTogglesPerButton) == 0 { 
        return current.path
      }

      // Expand successors
      for idx in current.machine.buttons.indices {
        var nextMachine = current.machine
        nextMachine.press(buttonIdx: idx)
        openSet.insert(State(
          machine: nextMachine,
          path: current.path + [idx],
          cost: current.cost + 1,
          maxToggles: maxTogglesPerButton
        ))
      }
    }

    // No path found
    return []
  }
}

/// A struct modeling a Light Indicator
private struct Indicator {
  /// The state of this indicator (they all start off)
  var isOn: Bool = false

  /// Toggles the Indicator
  mutating func toggle() -> Void { isOn.toggle() }
}

/// A struct modeling a Button
private struct Button {
  /// The index of the set of Indicators this Button controls
  /// Indicators are stored in the Machine, these are 
  /// the indices from that array
  let indicatorIndices: [Int]
}

/// A struct modeling a Machine
private struct Machine {
  /// The list of Light Indicators
  var indicators: [Indicator]

  /// The state the Indicators must be at the end
  let goalIndicators: [Indicator]

  /// The list of Button and their schematics
  let buttons: [Button]

  /// The list of Joltage Requirements
  let joltageRequirements: [Int]

  /// True if all Indicators match their state in the goalIndicators
  var isCorrect: Bool {
    guard indicators.count == goalIndicators.count else { fatalError("Number of indicators doesn't match") }

    for i in 0..<goalIndicators.count {
      // Early termination at the first non-matching Indicator
      if indicators[i].isOn != goalIndicators[i].isOn { return false }
    }

    // All matching
    return true
  }

  init(
    goalIndicators: [Indicator],
    buttons: [Button],
    joltage: [Int]
  ) {
    self.goalIndicators = goalIndicators
    self.buttons = buttons
    self.joltageRequirements = joltage

    self.indicators = Array(repeating: Indicator(), count: goalIndicators.count)
  }

  /// Toggles all Indicators specified in the Button's schematic
  mutating func press(buttonIdx: Int) {
    guard buttons.indices.contains(buttonIdx) else { fatalError("Unknown button pressed") }

    let button = buttons[buttonIdx]
    for idx in button.indicatorIndices {
      guard indicators.indices.contains(idx) else { fatalError("Unknown indicator toggled") }

      indicators[idx].toggle()
    }
  }
}