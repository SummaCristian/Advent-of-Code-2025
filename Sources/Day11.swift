import Algorithms

struct Day11: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // --- Constants ---
  private static let initialMachineName = "you"
  private static let finalMachineName = "out"

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

    guard let initialNode = machines[Day11.initialMachineName],
      let finalNode = machines[Day11.finalMachineName] else {
        fatalError("No initial or final Machines to be found in input")
      }
    
    // Computes all paths from initialNode to finalNode
    let paths = getAllPaths(from: initialNode, to: finalNode, in: machines)

    // Returns the number of paths
    return paths.count
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
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

  /// Returns the list of paths that lead from a Node to another
  private func getAllPaths(
    from initialNode: Node,
    to finalNode: Node,
    in dictionary: [String: Node]
  ) -> [[Node]] {
    var paths: [[Node]] = []

    func dfs(currentNode: Node, currentPath: [Node]) {
      var currentPath = currentPath
      currentPath.append(currentNode)

      if currentNode.name == finalNode.name {
        // Reached the end, save the path
        paths.append(currentPath)
        return
      }

      // Explore all connected nodes
      for connectedName in currentNode.connections {
        if let nextNode = dictionary[connectedName] {
          dfs(currentNode: nextNode, currentPath: currentPath)
        }
      }
    }

    dfs(currentNode: initialNode, currentPath: [])
    return paths
  }

}

/// A struct modeling a node in the machines DAG
private struct Node {
  let name: String

  /// The names of the Nodes it is connected to
  let connections: [String]
}