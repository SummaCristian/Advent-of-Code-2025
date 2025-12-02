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
    var invalidIDs: [Int] = []

    for range in ranges {
        invalidIDs.append(contentsOf: getAllInvalidIDs(in: range))
    }

    /// Return the sum of all the invalid IDs
    return invalidIDs.reduce(0, +)
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

  /// Returns an array containing all the invalid IDs 
  /// found in the specified range, using Part 2 requirements
  private func getAllInvalidIDs(in range: (Int, Int)) -> [Int] {
    var invalidIDs: [Int] = []
    let initialValue = range.0
    let finalValue = range.1

    // Only check valifd ranges and ones where the numbers have at least 2 digits
    if finalValue >= initialValue, String(finalValue).count > 1 {
        for id in initialValue...finalValue {
            let stringID = String(id)

            let length = stringID.count

            // Check if the string is at least 2 digits long
            guard length > 1 else { continue }
            /// Check if the String can be divided in at least 2 parts
            let maxNumberOfParts = length
            guard maxNumberOfParts >= 2 else { continue }

            // Iterate over all the possible number of repeated combinations (from 2 to count/2)
            for partsCount in 2...maxNumberOfParts {
                // Check if the ID can actually be divided into that number of substrings
                guard length % partsCount == 0 else { continue }

                let substringLength = length / partsCount
                
                // Check if the pattern in the first substring is 
                // repeated in all the following ones.
                let pattern = stringID.prefix(substringLength)
                
                var isRepeated = true
                for i in 1..<partsCount {
                    let start = stringID.index(stringID.startIndex, offsetBy: i * substringLength)
                    let end = stringID.index(start, offsetBy: substringLength)

                    if stringID[start..<end] != pattern {
                        isRepeated = false
                        break
                    }
                }

                if isRepeated {
                    invalidIDs.append(id)
                    break
                }
            }
        }

    }

    return invalidIDs
  }
}