import Algorithms

struct Day03: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  private static let batteriesPerBank = 2
  private static let batteriesPerBankWithOverride = 12

  /// Maps the input into an array of arrays of Ints.
  /// Each element in the first array corresponds to a line in the file,
  /// meaning one bank of batteries.
  /// Each element in the inner array contains a single digit 0-9, corresponding
  /// to the joltage rating for a single battery in that bank.
  var batteries: [[Int]] {
    data
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: "\n")
        .compactMap { bank in
            bank.compactMap { Int(String($0)) }
        }
    }

  // Solves the first part of the problem
  func part1() -> Any {
    let bestBatteries = getHighestJoltages(digits: Day03.batteriesPerBank)

    // Return the sum of the best batteries in all banks
    return bestBatteries.reduce(0, +)
  }

  // Solves the second part of the problem
  func part2() -> Any {
    let bestBatteries = getHighestJoltages(digits: Day03.batteriesPerBankWithOverride)

    // Return the sum of the best batteries in all banks
    return bestBatteries.reduce(0, +)
  }


    /// Returns an array containing the highest joltage
    /// found in each bank
    private func getHighestJoltages(digits: Int) -> [Int] {
        var bestBatteries: [Int] = []

        for bank in batteries {
            var found: [Int] = []
            var lastPickedIndex = -1

            while found.count < digits {
                // Check for the best digit to add to the selected ones.
                // Check from the last selected digit and ignoring the last
                // remaining digits so that we can always find enough of them
                // (Order matters!)
                let startingIndex = lastPickedIndex + 1
                let remaining = digits - found.count

                let endingIndex = min(
                    bank.count - remaining,
                    bank.count - 1
                )

                guard startingIndex <= endingIndex else { break }

                var bestValue = -1
                var bestIndex = startingIndex

                for i in startingIndex...endingIndex {
                    if bank[i] > bestValue {
                        bestValue = bank[i]
                        bestIndex = i
                    }
                }

                found.append(bestValue)
                lastPickedIndex = bestIndex
                }

            // Aggregate the batteries found into a single number
            let total = Int(
                found.compactMap { String($0) }
                    .reduce("", +)
            ) ?? 0

            bestBatteries.append(total)
        }

        return bestBatteries
    }
}
