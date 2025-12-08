import Foundation
import Algorithms

struct Day08: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  fileprivate static let pairsToFind = 1000
  fileprivate static let circuitsToCount = 3

  /// Converts the input String into an Array of JunctionBox objects
  private var junctionBoxes: [JunctionBox] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")
      .map { line in
        line
          .split(separator: ",")
          .compactMap { Int($0) }
      }
      .compactMap { JunctionBox(x: $0[0], y: $0[1], z: $0[2]) }
  }

  // Solves the first part of the problem
func part1() -> Any {
    let boxes = junctionBoxes
    var uf = UnionFind(boxes: boxes)

    // Generates all possible combinations of two boxes
    let combinations = boxes
        .combinations(ofCount: 2)
        .map { pairArray -> JunctionBoxPair in
            JunctionBoxPair(first: pairArray[0], second: pairArray[1])
        }

    // Sort all pairs by squared distance, from shortest to longest
    let sortedCombinations = combinations.sorted { $0.squaredDistance < $1.squaredDistance }

    // Iterates over the first `pairsToFind` pairs
    // and unions their sets to form connected circuits
    for pair in sortedCombinations.prefix(Day08.pairsToFind) {
        uf.union(pair.first, pair.second)
    }

    /// Maps the root of each component to the number of boxes it contains
    var componentSizes: [JunctionBox: Int] = [:]
    for box in boxes {
        let root = uf.find(box)
        componentSizes[root, default: 0] += 1
    }

    // Takes the `circuitsToCount` largest components
    // and multiplies their sizes to get the answer
    let top3 = componentSizes.values.sorted(by: >).prefix(Day08.circuitsToCount)
    return top3.reduce(1, *)
}

  // Solves the second part of the problem
  func part2() -> Any {
      let boxes = junctionBoxes
      var uf = UnionFind(boxes: boxes)

      // Sort all pairs by squared distance, from shortest to longest
      let sortedPairs = boxes
        .combinations(ofCount: 2)
        .map { pairArray -> (JunctionBox, JunctionBox, Int64) in
          let a = pairArray[0]
          let b = pairArray[1]
          return (a, b, a.squaredDistance(from: b))
        }
        .sorted { $0.2 < $1.2 }

      var lastPair: (JunctionBox, JunctionBox)? = nil

      for (a, b, _) in sortedPairs {
          if uf.find(a) != uf.find(b) {
              uf.union(a, b)
              lastPair = (a, b)
          }

          if uf.allConnected(boxes: boxes) {
              break
          }
      }

      guard let (lastA, lastB) = lastPair else {
          fatalError("No pair caused full connection")
      }

      return lastA.x * lastB.x
    }
  }

/// A struct modeling a Junction Box
private struct JunctionBox: Equatable, Hashable {
    // Coordinates
    let x: Int
    let y: Int
    let z: Int

    /// Returns the straight-line distance SQUARED from the
    /// JunctionBox passed as parameter.
    /// Since Square Root is a strictly increasing function
    /// ( sqrt(a) > sqrt(b) for all a > b)
    /// we can avoid the expensive computation and compare 
    /// their squares directly
    func squaredDistance(from other: JunctionBox) -> Int64 {
        let dx = Int64(x - other.x)
        let dy = Int64(y - other.y)
        let dz = Int64(z - other.z)

        return dx*dx + dy*dy + dz*dz
    }
}

/// A struct modeling a pair of JunctionBox objects
private struct JunctionBoxPair: Equatable, Hashable {
  let first: JunctionBox
  let second: JunctionBox

  // Conformance to Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(first)
    hasher.combine(second)
  }

  /// Returns true if any of the two JunctionBox inside the pair
  /// matches the one passed as parameter
  func contains(_ box: JunctionBox) -> Bool {
    return first == box || second == box
  }

  /// Returns the squaredDistance of the two Boxes in this Pair
  var squaredDistance: Int64 { first.squaredDistance(from: second) }
}

/// Utils struct to share common behavior between the two parts of the challenge
private struct UnionFind {
  private var parent: [JunctionBox: JunctionBox] = [:]

  init(boxes: [JunctionBox]) {
    for box in boxes {
      parent[box] = box
    }
  }

  /// Finds the root of the set containing `box` with path compression
  mutating func find(_ box: JunctionBox) -> JunctionBox {
    if parent[box]! != box {
        parent[box] = find(parent[box]!)
    }
    return parent[box]!
  }

  /// Connects the sets containing `a` and `b`
  mutating func union(_ a: JunctionBox, _ b: JunctionBox) {
    let rootA = find(a)
    let rootB = find(b)
    if rootA != rootB {
        parent[rootB] = rootA
    }
  }

  /// Returns the sizes of all connected components
  mutating func componentSizes(boxes: [JunctionBox]) -> [Int] {
    var sizes: [JunctionBox: Int] = [:]
    for box in boxes {
        let root = find(box)
        sizes[root, default: 0] += 1
    }
    return Array(sizes.values)
  }

  /// Returns true if all boxes belong to the same component
  mutating func allConnected(boxes: [JunctionBox]) -> Bool {
    let roots = Set(boxes.map { find($0) })
    return roots.count == 1
  }
}