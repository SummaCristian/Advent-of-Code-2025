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

    // Grab costant nodes: Start and End
    guard let start = machines[Day11.initialMachineName2],
      let end = machines[Day11.finalMachineName] else {
      fatalError("Start or end node not found")
    }

    // Grab required intermediate nodes
    let requiredNodes = [Day11.dacMachineName, Day11.fourierMachineName]

    // Compute all possible order permutations of the intermediate required nodes
    let permutations = requiredNodes.permutations()
    var totalPaths = 0

    // Compute the number of paths going from start -> intermediate1 -> ... -> end
    // for every permutation of the intermediate nodes
    for perm in permutations {
      let nodeSequence: [Node] = [start] + perm.compactMap { machines[$0] } + [end]

      var pathsForPerm = 1
      for i in 0..<(nodeSequence.count - 1) {
        var memo: [String: Int] = [:]
        pathsForPerm *= getAllPathsCount(from: nodeSequence[i],
                                         to: nodeSequence[i+1],
                                         in: machines,
                                         memo: &memo)
      }

      totalPaths += pathsForPerm
    }

    // Return the total number of paths from start -> end, passing through all intermediate nodes
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