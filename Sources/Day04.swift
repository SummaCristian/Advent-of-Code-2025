import Algorithms

struct Day04: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // --- Constants ---
    private static let rollChar = "@"
    private static let emptyChar = "."
    private static let maxRollNeighbours = 3

    // Convert the data into a matrix of booleans, true = roll, false = empty
    var grid: [[Bool]] {
        data.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .map { row in
                row.map { String($0) == Day04.rollChar }
            }
    }

    // Solves the first part of the problem
    func part1() -> Any {
        let grid = self.grid
        var accessibleRolls = 0
        
        for row in grid.enumerated() {
            for column in row.element.enumerated() {
                // Only check slots containing a roll
                guard grid[row.offset][column.offset] else { continue }

                let isSlotAccessible = isAccessible(
                    at: (row: row.offset, column: column.offset),
                    requiring: Day04.maxRollNeighbours,
                    in: grid
                )

                accessibleRolls += isSlotAccessible ? 1 : 0
            }
        }

        // Return the total number of accessible rolls
        return accessibleRolls
    }

    // Solves the second part of the problem
    func part2() -> Any {
        var grid = self.grid
        var removedRolls = 0
        
        var modified = false
        repeat {
            modified = false
            
            for row in grid.enumerated() {
            for column in row.element.enumerated() {
                // Only check slots containing a roll
                guard grid[row.offset][column.offset] else { continue }

                let isSlotAccessible = isAccessible(
                    at: (row: row.offset, column: column.offset),
                    requiring: Day04.maxRollNeighbours,
                    in: grid
                )

                // Remove the roll if it's accessible
                if isSlotAccessible {
                    grid[row.offset][column.offset] = false
                    removedRolls += 1
                    modified = true
                }
            }
        }

        } while modified

        return removedRolls

    }

    /// Returns a Bool indicating whether the element in the 
    /// given coordinates in the grid has less than the max number
    /// of rolls allowed in its vicinity
    private func isAccessible(
        at position: (row: Int, column: Int),
        requiring maxRollNeighbours: Int,
        in rollGrid: [[Bool]]
    ) -> Bool {
        var rollNeighbours = 0
        let offsets = [-1, 0, 1]

        for rowOffset in offsets {
            for columOffset in offsets {
                // Skip the element itself
                guard !(rowOffset == 0 && columOffset == 0) else { continue }

                let neighbour = (
                    row: position.row + rowOffset,
                    column: position.column + columOffset
                )

                // Skip off-grid neighbours
                guard isInGrid(neighbour, in: rollGrid) else { continue }

                if rollGrid[neighbour.row][neighbour.column] {
                    rollNeighbours += 1
                    if rollNeighbours > maxRollNeighbours {
                        return false
                    }
                }
            }
        }

        return true
    }

    /// Checks if the element's coordinates belong to the given grid/matrix
    private func isInGrid(
        _ position: (row: Int, column: Int),
        in grid: [[Bool]]
    ) -> Bool {
        guard !grid.isEmpty else { return false }

        return position.row >= 0 &&
            position.row < grid.count &&
            position.column >= 0 &&
            position.column < grid[position.row].count
    }
}
