import Algorithms

struct Day05: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  
  // A struct modeling the Inventory from the problem
  private struct Inventory {
    /// A list of IDs indicating fresh products
    var freshIDs: [Range]
    /// A list of IDs indicating products in stock
    var availableIDs: [Int]
  }

  /// A struct modeling a Range of values
  private struct Range {
    /// The initial value
    let start: Int
    /// The last value
    let end: Int
  }

  /// Converts the data into a struct containing
  /// a list of IDs considered fresh, and
  /// a list of IDs for products in inventory
  private var inventory: Inventory {
    var parts: [String] = []

    if let range = data.range(of: "\n\n") {
        parts.append(String(data[..<range.lowerBound]))
        parts.append(String(data[range.upperBound...]))
    } else { 
      fatalError("Wrong input format")
    }

    guard parts.count == 2 else {
        fatalError("Expected two data sections, found \(parts.count)")
    }

    let ranges = String(parts[0])
    let ingredients = String(parts[1])
    // Convert ranges in an array of all possible IDs
    let freshIDs: [Range] = ranges
    .split(separator: "\n")
    .compactMap { line -> Range? in
        let parts = line
            .split(separator: "-")
            .compactMap { Int($0) }

        guard parts.count == 2 else { return nil }

        let start = min(parts[0], parts[1])
        let end   = max(parts[0], parts[1])

        return Range(start: start, end: end)
    }
    .sorted { $0.start < $1.start }


    // Convert ingredients in an array of all IDs
    let availableIDs = 
      ingredients.split(separator: "\n")
        .compactMap { Int($0) }
        .sorted { $0 <= $1 }

      // Return the Inventory struct containing both
      let inventory = Inventory(freshIDs: freshIDs, availableIDs: availableIDs)
      return inventory
  }

  // Solves the first part of the problem
  func part1() -> Any {
    let inventory = self.inventory

    var i = 0  // ingredient index
    var r = 0  // range index

    var matching: [Int] = []

    while i < inventory.availableIDs.count && r < inventory.freshIDs.count {
        let id = inventory.availableIDs[i]
        let range = inventory.freshIDs[r]

        if id < range.start {
            i += 1
        } else if id > range.end {
            r += 1
        } else {
            matching.append(inventory.availableIDs[i])
            i += 1
        }
    }

    return matching.count
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }
}
