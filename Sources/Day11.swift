import Algorithms

struct Day11: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  private static let initialMachineName1 = "you"
  private static let initialMachineName2 = "svr"
  private static let finalMachineName = "out"
  private static let dacMachineName = "dac"
  private static let fourierMachineName = "fft"

  /// Converts the input String into a Dictionary of
  /// Nodes using the Machine's name as Key
  fileprivate var machines: [String: Node] {
    var dictionary: [String: Node] = [:]

    let array = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")
      .map { line in
        let parts = line.split(separator: ":")

        let machineName = String(parts.first ?? "")
        let connectedMachines = parts[1].split(separator: " ").map { String($0) }

        return Node(name: machineName, connections: connectedMachines)
      }

    for node in array {
      dictionary[node.name] = node
    }

    // Add the final machine
    dictionary[Day11.finalMachineName] = .init(name: Day11.finalMachineName, connections: [])

    return dictionary
  }

  // Solves the first part of the problem
  func part1() -> Any {
    let machines = self.machines

    guard let initialNode = machines[Day11.initialMachineName1],
      let finalNode = machines[Day11.finalMachineName] else {
        fatalError("No initial or final Machines to be found in input")
      }
    
    var memo: [String: Int] = [:]

    // Computes all paths from initialNode to finalNode
    let paths = getAllPathsCount(from: initialNode, to: finalNode, in: machines, memo: &memo)

    // Returns the number of paths
    return paths
  }

  // Solves the second part of the problem
  func part2() -> Any {
    let machines = self.machines

    guard let start = machines[Day11.initialMachineName2],
      let dac = machines[Day11.dacMachineName],
      let fft = machines[Day11.fourierMachineName],
      let end = machines[Day11.finalMachineName] else {
      fatalError("Required machines can't be found")
    }
    
    // Paths where dac comes before fft
    var memo1: [String: Int] = [:]
    let pathsStartToDAC = getAllPathsCount(from: start, to: dac, in: machines, memo: &memo1)

    var memo2: [String: Int] = [:]
    let pathsDACtoFFT = getAllPathsCount(from: dac, to: fft, in: machines, memo: &memo2)

    var memo3: [String: Int] = [:]
    let pathsFFTtoEnd = getAllPathsCount(from: fft, to: end, in: machines, memo: &memo3)

    // Paths where fft comes before dac
    var memo4: [String: Int] = [:]
    let pathsStartToFFT = getAllPathsCount(from: start, to: fft, in: machines, memo: &memo4)

    var memo5: [String: Int] = [:]
    let pathsFFTtoDAC = getAllPathsCount(from: fft, to: dac, in: machines, memo: &memo5)

    var memo6: [String: Int] = [:]
    let pathsDACtoEnd = getAllPathsCount(from: dac, to: end, in: machines, memo: &memo6)

    // Total paths passing through both dac and fft
    let totalPaths = (pathsStartToDAC * pathsDACtoFFT * pathsFFTtoEnd) +
      (pathsStartToFFT * pathsFFTtoDAC * pathsDACtoEnd)

    return totalPaths
  }


  /// Returns an Array of Nodes connected to the one passed as parameter
  private func getConnectedNotes(from node: Node, in dictionary: [String: Node]) -> [Node] {
    var array: [Node] = []

    for n in node.connections {
      if let connectedNode = dictionary[n] {
        array.append(connectedNode)
      }
    }

    return array
  }

  /// Returns the number of paths that lead from a Node to another
  private func getAllPathsCount(
    from currentNode: Node,
    to finalNode: Node,
    in dictionary: [String: Node],
    memo: inout [String: Int]
  ) -> Int {
    if currentNode.name == finalNode.name { return 1 }
    if let cached = memo[currentNode.name] { return cached }

    var paths = 0
    for connectedName in currentNode.connections {
      if let nextNode = dictionary[connectedName] {
        paths += getAllPathsCount(from: nextNode, to: finalNode, in: dictionary, memo: &memo)
      }
    }

    memo[currentNode.name] = paths
    return paths
  }

}

/// A struct modeling a node in the machines DAG
private struct Node {
  let name: String

  /// The names of the Nodes it is connected to
  let connections: [String]
}