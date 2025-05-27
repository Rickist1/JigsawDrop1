//
//  GameManager.swift
//  JigsawDrop
//
//  Created by Richard Carman on 5/23/25.
//

import Foundation
import SpriteKit

protocol GameManagerDelegate: AnyObject {
    func gameDidEnd(success: Bool, finalScore: Int)
    func scoreDidUpdate(_ score: Int)
    func nextPieceGenerated(_ piece: PuzzlePiece)
    func puzzleCompleted()
    func piecePlacedCorrectly()
    func piecePlacedIncorrectly()
}

class GameManager {
    weak var delegate: GameManagerDelegate?
    
    private let gridRows = 6
    private let gridColumns = 6
    private var puzzlePieces: [[PuzzlePiece]] = []
    private var availablePieces: [PuzzlePiece] = []
    private var currentPieceIndex = 0
    
    // Game state
    private var isGeneratingPiece = false
    private var gameActive = false
    private var puzzleComplete = false
    
    var score: Int = 0 {
        didSet {
            delegate?.scoreDidUpdate(score)
            updateHighScore()
        }
    }
    
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "JigsawDropHighScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "JigsawDropHighScore")
        }
    }
    
    init() {
        print("🧩 JigsawPuzzle GameManager.init() called")
        generateJigsawPuzzle()
        print("🧩 Generated \(puzzlePieces.count) rows x \(puzzlePieces.first?.count ?? 0) columns of puzzle pieces")
    }
    
    func startGame() {
        print("🧩 Starting jigsaw puzzle game")
        gameActive = true
        puzzleComplete = false
        isGeneratingPiece = false
        
        // Shuffle all pieces for random selection
        availablePieces = puzzlePieces.flatMap { $0 }
        availablePieces.shuffle()
        currentPieceIndex = 0
        
        print("🧩 Shuffled \(availablePieces.count) pieces for manual placement")
        
        // Generate the first piece
        generateNextPiece()
    }
    
    private func generateJigsawPuzzle() {
        print("🧩 Generating jigsaw puzzle...")
        
        // Initialize the puzzle grid
        puzzlePieces = Array(repeating: Array(repeating: PuzzlePiece(row: 0, column: 0, type: .corner, shape: PieceShape(topEdge: .flat, rightEdge: .flat, bottomEdge: .flat, leftEdge: .flat), imageTexture: createPieceTexture(for: 0, column: 0, shape: PieceShape(topEdge: .flat, rightEdge: .flat, bottomEdge: .flat, leftEdge: .flat))), count: gridColumns), count: gridRows)
        
        // Generate compatible jigsaw pieces
        for row in 0..<gridRows {
            for col in 0..<gridColumns {
                let pieceType = determinePieceType(row: row, col: col)
                let pieceShape = generatePieceShape(row: row, col: col)
                let texture = createPieceTexture(for: row, column: col, shape: pieceShape)
                
                puzzlePieces[row][col] = PuzzlePiece(
                    row: row,
                    column: col,
                    type: pieceType,
                    shape: pieceShape,
                    imageTexture: texture
                )
                
                print("🧩 Generated piece (\(row),\(col)): \(pieceType) with edges T:\(pieceShape.topEdge) R:\(pieceShape.rightEdge) B:\(pieceShape.bottomEdge) L:\(pieceShape.leftEdge)")
            }
        }
        
        print("🧩 Jigsaw puzzle generation complete!")
    }
    
    private func determinePieceType(row: Int, col: Int) -> PieceType {
        let isTopRow = (row == gridRows - 1)
        let isBottomRow = (row == 0)
        let isLeftCol = (col == 0)
        let isRightCol = (col == gridColumns - 1)
        
        if (isTopRow || isBottomRow) && (isLeftCol || isRightCol) {
            return .corner
        } else if isTopRow || isBottomRow || isLeftCol || isRightCol {
            return .edge
        } else {
            return .interior
        }
    }
    
    private func generatePieceShape(row: Int, col: Int) -> PieceShape {
        let isTopRow = (row == gridRows - 1)
        let isBottomRow = (row == 0)
        let isLeftCol = (col == 0)
        let isRightCol = (col == gridColumns - 1)
        
        // Border edges are always flat
        let topEdge: EdgeType = isTopRow ? .flat : (Bool.random() ? .tab : .blank)
        let rightEdge: EdgeType = isRightCol ? .flat : (Bool.random() ? .tab : .blank)
        let bottomEdge: EdgeType = isBottomRow ? .flat : (Bool.random() ? .tab : .blank)
        let leftEdge: EdgeType = isLeftCol ? .flat : (Bool.random() ? .tab : .blank)
        
        return PieceShape(topEdge: topEdge, rightEdge: rightEdge, bottomEdge: bottomEdge, leftEdge: leftEdge)
    }
    
    private func createPieceTexture(for row: Int, column: Int, shape: PieceShape) -> SKTexture {
        let size = CGSize(width: 60, height: 60)
        
        // Create a unique color for each piece based on position
        let hue = CGFloat(row * gridColumns + column) / CGFloat(gridRows * gridColumns)
        let color = UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1.0)
        
        // Generate the jigsaw piece texture with the specific shape
        return VisualManager.shared.generatePuzzlePieceTexture(
            size: size,
            color: color,
            hasTopTab: (shape.topEdge == .tab),
            hasRightTab: (shape.rightEdge == .tab),
            hasBottomTab: (shape.bottomEdge == .tab),
            hasLeftTab: (shape.leftEdge == .tab)
        )
    }
    
    func generateNextPiece() {
        print("🧩 === GENERATE NEXT PIECE START ===")
        print("🧩 gameActive: \(gameActive)")
        print("🧩 isGeneratingPiece: \(isGeneratingPiece)")
        print("🧩 currentPieceIndex: \(currentPieceIndex)")
        print("🧩 availablePieces.count: \(availablePieces.count)")
        
        // Prevent duplicate piece generation
        guard gameActive && !isGeneratingPiece && !puzzleComplete else {
            print("🧩 Blocked piece generation")
            return
        }
        
        // Check if we have pieces left
        guard currentPieceIndex < availablePieces.count else {
            print("🧩 No more pieces available")
            return
        }
        
        isGeneratingPiece = true
        
        // Get the next piece
        let piece = availablePieces[currentPieceIndex]
        currentPieceIndex += 1
        
        print("🧩 Generated piece: \(piece.pieceID) for position (\(piece.correctRow), \(piece.correctColumn))")
        
        // Add some random rotation to make it challenging
        let randomRotations = Int.random(in: 0...3)
        for _ in 0..<randomRotations {
            piece.rotatePiece()
        }
        
        print("🧩 Piece rotated \(randomRotations) times, current orientation: \(piece.currentOrientation)")
        
        delegate?.nextPieceGenerated(piece)
        
        isGeneratingPiece = false
        print("🧩 === GENERATE NEXT PIECE END ===")
    }
    
    func pieceCorrectlyPlaced(piece: PuzzlePiece) {
        score += 100
        delegate?.piecePlacedCorrectly()
        
        // Check for theme unlocks based on score milestones
        checkThemeUnlocks()
        
        // Check if puzzle is complete
        checkPuzzleCompletion()
    }
    
    private func checkThemeUnlocks() {
        // Unlock themes based on score achievements
        if score >= 1000 && !GameTheme.ocean.isUnlocked {
            GameTheme.ocean.unlock()
            showThemeUnlockedMessage(.ocean)
        }
        
        if score >= 2500 && !GameTheme.forest.isUnlocked {
            GameTheme.forest.unlock()
            showThemeUnlockedMessage(.forest)
        }
        
        if score >= 5000 && !GameTheme.neon.isUnlocked {
            GameTheme.neon.unlock()
            showThemeUnlockedMessage(.neon)
        }
    }
    
    private func showThemeUnlockedMessage(_ theme: GameTheme) {
        // Notify delegate about theme unlock (could be handled in GameScene)
        print("🎨 Theme unlocked: \(theme.displayName)")
        // This could trigger a celebration animation in the UI
    }
    
    func pieceIncorrectlyPlaced() {
        score = max(0, score - 10) // Small penalty for incorrect placement
        delegate?.piecePlacedIncorrectly()
    }
    
    private func checkPuzzleCompletion() {
        var correctPieces = 0
        let totalPieces = gridRows * gridColumns
        
        for row in puzzlePieces {
            for piece in row {
                if piece.isCorrectlyPlaced && piece.isLocked {
                    correctPieces += 1
                }
            }
        }
        
        print("🧩 Puzzle progress: \(correctPieces)/\(totalPieces) pieces correctly placed")
        
        if correctPieces == totalPieces {
            puzzleComplete = true
            gameActive = false
            score += 1000 // Completion bonus
            delegate?.puzzleCompleted()
            delegate?.gameDidEnd(success: true, finalScore: score)
            print("🧩 🎉 PUZZLE COMPLETED!")
        }
    }
    
    // Get a hint for the current piece
    func getHintForPiece(_ piece: PuzzlePiece) -> String {
        let rotationsNeeded = piece.getRotationHint()
        let rowHint = piece.correctRow + 1 // 1-based for user display
        let colHint = piece.correctColumn + 1 // 1-based for user display
        
        var hint = "Position: Row \(rowHint), Column \(colHint)"
        
        if rotationsNeeded > 0 {
            hint += "\nNeed \(rotationsNeeded) more rotation(s)"
        } else {
            hint += "\nCorrect orientation!"
        }
        
        return hint
    }
    
    // Force generate next piece (for external triggers)
    func forceGenerateNextPiece() {
        print("🧩 forceGenerateNextPiece() called")
        isGeneratingPiece = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.generateNextPiece()
        }
    }
    
    // Get remaining pieces count
    func getRemainingPiecesCount() -> Int {
        return max(0, availablePieces.count - currentPieceIndex)
    }
    
    // Get next pieces for preview (up to count)
    func getNextPieces(count: Int) -> [PuzzlePiece] {
        let remainingCount = availablePieces.count - currentPieceIndex
        let actualCount = min(count, remainingCount)
        
        guard actualCount > 0 else { return [] }
        
        let endIndex = currentPieceIndex + actualCount
        return Array(availablePieces[currentPieceIndex..<endIndex])
    }
    
    private func updateHighScore() {
        if score > highScore {
            highScore = score
        }
    }
    
    func resetHighScore() {
        highScore = 0
        print("🧩 High score reset to 0")
    }
    
    // Debug method to get current state
    func getGameState() -> String {
        return """
        JigsawPuzzle GameState:
        - gameActive: \(gameActive)
        - puzzleComplete: \(puzzleComplete)
        - currentPieceIndex: \(currentPieceIndex)
        - availablePieces.count: \(availablePieces.count)
        - remainingPieces: \(getRemainingPiecesCount())
        - isGeneratingPiece: \(isGeneratingPiece)
        """
    }
}

// PieceShape is now a struct, not an enum, so no CaseIterable needed 