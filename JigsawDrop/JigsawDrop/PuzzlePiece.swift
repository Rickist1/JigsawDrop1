//
//  PuzzlePiece.swift
//  JigsawDrop
//
//  Created by Richard Carman on 5/23/25.
//

import SpriteKit

enum PieceType: CaseIterable {
    case corner
    case edge
    case interior
}

// Edge types for jigsaw connection
enum EdgeType {
    case flat    // For border pieces
    case tab     // Protruding connector
    case blank   // Indented connector
}

// Rotation states
enum PieceOrientation: Int, CaseIterable {
    case north = 0    // 0 degrees
    case east = 90    // 90 degrees
    case south = 180  // 180 degrees
    case west = 270   // 270 degrees
    
    var degrees: Int { return rawValue }
    
    func rotated() -> PieceOrientation {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }
}

// Define the exact shape of each piece
struct PieceShape {
    let topEdge: EdgeType
    let rightEdge: EdgeType
    let bottomEdge: EdgeType
    let leftEdge: EdgeType
    
    // Rotate the shape 90 degrees clockwise
    func rotated() -> PieceShape {
        return PieceShape(
            topEdge: leftEdge,
            rightEdge: topEdge,
            bottomEdge: rightEdge,
            leftEdge: bottomEdge
        )
    }
}

class PuzzlePiece: SKSpriteNode {
    // UNIQUE POSITION: Each piece has exactly one correct spot
    let correctRow: Int
    let correctColumn: Int
    
    // UNIQUE SHAPE: Each piece has a unique combination of edges
    let originalShape: PieceShape
    var currentShape: PieceShape
    var currentOrientation: PieceOrientation = .north
    
    // PIECE METADATA
    let pieceType: PieceType
    let pieceID: String
    var isCorrectlyPlaced: Bool = false
    var isLocked: Bool = false
    
    // MANUAL PLACEMENT STATE
    var isBeingDragged: Bool = false
    var isDragEnabled: Bool = true
    
    // TIMING FOR SCORING
    var spawnTime: TimeInterval = 0
    
    init(row: Int, column: Int, type: PieceType, shape: PieceShape, imageTexture: SKTexture) {
        self.correctRow = row
        self.correctColumn = column
        self.pieceType = type
        self.originalShape = shape
        self.currentShape = shape
        self.pieceID = "piece_\(row)_\(column)"
        
        super.init(texture: imageTexture, color: .clear, size: imageTexture.size())
        
        self.name = "puzzlePiece"
        self.zPosition = 1
        self.isUserInteractionEnabled = true
        
        // Add subtle glow effect for better visibility
        let glowEffect = SKSpriteNode(texture: imageTexture)
        glowEffect.alpha = 0.3
        glowEffect.zPosition = -1
        glowEffect.scale(to: CGSize(width: size.width * 1.1, height: size.height * 1.1))
        glowEffect.color = .white
        glowEffect.colorBlendFactor = 1.0
        addChild(glowEffect)
        
        // Add piece number for debugging
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "\(row),\(column)"
        label.fontSize = 12
        label.fontColor = .black
        label.position = CGPoint.zero
        label.zPosition = 2
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MANUAL ROTATION: Players must rotate to correct orientation
    func rotatePiece() {
        guard !isLocked && isDragEnabled else { return }
        
        // Update orientation and shape
        currentOrientation = currentOrientation.rotated()
        currentShape = currentShape.rotated()
        
        // Play enhanced rotation animation from VisualManager
        VisualManager.shared.animatePieceRotation(piece: self) {
            // Animation completed
        }
        
        print("🔄 Piece \(pieceID) rotated to \(currentOrientation) (\(currentOrientation.degrees)°)")
    }
    
    // CHECK IF PIECE IS IN CORRECT POSITION AND ORIENTATION
    func checkCorrectPlacement(gridRow: Int, gridColumn: Int) -> Bool {
        // Must be in correct grid position
        let correctPosition = (gridRow == correctRow && gridColumn == correctColumn)
        
        // Must be in correct orientation (0 degrees = north)
        let correctOrientation = (currentOrientation == .north)
        
        isCorrectlyPlaced = correctPosition && correctOrientation
        
        print("🧩 Piece \(pieceID) placement check:")
        print("🧩 - Position: (\(gridRow), \(gridColumn)) vs correct (\(correctRow), \(correctColumn)) = \(correctPosition)")
        print("🧩 - Orientation: \(currentOrientation) vs correct (.north) = \(correctOrientation)")
        print("🧩 - Overall correct: \(isCorrectlyPlaced)")
        
        if isCorrectlyPlaced {
            // Visual feedback for correct placement with enhanced effects
            let currentTheme = VisualManager.shared.getCurrentTheme()
            run(SKAction.colorize(with: currentTheme.primaryColor, colorBlendFactor: 0.3, duration: 0.3))
            print("🧩 ✅ Piece \(pieceID) is CORRECTLY placed and oriented!")
            
            // Add subtle sparkle effect
            VisualManager.shared.createSparkleEffect(at: position, in: parent ?? self)
        } else {
            // Clear any color tint for incorrect placement
            run(SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.3))
            
            if correctPosition && !correctOrientation {
                // Right position, wrong orientation - give hint with theme colors
                let currentTheme = VisualManager.shared.getCurrentTheme()
                run(SKAction.colorize(with: currentTheme.secondaryColor, colorBlendFactor: 0.3, duration: 0.3))
                print("🧩 🟡 Piece \(pieceID) is in correct position but wrong orientation!")
                
                // Small shake to indicate incorrect orientation
                VisualManager.shared.shakeNode(self, intensity: 2.0, duration: 0.1)
            }
        }
        
        return isCorrectlyPlaced
    }
    
