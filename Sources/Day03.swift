import Algorithms

struct Day03: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  private static let batteriesPerBank = 2

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
    let bestBatteries = getHighestJoltages()

    // Return the sum of the best batteries in all banks
    return bestBatteries.reduce(0, +)
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }


    /// Returns an array containing the highest joltage
    /// found in each bank
    private func getHighestJoltages() -> [Int] {
        var bestBatteries: [Int] = []

        for bank in batteries {
            var found: [Int] = []

            while found.count < Day03.batteriesPerBank {
                // Check for the best digit to add to the selected ones.
                // Check from the last selected digit and ignoring the last
                // remaining digits so that we can always find enough of them
                // (Order matters!)
                let alreadyFound = found.count

                let startingIndex: Int = {
                    if alreadyFound == 0 { return 0 }
                    guard let index = bank.firstIndex(of: found.last!) else { return 0 }
                    return index + 1
                }()


                let remaining = Day03.batteriesPerBank - found.count

                let endingIndex = min(
                    bank.count - remaining,
                    bank.count - 1
                )


                let partition = startingIndex <= endingIndex
                    ? Array(bank[startingIndex...endingIndex])
                    : []


                // Find the best battery in this partition
                let best = partition.max() ?? 0
                found.append(best)
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
