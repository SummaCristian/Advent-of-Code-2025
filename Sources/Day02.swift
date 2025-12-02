import Algorithms

struct Day02: AdventDay {
  /// The data from the instructions file
  var data: String

  // Splits input data into its component parts and convert from string.
  var ranges: [(Int, Int)] {
    data
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: ",")
        .compactMap { rangeStr in
            let parts = rangeStr.split(separator: "-")
            
            guard parts.count == 2,
                  let start = Int(parts[0]),
                  let end = Int(parts[1]) else {
                print("Invalid range:", rangeStr)
                return nil
            }
            
            return (start, end)
        }
}

  /// Solves the first part of the problem
  func part1() -> Any {
    var invalidIDs: [Int] = []

    for range in ranges {
        invalidIDs.append(contentsOf: getInvalidIDs(in: range))
    }

    // Return the sum of all the invalid IDs
    return invalidIDs.reduce(0, +)
  }

  /// Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }

  /// Returns an array containing all the invalid IDs 
  /// found in the specified range
  private func getInvalidIDs(in range: (Int, Int)) -> [Int] {
    var invalidIDs: [Int] = []
    let initialValue = range.0
    let finalValue = range.1

    // Only check valid ranges and ones where the numbers have at least 2 digits


    if finalValue >= initialValue, String(finalValue).count > 1 {
        for id in initialValue...finalValue {
            let stringID = String(id)

            // Skip numbers with an odd number of digits (can't be repeated)
            guard stringID.count % 2 == 0 else { continue }

            let count = stringID.count
            let midIndex = stringID.index(stringID.startIndex, offsetBy: count / 2)

            let firstHalf = String(stringID[..<midIndex])
            let secondHalf = String(stringID[midIndex...])

            if firstHalf == secondHalf {
                invalidIDs.append(id)
            }
        }

    }

    return invalidIDs
  }
}