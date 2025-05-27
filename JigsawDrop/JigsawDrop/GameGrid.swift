//
//  GameGrid.swift
//  JigsawDrop
//
//  Created by Richard Carman on 5/23/25.
//

import SpriteKit

class GameGrid: SKNode {
    let rows: Int
    let columns: Int
    let cellSize: CGFloat
    var grid: [[PuzzlePiece?]]
    
    // Jigsaw puzzle doesn't need current row concept
    var placedPieces: Int = 0
    
    init(rows: Int, columns: Int, cellSize: CGFloat) {
        self.rows = rows
        self.columns = columns
        self.cellSize = cellSize
        
        // Initialize empty grid
        self.grid = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        
        super.init()
        
        setupGridVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGridVisuals() {
        // Create grid lines for reference - aligned with piece positioning
        // Grid lines should be at the edges of cells, pieces at centers
        
        for row in 0...rows {
            let line = SKShapeNode()
            let path = CGMutablePath()
            // Align grid lines with the same coordinate system as pieces
            let y = CGFloat(row) * cellSize - CGFloat(rows) * cellSize / 2
            path.move(to: CGPoint(x: -CGFloat(columns) * cellSize / 2, y: y))
            path.addLine(to: CGPoint(x: CGFloat(columns) * cellSize / 2, y: y))
            line.path = path
            line.strokeColor = .gray  // Back to subtle gray
            line.lineWidth = 1        // Normal line width
            line.alpha = 0.4          // Slightly more visible than before
            addChild(line)
        }
        
        for col in 0...columns {
            let line = SKShapeNode()
            let path = CGMutablePath()
            // Align grid lines with the same coordinate system as pieces
            let x = CGFloat(col) * cellSize - CGFloat(columns) * cellSize / 2
            path.move(to: CGPoint(x: x, y: -CGFloat(rows) * cellSize / 2))
            path.addLine(to: CGPoint(x: x, y: CGFloat(rows) * cellSize / 2))
            line.path = path
            line.strokeColor = .gray  // Back to subtle gray
            line.lineWidth = 1        // Normal line width
            line.alpha = 0.4          // Slightly more visible than before
            addChild(line)
        }
    }
    
    func getGridPosition(for point: CGPoint) -> (row: Int, column: Int)? {
        // Convert world position to grid coordinates
        // Use the same coordinate system as getWorldPosition for consistency
        let gridX = point.x + CGFloat(columns) * cellSize / 2
        let gridY = point.y + CGFloat(rows) * cellSize / 2
        
        // Convert to grid indices - pieces are positioned at cell centers
        let col = Int(gridX / cellSize)
        let rawRow = Int(gridY / cellSize)
        
        // FLIP Y-AXIS: Invert row to match visual expectations (row 0 at top)
        let row = (rows - 1) - rawRow
        
        if row >= 0 && row < rows && col >= 0 && col < columns {
            return (row, col)
        }
        return nil
    }
    
    func getWorldPosition(row: Int, column: Int) -> CGPoint {
        // FLIP Y-AXIS: Invert row to match visual expectations (row 0 at top)
        let visualRow = (rows - 1) - row
        
        let x = (CGFloat(column) + 0.5) * cellSize - CGFloat(columns) * cellSize / 2
        let y = (CGFloat(visualRow) + 0.5) * cellSize - CGFloat(rows) * cellSize / 2
        
        return CGPoint(x: x, y: y)
    }
    
    // Check if a piece can be placed at the given position
    func canPlacePiece(_ piece: PuzzlePiece, at row: Int, column: Int) -> Bool {
        print("🧩 Checking if piece \(piece.pieceID) can be placed at (\(row), \(column))")
        
        // Check bounds
        guard row >= 0 && row < rows && column >= 0 && column < columns else {
            print("🧩 ❌ Out of bounds")
            return false
        }
        
        // Check if position is already occupied
        guard grid[row][column] == nil else {
            print("🧩 ❌ Position already occupied")
            return false
        }
        
        // For true jigsaw puzzle: pieces can ONLY go in their correct position
        guard piece.correctRow == row && piece.correctColumn == column else {
            print("🧩 ❌ Wrong position - piece belongs at (\(piece.correctRow), \(piece.correctColumn))")
            return false
        }
        
        // Check edge compatibility with neighbors
        if !piece.canFitAt(gridRow: row, gridColumn: column, grid: grid) {
            print("🧩 ❌ Edges don't match with neighbors")
            return false
        }
        
        print("🧩 ✅ Piece can be placed!")
        return true
    }
    
    // Place a piece in the grid (only if it fits perfectly)
    func placePiece(_ piece: PuzzlePiece, at row: Int, column: Int) -> Bool {
        print("🧩 === PLACE PIECE START ===")
        print("🧩 Attempting to place piece \(piece.pieceID) at (\(row), \(column))")
        
        guard canPlacePiece(piece, at: row, column: column) else {
            print("🧩 ❌ Cannot place piece - placement rules not met")
            return false
        }
        
        // Remove piece from previous position if it exists
        removePieceFromGrid(piece)
        
        // Remove piece from its current parent before adding to grid
        piece.removeFromParent()
        piece.removeAllActions()
        
        // Place the piece
        grid[row][column] = piece
        let worldPos = getWorldPosition(row: row, column: column)
        
        piece.position = worldPos
        addChild(piece)
        
        // Check if piece is correctly placed and oriented
        let isCorrect = piece.checkCorrectPlacement(gridRow: row, gridColumn: column)
        
        if isCorrect {
            // Lock the piece in place
            piece.lockPiece()
            placedPieces += 1
            
            print("🧩 ✅ Piece correctly placed and locked! (\(placedPieces)/\(rows * columns))")
            
            // Visual celebration effect
            addPlacementEffect(at: worldPos)
        } else {
            print("🧩 🟡 Piece placed but not correctly oriented")
        }
        
        // 🔊 AUDIO FEEDBACK: Play sound and haptic for piece placement
        SoundManager.shared.playSound(.piecePlacement)
        SoundManager.shared.playHaptic(isCorrect ? .success : .light)
        
        print("🧩 === PLACE PIECE SUCCESS ===")
        return true
    }
    
    // Remove piece from grid (when picking it up)
    func removePieceFromGrid(_ piece: PuzzlePiece) {
        for row in 0..<rows {
            for col in 0..<columns {
                if grid[row][col] === piece {
                    grid[row][col] = nil
                    if piece.isLocked {
                        placedPieces -= 1
                    }
                    print("🧩 Removed piece \(piece.pieceID) from grid at (\(row), \(col))")
                    return
                }
            }
        }
    }
    
    // Check if puzzle is complete
    func isPuzzleComplete() -> Bool {
        return placedPieces == (rows * columns)
    }
    
    // Get completion percentage
    func getCompletionPercentage() -> Float {
        return Float(placedPieces) / Float(rows * columns)
    }
    
    // Find the correct position for a piece
    func getCorrectPositionForPiece(_ piece: PuzzlePiece) -> (row: Int, column: Int) {
        return (piece.correctRow, piece.correctColumn)
    }
    
    // Check if a position is the correct one for the given piece
    func isCorrectPosition(row: Int, column: Int, for piece: PuzzlePiece) -> Bool {
        return piece.correctRow == row && piece.correctColumn == column
    }
    
    // Highlight the correct position for a piece (hint system)
    func highlightCorrectPosition(for piece: PuzzlePiece) {
        // Remove previous hints
        children.filter { $0.name == "positionHint" }.forEach { $0.removeFromParent() }
        
        let correctPos = getWorldPosition(row: piece.correctRow, column: piece.correctColumn)
        
        // Create pulsing highlight
        let highlight = SKShapeNode(rectOf: CGSize(width: cellSize * 0.9, height: cellSize * 0.9), cornerRadius: 5)
        highlight.fillColor = .yellow
        highlight.strokeColor = .orange
        highlight.alpha = 0.6
        highlight.position = correctPos
        highlight.name = "positionHint"
        highlight.zPosition = -0.5
        
        // Pulsing animation
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.8),
            SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        ]))
        
        highlight.run(pulse)
        addChild(highlight)
        
        // Remove hint after 5 seconds
        highlight.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
    }
    
    // Add visual effect for successful placement
    private func addPlacementEffect(at position: CGPoint) {
        // Create sparkle effect
        let sparkle = SKEmitterNode()
        sparkle.particleBirthRate = 30
        sparkle.numParticlesToEmit = 20
        sparkle.particleLifetime = 1.0
        sparkle.particleSpeed = 50
        sparkle.particleSpeedRange = 30
        sparkle.emissionAngle = 0
        sparkle.emissionAngleRange = CGFloat.pi * 2
        sparkle.particleColor = .yellow
        sparkle.particleColorBlendFactor = 0.8
        sparkle.particleAlpha = 1.0
        sparkle.particleScale = 0.3
        sparkle.position = position
        sparkle.zPosition = 10
        
        addChild(sparkle)
        
        // Remove after animation
        sparkle.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }
    
    // Get piece at position
    func getPieceAt(row: Int, column: Int) -> PuzzlePiece? {
        guard row >= 0 && row < rows && column >= 0 && column < columns else {
            return nil
        }
        return grid[row][column]
    }
    
    // Get the grid position of a placed piece
    func getGridPositionForPiece(_ piece: PuzzlePiece) -> (row: Int, column: Int)? {
        for row in 0..<rows {
            for col in 0..<columns {
                if grid[row][col] === piece {
                    return (row: row, column: col)
                }
            }
        }
        return nil // Piece not found in grid
    }
    
    // Clear all position hints
    func clearHints() {
        children.filter { $0.name == "positionHint" }.forEach { $0.removeFromParent() }
    }
    
    // Debug method to print grid state
    func debugPrintGridState() {
        print("🧩 === JIGSAW PUZZLE GRID STATE ===")
        print("🧩 Placed pieces: \(placedPieces)/\(rows * columns)")
        
        for row in (0..<rows).reversed() { // Print from top to bottom
            var rowString = "Row \(row): "
            for col in 0..<columns {
                if let piece = grid[row][col] {
                    let status = piece.isLocked ? "🔒" : "🔓"
                    rowString += "[\(piece.correctRow),\(piece.correctColumn)\(status)] "
                } else {
                    rowString += "[     ] "
                }
            }
            print("🧩 \(rowString)")
        }
        print("🧩 === END GRID STATE ===")
    }
    
    // Get the number of placed pieces
    func getPlacedPiecesCount() -> Int {
        return placedPieces
    }
} 