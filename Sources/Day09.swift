import Algorithms

struct Day09: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  /// Converts the input String into a list of Tile objects
  private var tiles: [Tile] {
    data
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: "\n")
        .map { line in
            let coords = line.split(separator: ",")
            .compactMap { Int(String($0)) }

            return Tile(x: coords[0], y: coords[1])
        }
  }

  // Solves the first part of the problem
  func part1() -> Any {
    let redTiles = self.tiles

    // Generates all possible Rectangles 
    // using all possible pairs of Red Tiles
    let rectangles = redTiles
        .combinations(ofCount: 2)
        .map { Rectangle(firstTile: $0[0], secondTile: $0[1]) }
    
    // Find the largest area among those Rectangles
    let maxArea = rectangles
        .map { $0.area }
        .max()
    
    return maxArea ?? 0
  }

  // Solves the second part of the problem
  func part2() -> Any {
    return "Not implemented yet"
  }
}

/// A struct modeling a red Tile
private struct Tile {
    let x: Int
    let y: Int
}

/// A struct modeling a Rectangle with 
/// red Tiles in opposite corners
private struct Rectangle {
    let firstTile: Tile
    let secondTile: Tile

    /// The area of the Rectangle
    var area: Int {
        let x = abs(firstTile.x - secondTile.x) + 1
        let y = abs(firstTile.y - secondTile.y) + 1

        return x * y
    }
}