    // CHECK IF PIECE CAN FIT AT GIVEN POSITION (considering neighboring pieces)
    func canFitAt(gridRow: Int, gridColumn: Int, grid: [[PuzzlePiece?]]) -> Bool {
        // For true jigsaw puzzle, we need to check edge compatibility
        let rows = grid.count
        let columns = grid[0].count
        
        // Check if this piece's edges match neighboring pieces
        // Top neighbor
        if gridRow + 1 < rows, let topNeighbor = grid[gridRow + 1][gridColumn] {
            if !edgesMatch(myEdge: currentShape.topEdge, neighborEdge: topNeighbor.currentShape.bottomEdge) {
                return false
            }
        }
        
        // Right neighbor
        if gridColumn + 1 < columns, let rightNeighbor = grid[gridRow][gridColumn + 1] {
            if !edgesMatch(myEdge: currentShape.rightEdge, neighborEdge: rightNeighbor.currentShape.leftEdge) {
                return false
            }
        }
        
        // Bottom neighbor
        if gridRow - 1 >= 0, let bottomNeighbor = grid[gridRow - 1][gridColumn] {
            if !edgesMatch(myEdge: currentShape.bottomEdge, neighborEdge: bottomNeighbor.currentShape.topEdge) {
                return false
            }
        }
        
        // Left neighbor
        if gridColumn - 1 >= 0, let leftNeighbor = grid[gridRow][gridColumn - 1] {
            if !edgesMatch(myEdge: currentShape.leftEdge, neighborEdge: leftNeighbor.currentShape.rightEdge) {
                return false
            }
        }
        
        return true
    }
    
    // Check if two edges are compatible
    private func edgesMatch(myEdge: EdgeType, neighborEdge: EdgeType) -> Bool {
        switch (myEdge, neighborEdge) {
        case (.tab, .blank), (.blank, .tab), (.flat, .flat):
            return true
        default:
            return false
        }
    }
    
    func lockPiece() {
        isLocked = true
        isCorrectlyPlaced = true
        isDragEnabled = false
        
        // Visual feedback for locked piece
        run(SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.2),
            SKAction.colorize(with: .green, colorBlendFactor: 0.3, duration: 0.3)
        ]))
        
        print("🔒 Piece \(pieceID) locked in place!")
    }
    
    // Enable/disable dragging
    func setDragEnabled(_ enabled: Bool) {
        isDragEnabled = enabled
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.6
    }
    
    // Get rotation hint - how many 90° rotations needed to be correct
    func getRotationHint() -> Int {
        let currentDegrees = currentOrientation.degrees
        let targetDegrees = 0 // Always want north (0°)
        
        let degreesNeeded = (targetDegrees - currentDegrees + 360) % 360
        return degreesNeeded / 90
    }
} 