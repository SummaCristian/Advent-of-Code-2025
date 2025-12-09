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

  /// Returns the edges connecting red tiles in order, wrapping around
  private var tileLines: [TileLine] {
    let redTiles = tiles
    guard !redTiles.isEmpty else { return [] }

    var lines: [TileLine] = []
    for i in 0..<redTiles.count {
      let start = redTiles[i]
      let end = redTiles[(i + 1) % redTiles.count] // wrap-around
      lines.append(TileLine(start: start, end: end))
    }
    return lines
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
    let redTiles = self.tiles

    // Generates all possible Rectangles 
    // using all possible pairs of Red Tiles,
    // sorted by area (largest to smallest)
    let rectangles = redTiles
      .combinations(ofCount: 2)
      .map { Rectangle(firstTile: $0[0], secondTile: $0[1]) }
      .sorted { $0.area > $1.area }

    // Precomputes minX and maxX for each Y along the perimeter
    var minXByY: [Int: Int] = [:]
    var maxXByY: [Int: Int] = [:]

    for line in tileLines {
      if line.isHorizontal {
        let y = line.start.y
        let xs = [line.start.x, line.end.x]
        minXByY[y] = min(minXByY[y] ?? xs[0], xs.min()!)
        maxXByY[y] = max(maxXByY[y] ?? xs[0], xs.max()!)
      } else {
        // vertical line, update each y along line
        let x = line.start.x
        let range = min(line.start.y, line.end.y)...max(line.start.y, line.end.y)
        for y in range {
            minXByY[y] = min(minXByY[y] ?? x, x)
            maxXByY[y] = max(maxXByY[y] ?? x, x)
        }
      }
    }

    // Looks for the largest rectangle that fits 
    // entirely inside the perimeter
    var largest: Rectangle? = nil

    for rect in rectangles {
      var fits = true
      for y in rect.minY...rect.maxY {
        guard let minX = minXByY[y], let maxX = maxXByY[y] else {
          // Doesn't fit vertically
          fits = false
          break
        }
      
        if rect.minX < minX || rect.maxX > maxX {
          // Doesn't fit horizontally
          fits = false
          break
        }
      }
      
      if fits {
        largest = rect
        break
      }
    }

    // Returns the area of the largest fitting Rectangle
    return largest?.area ?? 0
  }
}

/// A struct modeling a Tile
private struct Tile: Equatable, Hashable {
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

  var minX: Int { min(firstTile.x, secondTile.x) }
  var maxX: Int { max(firstTile.x, secondTile.x) }
  var minY: Int { min(firstTile.y, secondTile.y) }
  var maxY: Int { max(firstTile.y, secondTile.y) }
}

/// A struct modeling a line of the polygon formed by the Red Tiles
fileprivate struct TileLine {
    let start: Tile
    let end: Tile

    /// True if this line is horizontal
    var isHorizontal: Bool { start.y == end.y }

    /// True if this line is vertical
    var isVertical: Bool { start.x == end.x }
}
