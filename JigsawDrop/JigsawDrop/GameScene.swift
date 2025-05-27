//
//  GameScene.swift
//  JigsawDrop
//
//  Created by Richard Carman on 5/23/25.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene {
    
    // Game components
    private var gameManager: GameManager!
    private var gameGrid: GameGrid!
    private var currentPiece: PuzzlePiece?
    
    // Grid configuration (can be set by difficulty selection later)
    private var selectedRows: Int = 6 // Default
    private var selectedColumns: Int = 6 // Default
    
    // UI Elements
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var instructionLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    
    // Progress Indicators
    private var progressBar: SKShapeNode!
    private var progressFill: SKSpriteNode!
    private var pieceCountLabel: SKLabelNode!
    private var progressPercentLabel: SKLabelNode!
    
    // Preview Window
    private var previewWindow: SKSpriteNode!
    private var previewTitleLabel: SKLabelNode!
    private var nextPiecesContainer: SKNode!
    
    // Grid Enhancements
    private var gridLines: SKNode!
    private var dropZoneHighlights: [SKSpriteNode] = []
    private var pieceShadow: SKSpriteNode?
    
    // Tab System
    private var tabBar: SKNode!
    private var homeTab: SKSpriteNode!
    private var settingsTab: SKSpriteNode!
    private var currentTab: TabType = .home
    
    enum TabType {
        case home
        case settings
    }
    
    // Game state
    private var gameIsPaused = false
    private var isGameOver = false
    
    // CLEANED UP: Simplified touch handling
    private var touchStartPosition: CGPoint = .zero
    private var touchStartTime: TimeInterval = 0
    private var isDragging = false
    private var hasMovedSignificantly = false
    private let tapThreshold: TimeInterval = 0.25 // More generous tap window
    private let swipeThreshold: CGFloat = 15.0    // Very sensitive swipes
    private let dragThreshold: CGFloat = 3.0      // Extremely responsive dragging
    private var lastTouchTime: TimeInterval = 0
    private let doubleTapThreshold: TimeInterval = 0.25 // Faster double tap
    private let touchRadius: CGFloat = 300.0      // Extremely large touch area for maximum responsiveness
    
    // IMPROVED: Game progression and scoring
    private var currentLevel = 1
    private var consecutiveCorrect = 0
    private var timeSinceSpawn: TimeInterval = 0
    private var piecesPlaced = 0
    
    // ENHANCED: Visual feedback
    private var dropZoneIndicator: SKShapeNode?
    private var comboLabel: SKLabelNode?
    
    // MARK: - Enhanced Falling Mechanics
    
    private var fallingTimer: Timer?
    private var isFalling: Bool = false
    private let baseFallSpeed: TimeInterval = 0.6 // Faster base speed
    private let fallDistance: CGFloat = 12.0 // Larger increments for smoother movement
    private var currentFallAction: SKAction?
    
    // Visual feedback management
    private var feedbackLabel: SKLabelNode?
    private var feedbackUpdateTimer: Timer?
    
    override func didMove(to view: SKView) {
        print("🎯 DEBUG: GameScene didMove(to:) called")
        print("🎯 DEBUG: Scene size: \(size)")
        
        // Initialize sound manager
        SoundManager.shared.loadSettings()
        print("🔊 DEBUG: Sound manager initialized - Sound: \(SoundManager.shared.soundEnabled), Haptic: \(SoundManager.shared.hapticEnabled)")
        
        // Start background music
        SoundManager.shared.startBackgroundMusic()
        print("🎵 DEBUG: Background music started - Music enabled: \(SoundManager.shared.musicEnabled)")
        
        // Show loading screen first
        VisualManager.shared.createLoadingScreen(in: self) { [weak self] in
            // After loading completes, setup the game
            self?.setupScene()
            self?.setupGameComponents()
            self?.setupUI()
            self?.startGame()
        }
    }
    
    private func setupScene() {
        // Create beautiful gradient background with theme support
        let backgroundTexture = VisualManager.shared.generateThemeBackground(size: size)
        let backgroundSprite = SKSpriteNode(texture: backgroundTexture)
        backgroundSprite.position = CGPoint.zero
        backgroundSprite.zPosition = -10
        addChild(backgroundSprite)
        
        // Add floating particles for ambient atmosphere
        VisualManager.shared.createFloatingParticles(in: self, count: 30)
        
        // Set scene size to fit the screen
        if let view = view {
            size = view.bounds.size
        }
        
        // MAJOR FIX: Use center-based coordinate system for predictable positioning
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        print("🎯 DEBUG: Set scene anchor point to (0.5,0.5) - center")
        print("🎯 DEBUG: Scene size after setup: \(size)")
        
        // Start theme-appropriate ambient sounds
        SoundManager.shared.startThemeAmbientSound(theme: VisualManager.shared.getCurrentTheme().rawValue)
    }
    
    private func setupGameComponents() {
        print("🎯 DEBUG: setupGameComponents() called with selectedGrid: \(self.selectedRows)x\(self.selectedColumns)")

        // selectedRows and selectedColumns are now set by GameViewController before scene is presented.
        // Remove hardcoded values:
        // selectedRows = 8 
        // selectedColumns = 8

        // Create game manager first
        print("🎯 DEBUG: About to create GameManager with grid: \(self.selectedRows)x\(self.selectedColumns)")
        gameManager = GameManager(rows: self.selectedRows, columns: self.selectedColumns) // Initialize with selected size
        print("🎯 DEBUG: GameManager created: \(gameManager != nil)")
        gameManager.delegate = self
        print("🎯 DEBUG: Delegate set. gameManager.delegate is: \(gameManager.delegate != nil ? "NOT NIL" : "NIL")")

        // Calculate available space for the grid (e.g., 90% width, 60% height, adjust as needed)
        let availableWidth = self.size.width * 0.9
        let topMarginForUI: CGFloat = 150 // Space for score, progress, etc.
        let bottomMarginForUI: CGFloat = 80 // Space for tab bar or controls
        let availableHeight = self.size.height - topMarginForUI - bottomMarginForUI
        
        // Calculate cellSize based on available space and selected grid dimensions
        let cellWidth = availableWidth / CGFloat(selectedColumns)
        let cellHeight = availableHeight / CGFloat(selectedRows)
        let calculatedCellSize = min(cellWidth, cellHeight)
        
        print("🎯 DEBUG: Available Width: \(availableWidth), Available Height: \(availableHeight) for grid")
        print("🎯 DEBUG: Calculated CellSize: \(calculatedCellSize) (from cellWidth: \(cellWidth), cellHeight: \(cellHeight)) for \(self.selectedRows)x\(self.selectedColumns) grid")

        // Communicate cell size to GameManager. 
        // Grid size is already set during GameManager initialization.
        // The setGridSize call here would be redundant and cause a double puzzle generation.
        gameManager.setCellSize(calculatedCellSize) // This will trigger piece regeneration if necessary if cell size implies different texture needs

        // Create game grid
        gameGrid = GameGrid(rows: self.selectedRows, columns: self.selectedColumns, cellSize: calculatedCellSize)
        
        // Adjust gameGrid position: Center it, considering the top UI and bottom tab bar.
        // The grid's internal content is already centered (SKNode origin is center).
        // We want to position the center of the gameGrid node in the center of the available vertical space.
        let gridTotalHeight = calculatedCellSize * CGFloat(selectedRows) // Total height of the grid content
        
        // Calculate the Y coordinate of the center of the available space for the grid.
        // topMarginForUI is from scene top (self.size.height / 2) downwards.
        // bottomMarginForUI is from scene bottom (-self.size.height / 2) upwards.
        // Center of available space = ((self.size.height / 2 - topMarginForUI) + (-self.size.height / 2 + bottomMarginForUI)) / 2
        // This simplifies to (bottomMarginForUI - topMarginForUI) / 2.
        let centerYOfAvailableSpace = (bottomMarginForUI - topMarginForUI) / 2
        
        gameGrid.position = CGPoint(x: 0, y: centerYOfAvailableSpace)

        addChild(gameGrid)
        print("🎯 DEBUG: Created and added gameGrid at position \(gameGrid.position)")
        print("🎯 DEBUG: Grid total height: \(gridTotalHeight), Target Y for grid center: \(centerYOfAvailableSpace)")
        print("🎯 DEBUG: Screen size: \(size)")
    }
    
    private func setupUI() {
        // CENTER-BASED UI POSITIONING
        // With anchor point (0.5, 0.5), we position relative to center
        let topEdge = self.size.height / 2
        let leftEdge = -self.size.width / 2
        let rightEdge = self.size.width / 2
        
        // Score label - top left with modern font
        scoreLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if scoreLabel.fontName == nil {
            scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        }
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 22 // Adjusted for potentially less space
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: leftEdge + 20, y: topEdge - 40)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // High score label - top center with modern font
        let highScoreLabel = SKLabelNode(fontNamed: "SF Pro Text")
        if highScoreLabel.fontName == nil {
            highScoreLabel.fontName = "Helvetica"
        }
        highScoreLabel.text = "Best: \(gameManager.highScore)"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = .lightGray
        highScoreLabel.position = CGPoint(x: 0, y: topEdge - 30)
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.name = "highScoreLabel"
        addChild(highScoreLabel)
        
        // Completion label - top left below score with modern font
        levelLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if levelLabel.fontName == nil {
            levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        }
        levelLabel.text = "Complete: 0%"
        levelLabel.fontSize = 18 // Adjusted
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: leftEdge + 20, y: topEdge - 70)
        levelLabel.horizontalAlignmentMode = .left
        addChild(levelLabel)
        
        // Control buttons
        createControlButtons() // Positions relative to screen edges/center
        
        // Setup new UI elements
        setupProgressIndicators() // Positions relative to screen edges/center
        setupPreviewWindow()      // Positions relative to screen edges/center
        setupGridEnhancements()   // Related to gameGrid, should be fine
        setupTabSystem()          // Bottom of screen, relative
    }
    
    private func setupProgressIndicators() {
        let topEdge = self.size.height / 2
        // Create glassmorphism progress panel
        let panelWidth: CGFloat = min(self.size.width * 0.5, 220) // Responsive width
        let progressPanel = VisualManager.shared.createGlassmorphismPanel(size: CGSize(width: panelWidth, height: 40))
        // Positioned more towards center top, below high score
        progressPanel.position = CGPoint(x: 0, y: topEdge - 65) 
        progressPanel.zPosition = 1
        addChild(progressPanel)
        
        // Progress bar background with rounded corners
        progressBar = SKShapeNode(rectOf: CGSize(width: panelWidth - 20, height: 20), cornerRadius: 10)
        progressBar.fillColor = .darkGray
        progressBar.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor.withAlphaComponent(0.5)
        progressBar.lineWidth = 1
        progressBar.position = CGPoint.zero
        progressBar.zPosition = 2
        progressPanel.addChild(progressBar)
        
        // Progress bar fill with gradient effect
        progressFill = SKSpriteNode(color: VisualManager.shared.getCurrentTheme().primaryColor, size: CGSize(width: 0, height: 18))
        progressFill.position = CGPoint(x: -(panelWidth - 20)/2, y: 0) // Anchor left of progress bar
        progressFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressFill.zPosition = 3
        progressBar.addChild(progressFill)
        
        // Progress percentage label with modern font
        progressPercentLabel = SKLabelNode(fontNamed: "SF Pro Text")
        if progressPercentLabel.fontName == nil {
            progressPercentLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        }
        progressPercentLabel.text = "0%"
        progressPercentLabel.fontSize = 14
        progressPercentLabel.fontColor = .white
        progressPercentLabel.position = CGPoint(x: 0, y: -7) // Centered in the bar
        progressPercentLabel.horizontalAlignmentMode = .center
        progressPercentLabel.zPosition = 4
        progressBar.addChild(progressPercentLabel)
        
        // Add subtle pulsing animation to progress bar
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        // progressPanel.run(SKAction.repeatForever(pulseAction)) // Can be distracting, make optional
    }
    
    private func createControlButtons() {
        let topEdge = self.size.height / 2
        let rightEdge = self.size.width / 2
        // PAUSE button - top right with pause symbol
        let pauseLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        pauseLabel.text = "⏸" // Pause symbol
        pauseLabel.fontSize = 28 // Slightly smaller if needed
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: rightEdge - 30, y: topEdge - 30)
        pauseLabel.horizontalAlignmentMode = .center
        pauseLabel.verticalAlignmentMode = .center
        pauseLabel.name = "pauseButton"
        pauseLabel.zPosition = 150
        addChild(pauseLabel)
    }
    
    private func createBeautifulButton(text: String, size: CGSize, position: CGPoint, color: UIColor, name: String, fontSize: CGFloat) {
        // Create button texture
        let buttonTexture = VisualManager.shared.generateButtonTexture(size: size, baseColor: color)
        let buttonSprite = SKSpriteNode(texture: buttonTexture)
        buttonSprite.position = position
        buttonSprite.name = name
        buttonSprite.zPosition = 1
        addChild(buttonSprite)
        
        // Add subtle text shadow first (behind the main text)
        let shadow = SKLabelNode(fontNamed: "Helvetica-Bold")
        shadow.text = text
        shadow.fontSize = fontSize
        shadow.fontColor = .black
        shadow.alpha = 0.7
        shadow.position = CGPoint(x: 1, y: -1)  // Fixed positioning - simple offset
        shadow.horizontalAlignmentMode = .center
        shadow.verticalAlignmentMode = .center
        shadow.zPosition = 1
        
        // Add main label with better typography
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)  // Fixed positioning - center of button
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 2  // Ensure text is on top
        
        buttonSprite.addChild(shadow)
        buttonSprite.addChild(label)
    }
    
    private func createBeautifulOverlayButton(text: String, size: CGSize, position: CGPoint, color: UIColor, name: String, fontSize: CGFloat, zPosition: CGFloat) {
        // Create button texture
        let buttonTexture = VisualManager.shared.generateButtonTexture(size: size, baseColor: color)
        let buttonSprite = SKSpriteNode(texture: buttonTexture)
        buttonSprite.position = position
        buttonSprite.name = name
        buttonSprite.zPosition = zPosition
        addChild(buttonSprite)
        
        // Add subtle text shadow first (behind the main text)
        let shadow = SKLabelNode(fontNamed: "Helvetica-Bold")
        shadow.text = text
        shadow.fontSize = fontSize
        shadow.fontColor = .black
        shadow.alpha = 0.7
        shadow.position = CGPoint(x: 1, y: -1)  // Fixed positioning - simple offset
        shadow.horizontalAlignmentMode = .center
        shadow.verticalAlignmentMode = .center
        shadow.zPosition = 1
        
        // Add main label with better typography
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)  // Fixed positioning - center of button
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 2  // Ensure text is on top
        
        buttonSprite.addChild(shadow)
        buttonSprite.addChild(label)
    }
    
    private func updateSettingsButton(name: String, text: String, color: UIColor, position: CGPoint) {
        // Remove the old button
        childNode(withName: name)?.removeFromParent()
        
        // Create a new button with updated appearance
        createBeautifulOverlayButton(
            text: text,
            size: CGSize(width: 200, height: 50),
            position: position,
            color: color,
            name: name,
            fontSize: 18,
            zPosition: 101
        )
    }
    
    private func startGame() {
        print("🎯 DEBUG: startGame() called")
        
        if let manager = gameManager {
            print("🎯 DEBUG: gameManager exists, calling startGame()")
            manager.startGame()
            print("🎯 DEBUG: gameManager.startGame() call completed")
        } else {
            print("🎯 DEBUG: ERROR - gameManager is NIL!")
        }
    }
    
    private func dropCurrentPiece() {
        print("🧩 Manual drop requested")
        
        guard let piece = currentPiece else { 
            print("🧩 No current piece to drop!")
            return 
        }
        
        // Stop auto-falling when user manually drops
        stopAutoFall()
        
        // Piece is already visible for manual drop
        
        // FIXED: Get piece position WITHOUT constraining it - drop in current column
        let piecePositionInGrid = convert(piece.position, to: gameGrid)
        print("🧩 DEBUG: Piece position in grid: \(piecePositionInGrid)")
        
        // Try to get grid position for current piece location
        guard let gridPos = gameGrid.getGridPosition(for: piecePositionInGrid) else {
            // Fallback: Calculate column manually based on current position
            let gridWidth = CGFloat(gameGrid.columns) * gameGrid.cellSize
            let columnFloat = (piecePositionInGrid.x + gridWidth / 2) / gameGrid.cellSize
            let targetColumn = max(0, min(gameGrid.columns - 1, Int(columnFloat)))
            print("🧩 DEBUG: Fallback column calculation: \(targetColumn)")
            performManualDrop(to: targetColumn)
            return
        }
        
        let targetColumn = gridPos.column
        print("🧩 Manual drop - Current column: \(targetColumn)")
        
        performManualDrop(to: targetColumn)
    }
    
    private func performManualDrop(to targetColumn: Int) {
        guard let piece = currentPiece else { return }
        
        // Ensure column is within bounds
        let safeColumn = max(0, min(gameGrid.columns - 1, targetColumn))
        
        // Find the lowest available row in this column (Tetris-style stacking)
        var targetRow = gameGrid.rows - 1
        
        // Search from bottom row (highest index) upward to find the first empty spot
        for row in (0..<gameGrid.rows).reversed() {
            if gameGrid.grid[row][safeColumn] == nil {
                targetRow = row  // This is the first empty row from bottom - use it!
                break  // Found the landing spot, stop searching
            }
            // If this row is occupied, continue to next row up
        }
        
        print("🧩 DEBUG: Dropping to column \(safeColumn), row \(targetRow)")
        
        // Move piece directly to landing position using enhanced animation
        let landingPosition = gameGrid.getWorldPosition(row: targetRow, column: safeColumn)
        print("🧩 Moving piece to world position: \(landingPosition)")
        
        // Use simple drop animation without spinning
        let dropAction = SKAction.move(to: landingPosition, duration: 0.4)
        dropAction.timingMode = .easeIn
        
        piece.run(dropAction) {
            // After animation completes, try to place the piece
            self.attemptPiecePlacement(piece: piece, row: targetRow, column: safeColumn)
        }
        
        showDropFeedback("Hard drop!", color: .cyan)
    }
    
    private func attemptPiecePlacement(piece: PuzzlePiece, row: Int, column: Int) {
        // Ensure we're on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.attemptPiecePlacement(piece: piece, row: row, column: column)
            }
            return
        }
        
        // Safety check for valid game state
        guard !isGameOver, let gameGrid = gameGrid, let gameManager = gameManager else { 
            print("🧩 ERROR: Cannot place piece - invalid game state")
            return 
        }
        
        // Verify row and column are within bounds
        guard row >= 0 && row < gameGrid.rows && column >= 0 && column < gameGrid.columns else {
            print("🧩 ERROR: Cannot place piece - invalid position: row \(row), column \(column)")
            return
        }
        
        // Remove piece from previous position if it exists
        gameGrid.removePieceFromGrid(piece)
        
        // Remove from parent and add to grid
        piece.removeFromParent()
        piece.removeAllActions()
        
        // Place the piece in the grid
        gameGrid.grid[row][column] = piece
        let worldPos = gameGrid.getWorldPosition(row: row, column: column)
        piece.position = worldPos
        gameGrid.addChild(piece)
        
        // Check if piece is correctly placed and oriented (for scoring)
        let isCorrect = piece.checkCorrectPlacement(gridRow: row, gridColumn: column)
        
        // Calculate score with new combo system
        let score = calculateScore(for: isCorrect ? .perfect : .incorrect)
        
        if isCorrect {
            // Perfect placement - lock the piece and award points
            piece.lockPiece()
            gameGrid.placedPieces += 1
            consecutiveCorrect += 1
            gameManager.pieceCorrectlyPlaced(piece: piece)
            
            // Show combo feedback
            showComboFeedback(score: score)
            
            // Enhanced visual effects
            VisualManager.shared.createSparkleEffect(at: worldPos, in: self)
            VisualManager.shared.createFloatingScoreLabel(score: score, at: worldPos, in: self)
            VisualManager.shared.createPieceGlowEffect(piece: piece, color: VisualManager.shared.getCurrentTheme().primaryColor)
            
            // Enhanced audio feedback
            SoundManager.shared.playSound(.perfectPlacement)
            SoundManager.shared.createHapticMelody(notes: [523.25, 659.25, 783.99])
            
            // Check for level progression
            checkLevelProgression()
            
            // Check if puzzle is complete
            if gameGrid.isPuzzleComplete() {
                showPuzzleComplete()
                return
            }
        } else {
            consecutiveCorrect = 0  // Reset combo
            gameManager.pieceIncorrectlyPlaced()
            showDropFeedback("Try again!", color: .orange)
            VisualManager.shared.shakeNode(piece, intensity: 2.0, duration: 0.2)
        }
        
        // Play placement sound
        SoundManager.shared.playSound(.piecePlacement)
        SoundManager.shared.playHaptic(isCorrect ? .success : .light)
        
        // Update piece counter
        piecesPlaced += 1
        
        // Clear current piece
        currentPiece = nil
        
        // PERFORMANCE FIX: Clean up visual effects and orphaned pieces periodically
        if piecesPlaced % 5 == 0 { // Clean up every 5 pieces
            cleanupOldVisualEffects()
            ensureProperPieceCleanup()
        }
        
        // Generate next piece with reduced delay for faster gameplay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            self.gameManager.generateNextPiece()
        }
    }
    
    private func shouldCheckForRowCompletion(row: Int) -> Bool {
        // Check if the entire row is filled with correctly placed pieces
        for col in 0..<gameGrid.columns {
            guard let piece = gameGrid.grid[row][col],
                  piece.isCorrectlyPlaced && piece.isLocked else {
                return false
            }
        }
        return true
    }
    
    private func showDropFeedback(_ message: String, color: UIColor) {
        // Remove any existing feedback
        childNode(withName: "dropFeedback")?.removeFromParent()
        
        let feedbackLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if feedbackLabel.fontName == nil {
            feedbackLabel.fontName = "Helvetica-Bold"
        }
        feedbackLabel.text = message
        feedbackLabel.fontSize = 16
        feedbackLabel.fontColor = color
        feedbackLabel.position = CGPoint(x: 0, y: size.height * 0.15)
        feedbackLabel.horizontalAlignmentMode = .center
        feedbackLabel.name = "dropFeedback"
        feedbackLabel.zPosition = 100
        addChild(feedbackLabel)
        
        // Animate and remove
        feedbackLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    private func returnPieceToSpawnArea(_ piece: PuzzlePiece) {
        // Calculate spawn position using same logic as piece generation
        // This function is for returning a piece, so its spawn needs to be above the grid.
        // The gameGrid's origin (0,0) is its center.
        // Top of the grid in gameGrid's coordinates is gameGrid.cellSize * CGFloat(gameGrid.rows) / 2.0
        // Convert this to scene coordinates.
        let gridTopInScene = gameGrid.convert(CGPoint(x: 0, y: gameGrid.cellSize * CGFloat(gameGrid.rows) / 2.0), to: self).y
        let spawnY = gridTopInScene + gameGrid.cellSize // Spawn one cell size above the grid top.

        // For X, let's use the center of the grid.
        let spawnX = gameGrid.position.x 
        let spawnPosition = CGPoint(x: spawnX, y: spawnY)
        
        // Animate piece back to spawn area
        piece.run(SKAction.move(to: spawnPosition, duration: 0.5))
    }
    
    private func showPuzzleComplete() {
        print("🧩 🎉 PUZZLE COMPLETED!")
        
        // Stop any timers
        stopAutoFall()
        
        // Show completion message
        let completionLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if completionLabel.fontName == nil {
            completionLabel.fontName = "Helvetica-Bold"
        }
        completionLabel.text = "PUZZLE COMPLETE!"
        completionLabel.fontSize = 32
        completionLabel.fontColor = .green
        completionLabel.position = CGPoint.zero
        completionLabel.horizontalAlignmentMode = .center
        completionLabel.zPosition = 100
        addChild(completionLabel)
        
        // Animate completion
        completionLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.5),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 1.0)
        ]))
        
        // Show final score
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Final Score: \(gameManager.score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: -50)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        scoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }
    
    private func updateCompletionLabel() {
        if gameGrid == nil || gameGrid.rows == 0 || gameGrid.columns == 0 { // Ensure gameGrid is initialized
            levelLabel.text = "Complete: 0%"
            progressPercentLabel.text = "0%"
            progressFill.size.width = 0
            return
        }
        let completionPercentage = gameGrid.getCompletionPercentage()
        let completionInt = Int(completionPercentage * 100)
        levelLabel.text = "Complete: \(completionInt)%"
        
        // Update adaptive music intensity based on completion
        SoundManager.shared.setAdaptiveMusicIntensity(completionPercentage: Float(completionPercentage))
        
        // Update progress bar fill with smooth animation
        let progressBarWidth = progressBar.frame.size.width 
        let targetWidth = CGFloat(progressBarWidth * CGFloat(completionPercentage))
        let fillAction = SKAction.resize(toWidth: targetWidth, duration: 0.5)
        progressFill.run(fillAction)
        
        // Update progress percentage label
        progressPercentLabel.text = "\(completionInt)%"
        
        // Add visual feedback for milestones
        if completionInt % 25 == 0 && completionInt > 0 {
            VisualManager.shared.createSparkleEffect(at: progressBar.position, in: self)
            SoundManager.shared.playSound(.levelUp)
        }
    }
    
    // MARK: - Touch Handling (CLEANED UP)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        // Store touch timing and position
        let currentTime = event?.timestamp ?? CACurrentMediaTime()
        touchStartTime = currentTime
        touchStartPosition = touchLocation
        isDragging = false
        hasMovedSignificantly = false
        timeSinceSpawn = touchStartTime - (currentPiece?.spawnTime ?? touchStartTime)
        
        print("🎯 Touch began at: \(touchLocation)")
        
        // Handle UI button touches first - these should be immediate and responsive
        if handleUITouch(touchedNode) { 
            return 
        }
        
        // Check for current piece interaction - MUCH more forgiving detection
        if let piece = currentPiece {
            let directTouch = (touchedNode as? PuzzlePiece) === piece
            let nearbyTouch = isPointNearPiece(touchLocation, piece: piece)
            
            // Very generous game area detection - essentially any touch in the main game area
            let inMainArea = abs(touchLocation.x) < size.width/2 && 
                           touchLocation.y > -size.height/2 && 
                           touchLocation.y < size.height/2
            
            // Also check if touch is in the lower playing field where users naturally touch
            let inPlayingField = abs(touchLocation.x) < 200 && touchLocation.y > -400 && touchLocation.y < 400
            
            if directTouch || nearbyTouch || inMainArea || inPlayingField {
                print("🎯 Touch on current piece - Direct: \(directTouch), Nearby: \(nearbyTouch), InMainArea: \(inMainArea), InPlayingField: \(inPlayingField)")
                handleCurrentPieceTouch(piece: piece, currentTime: currentTime)
                return
            }
        }
        
        // Priority 3: Touch on placed pieces in the grid
        if let touchedPiece = touchedNode as? PuzzlePiece, touchedPiece != currentPiece {
            handlePlacedPieceTouch(piece: touchedPiece)
            return
        }
        
        print("🎯 Touch not on any piece")
    }
    
    private func handleCurrentPieceTouch(piece: PuzzlePiece, currentTime: TimeInterval) {
        // Immediate feedback for responsiveness
        SoundManager.shared.playHaptic(.medium)  // Stronger feedback for piece interaction
        VisualManager.shared.createPieceGlowEffect(piece: piece, color: .cyan)
        
        // Show visual connection between touch and piece
        showTouchToPieceConnection(from: touchStartPosition, to: piece)
        
        // Check for double tap
        if currentTime - lastTouchTime < doubleTapThreshold {
            print("🎯 Double tap detected - rotating")
            rotatePieceWithFeedback(piece)
            lastTouchTime = 0  // Reset to prevent triple tap
            return
        }
        
        // Single touch on piece - prepare for potential drag or tap
        showDropZoneIndicator(for: piece)
        lastTouchTime = currentTime
        print("🎯 Single touch on current piece - ready for drag/tap")
    }
    
    private func handlePlacedPieceTouch(piece: PuzzlePiece) {
        // Only allow rotation of placed pieces that aren't locked
        if !piece.isLocked && piece.isDragEnabled {
            print("🎯 Rotating placed piece: \(piece.pieceID)")
                
            // Immediate rotation for placed pieces
            VisualManager.shared.animatePieceRotation(piece: piece) {
                    // Rotation animation completed
                }
            VisualManager.shared.createPieceGlowEffect(piece: piece, color: VisualManager.shared.getCurrentTheme().secondaryColor)
            piece.rotatePiece()
                SoundManager.shared.playSound(.pieceRotation)
                SoundManager.shared.playHaptic(.light)
                
                // Check if the piece is now correctly placed after rotation
            if let gridPos = gameGrid.getGridPositionForPiece(piece) {
                let isCorrect = piece.checkCorrectPlacement(gridRow: gridPos.row, gridColumn: gridPos.column)
                    if isCorrect {
                    piece.lockPiece()
                        gameGrid.placedPieces += 1
                    gameManager.pieceCorrectlyPlaced(piece: piece)
                        showDropFeedback("Perfect placement!", color: .green)
                        
                        // Add enhanced success effects
                    VisualManager.shared.createSparkleEffect(at: piece.position, in: self)
                    VisualManager.shared.createFloatingScoreLabel(score: 100, at: piece.position, in: self)
                    } else {
                        showDropFeedback("Keep trying!", color: .orange)
                    }
                }
                
                showDropFeedback("Piece rotated!", color: .cyan)
        } else if piece.isLocked {
                showDropFeedback("Piece is locked!", color: .gray)
            }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let piece = currentPiece else { return }
        
        let location = touch.location(in: self)
        let deltaX = location.x - touchStartPosition.x
        let deltaY = touchStartPosition.y - location.y
        let totalMovement = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        // Track if user has moved significantly (affects gesture detection)
        if !hasMovedSignificantly && totalMovement > dragThreshold {
            hasMovedSignificantly = true
            print("🎯 Significant movement detected: \(totalMovement)")
        }
        
        // More responsive drag detection - start dragging with any horizontal movement above threshold
        // BUT only if it's primarily horizontal movement (not vertical swipe)
        if !isDragging && abs(deltaX) > dragThreshold && abs(deltaX) > abs(deltaY) {
            print("👆 Starting drag - deltaX: \(deltaX), deltaY: \(deltaY), total: \(totalMovement)")
            isDragging = true
            piece.isBeingDragged = true
            SoundManager.shared.playHaptic(.light)
            
            // DON'T pause falling - let piece continue to fall while being dragged horizontally
            // This creates a more natural Tetris-like feel
        }
        
        // Process movement during dragging
        if isDragging {
            // Convert touch location to grid coordinates
            let gridLocation = convert(location, to: gameGrid)
            
            // Calculate grid bounds with better precision
            let gridWidth = CGFloat(gameGrid.columns) * gameGrid.cellSize
            let minX = -gridWidth / 2 + gameGrid.cellSize / 2
            let maxX = gridWidth / 2 - gameGrid.cellSize / 2
            
            // Clamp to grid bounds
            let targetX = max(minX, min(maxX, gridLocation.x))
            
            // Direct movement for more responsive feel
            piece.position.x = targetX
            
            // Update drop zone indicator
            updateDropZoneIndicator(for: piece)
            
            print("🎯 Dragging - gridX: \(gridLocation.x), targetX: \(targetX), pieceX: \(piece.position.x)")
        }
    }
    

    
    // MARK: - Helper Functions for Cleaned Up Gameplay
    
    private func handleUITouch(_ touchedNode: SKNode) -> Bool {
        if touchedNode.name == "pauseButton" || touchedNode.parent?.name == "pauseButton" {
            handlePauseButton()
            return true
        }
        
        if touchedNode.name == "resumeButton" || touchedNode.parent?.name == "resumeButton" {
            togglePause()
            return true
        }
        
        if touchedNode.name == "homeTab" || touchedNode.parent?.name == "homeTab" {
            switchToTab(.home)
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHaptic(.light)
            return true
        }
        
        if touchedNode.name == "settingsTab" || touchedNode.parent?.name == "settingsTab" {
            switchToTab(.settings)
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHaptic(.light)
            return true
        }
        
        if touchedNode.name?.hasPrefix("themeButton_") == true {
            if let themeName = touchedNode.name?.replacingOccurrences(of: "themeButton_", with: ""),
               let theme = GameTheme(rawValue: themeName) {
                selectTheme(theme)
            }
            return true
        }
        
        if touchedNode.name == "closeSettings" || touchedNode.parent?.name == "closeSettings" {
            hideSettingsOverlay()
            return true
        }
        
        if touchedNode.name == "soundToggle" || touchedNode.parent?.name == "soundToggle" {
            SoundManager.shared.toggleSound()
            createEnhancedSettingsOverlay()
            return true
        }
        
        if touchedNode.name == "musicToggle" || touchedNode.parent?.name == "musicToggle" {
            SoundManager.shared.toggleMusic()
            createEnhancedSettingsOverlay()
            return true
        }
        
        if touchedNode.name == "hapticToggle" || touchedNode.parent?.name == "hapticToggle" {
            SoundManager.shared.toggleHaptic()
            createEnhancedSettingsOverlay()
            return true
        }
        
        if touchedNode.name == "resetHighScore" || touchedNode.parent?.name == "resetHighScore" {
            resetHighScore()
            return true
        }
        
        return false
    }
    
    private func showDropZoneIndicator(for piece: PuzzlePiece) {
        hideDropZoneIndicator()
        
        let gridLocation = convert(piece.position, to: gameGrid)
        guard let gridPos = gameGrid.getGridPosition(for: gridLocation) else { return }
        
        let indicatorSize = CGSize(width: gameGrid.cellSize - 4, height: gameGrid.cellSize - 4)
        dropZoneIndicator = SKShapeNode(rectOf: indicatorSize, cornerRadius: 8)
        dropZoneIndicator?.fillColor = VisualManager.shared.getCurrentTheme().primaryColor.withAlphaComponent(0.3)
        dropZoneIndicator?.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor
        dropZoneIndicator?.lineWidth = 2
        dropZoneIndicator?.position = gameGrid.getWorldPosition(row: gridPos.row, column: gridPos.column)
        dropZoneIndicator?.zPosition = 0.5
        gameGrid.addChild(dropZoneIndicator!)
        
        // Add visual feedback to show touch was detected
        showTouchFeedback(at: piece.position)
    }
    
    private func showTouchFeedback(at position: CGPoint) {
        // Create a more prominent visual indicator that touch was detected
        let touchIndicator = SKShapeNode(circleOfRadius: 30)
        touchIndicator.fillColor = VisualManager.shared.getCurrentTheme().primaryColor.withAlphaComponent(0.3)
        touchIndicator.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor
        touchIndicator.lineWidth = 4
        touchIndicator.alpha = 1.0
        touchIndicator.position = position
        touchIndicator.zPosition = 100
        
        // Add to the scene for maximum visibility
        addChild(touchIndicator)
        
        // More prominent animation
        let scaleUp1 = SKAction.scale(to: 2.0, duration: 0.1)
        let scaleUp2 = SKAction.scale(to: 2.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        touchIndicator.run(SKAction.sequence([
            scaleUp1,
            scaleUp2,
            SKAction.group([fadeOut]),
            remove
        ]))
        
        // Add text indicator for immediate feedback
        let touchText = SKLabelNode(fontNamed: "SF Pro Display")
        if touchText.fontName == nil {
            touchText.fontName = "Helvetica-Bold"
        }
        touchText.text = "TOUCH!"
        touchText.fontSize = 16
        touchText.fontColor = VisualManager.shared.getCurrentTheme().primaryColor
        touchText.position = CGPoint(x: position.x, y: position.y + 40)
        touchText.zPosition = 101
        addChild(touchText)
        
        touchText.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.wait(forDuration: 0.3),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.moveBy(x: 0, y: 20, duration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showTouchToPieceConnection(from touchPoint: CGPoint, to piece: PuzzlePiece) {
        // Get piece position in scene coordinates
        let piecePosition: CGPoint
        if piece.parent == gameGrid {
            piecePosition = convert(piece.position, from: gameGrid)
        } else {
            piecePosition = piece.position
        }
        
        // Create a line connecting touch to piece
        let connectionLine = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: touchPoint)
        path.addLine(to: piecePosition)
        connectionLine.path = path.cgPath
        connectionLine.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor
        connectionLine.lineWidth = 3
        connectionLine.alpha = 0.7
        connectionLine.zPosition = 99
        addChild(connectionLine)
        
        // Animate the line
        connectionLine.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Add a pulse at the piece position
        let pieceIndicator = SKShapeNode(circleOfRadius: 25)
        pieceIndicator.fillColor = .clear
        pieceIndicator.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor
        pieceIndicator.lineWidth = 3
        pieceIndicator.position = piecePosition
        pieceIndicator.zPosition = 100
        addChild(pieceIndicator)
        
        pieceIndicator.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }
    
    private func updateDropZoneIndicator(for piece: PuzzlePiece) {
        guard let indicator = dropZoneIndicator else { return }
        
        let gridLocation = convert(piece.position, to: gameGrid)
        guard let gridPos = gameGrid.getGridPosition(for: gridLocation) else { return }
        
        indicator.position = gameGrid.getWorldPosition(row: gridPos.row, column: gridPos.column)
    }
    
    private func hideDropZoneIndicator() {
        dropZoneIndicator?.removeFromParent()
        dropZoneIndicator = nil
    }
    
    private func isPointNearPiece(_ point: CGPoint, piece: PuzzlePiece, radius: CGFloat? = nil) -> Bool {
        let effectiveRadius = radius ?? touchRadius
        
        // Get piece position in scene coordinates
        let pieceScenePosition: CGPoint
        if piece.parent == gameGrid {
            // Piece is in the grid - convert from grid to scene coordinates
            pieceScenePosition = convert(piece.position, from: gameGrid)
        } else {
            // Piece is directly in scene
            pieceScenePosition = piece.position
        }
        
        let distance = sqrt(pow(point.x - pieceScenePosition.x, 2) + pow(point.y - pieceScenePosition.y, 2))
        let isNear = distance <= effectiveRadius
        
        // Debug output for troubleshooting
        if piece == currentPiece {
            print("🎯 Touch detection - Point: \(point), Piece: \(pieceScenePosition), Distance: \(distance), Radius: \(effectiveRadius), Near: \(isNear)")
        }
        
        return isNear
    }
    
    private func resetTouchState() {
        isDragging = false
        hasMovedSignificantly = false
        currentPiece?.isBeingDragged = false
        hideDropZoneIndicator()
        lastTouchTime = 0
    }
    
    private func ensurePieceResponsiveness() {
        // Ensure current piece is always responsive
        guard let piece = currentPiece else { return }
        
        // Reset any stuck states
        piece.isBeingDragged = false
        piece.isUserInteractionEnabled = true
        piece.alpha = 1.0
        
        // Ensure piece is in the correct parent
        if piece.parent != gameGrid {
            piece.removeFromParent()
            gameGrid.addChild(piece)
        }
        
        print("🎯 Ensured piece \(piece.pieceID) responsiveness")
    }
    
    private func rotatePieceWithFeedback(_ piece: PuzzlePiece) {
        print("🔄 DEBUG: Rotating piece \(piece.pieceID)")
        VisualManager.shared.animatePieceRotation(piece: piece) {}
        VisualManager.shared.createPieceGlowEffect(piece: piece, color: VisualManager.shared.getCurrentTheme().secondaryColor)
        piece.rotatePiece()
        SoundManager.shared.playSound(.pieceRotation)
        SoundManager.shared.playHaptic(.light)
        showDropFeedback("Rotated!", color: .cyan)
    }
    
    private func hardDropPiece() {
        print("⬇️ DEBUG: Hard drop triggered")
        guard let piece = currentPiece else {
            print("⬇️ ERROR: No current piece for hard drop")
            return
        }
        print("⬇️ Hard dropping piece: \(piece.pieceID)")
        dropCurrentPiece()
        SoundManager.shared.playHaptic(.medium)
        showDropFeedback("Hard Drop!", color: .orange)
    }
    
    // MARK: - Enhanced Scoring System
    
    private enum PlacementType {
        case perfect
        case correct
        case incorrect
    }
    
    private func calculateScore(for placement: PlacementType) -> Int {
        let baseScore: Int
        switch placement {
        case .perfect: baseScore = 100
        case .correct: baseScore = 50
        case .incorrect: baseScore = -10
        }
        
        // Apply combo multiplier (max 5x)
        let comboMultiplier = min(consecutiveCorrect / 3 + 1, 5)
        
        // Apply time bonus (faster placement = more points)
        let timeBonus = max(0, Int((3.0 - timeSinceSpawn) * 10))
        
        // Apply level multiplier
        let levelMultiplier = currentLevel
        
        return max(0, (baseScore + timeBonus) * comboMultiplier * levelMultiplier)
    }
    
    private func showComboFeedback(score: Int) {
        let comboMultiplier = min(consecutiveCorrect / 3 + 1, 5)
        
        if comboMultiplier > 1 {
            let comboText = "COMBO x\(comboMultiplier)!"
            showDropFeedback(comboText, color: .systemYellow)
            
            // Show combo label
            updateComboLabel(multiplier: comboMultiplier)
            
            // Enhanced effects for higher combos
            if comboMultiplier >= 3 {
                VisualManager.shared.shakeScreen(self, intensity: 5.0, duration: 0.3)
                SoundManager.shared.playSound(.comboMultiplier)
            }
        } else {
            showDropFeedback("Perfect! +\(score)", color: .green)
        }
    }
    
    private func updateComboLabel(multiplier: Int) {
        comboLabel?.removeFromParent()
        
        if multiplier > 1 {
            comboLabel = SKLabelNode(fontNamed: "SF Pro Display")
            if comboLabel?.fontName == nil {
                comboLabel?.fontName = "Helvetica-Bold"
            }
            comboLabel?.text = "COMBO x\(multiplier)"
            comboLabel?.fontSize = 20
            comboLabel?.fontColor = .systemYellow
            comboLabel?.position = CGPoint(x: size.width * 0.35, y: size.height * 0.25)
            comboLabel?.zPosition = 10
            addChild(comboLabel!)
            
            // Pulse animation
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            comboLabel?.run(pulseAction)
        }
    }
    
    private func checkLevelProgression() {
        let piecesForNextLevel = currentLevel * 10  // 10, 20, 30 pieces per level
        
        if piecesPlaced >= piecesForNextLevel {
            currentLevel += 1
            showDropFeedback("LEVEL \(currentLevel)!", color: .systemPurple)
            
            // Level up effects
            VisualManager.shared.shakeScreen(self, intensity: 10.0, duration: 0.5)
            SoundManager.shared.playSound(.levelUp)
            SoundManager.shared.playHaptic(.success)
            
            // Unlock new themes based on level
            unlockThemeForLevel(currentLevel)
        }
    }
    
    private func unlockThemeForLevel(_ level: Int) {
        let themeToUnlock: GameTheme?
        
        switch level {
        case 2: themeToUnlock = .sunset
        case 3: themeToUnlock = .ocean
        case 4: themeToUnlock = .forest
        case 5: themeToUnlock = .neon
        case 6: themeToUnlock = .cyberpunk
        case 7: themeToUnlock = .retro
        case 8: themeToUnlock = .nature
        case 9: themeToUnlock = .galaxy
        case 10: themeToUnlock = .aurora
        default: themeToUnlock = nil
        }
        
        if let theme = themeToUnlock {
            theme.unlock()
            showDropFeedback("New theme unlocked: \(theme.displayName)!", color: theme.primaryColor)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        let touchDuration = (event?.timestamp ?? CACurrentMediaTime()) - touchStartTime
        
        // Hide drop zone indicator
        hideDropZoneIndicator()
        
        // Handle piece interactions
        if let piece = currentPiece {
            let deltaX = location.x - touchStartPosition.x
            let deltaY = touchStartPosition.y - location.y
            let totalMovement = sqrt(deltaX * deltaX + deltaY * deltaY)
            
            print("🎯 Touch ended - Duration: \(touchDuration), Movement: \(totalMovement), Dragging: \(isDragging)")
            print("🎯 Delta - X: \(deltaX), Y: \(deltaY)")
            print("🎯 Swipe check - deltaY: \(deltaY), threshold: \(swipeThreshold), abs(deltaY): \(abs(deltaY)), abs(deltaX): \(abs(deltaX))")
            print("🎯 Swipe condition: deltaY > threshold: \(deltaY > swipeThreshold), abs(deltaY) > abs(deltaX): \(abs(deltaY) > abs(deltaX))")
            print("🎯 Touch distance from piece: \(currentPiece != nil ? sqrt(pow(touchStartPosition.x - convert(currentPiece!.position, from: gameGrid).x, 2) + pow(touchStartPosition.y - convert(currentPiece!.position, from: gameGrid).y, 2)) : 0)")
            
            // Determine gesture type based on movement and timing
            if deltaY > swipeThreshold && abs(deltaY) > abs(deltaX) {
                // Clear downward swipe = hard drop (check this FIRST, before other conditions)
                print("🎯 Downward swipe detected - hard drop (deltaY: \(deltaY), threshold: \(swipeThreshold))")
                hardDropPiece()
            } else if isDragging {
                // Was dragging - just end the drag (falling continues automatically)
                print("🎯 Ending drag")
                piece.isBeingDragged = false
                isDragging = false
                // No need to restart falling since we never stopped it
            } else if !hasMovedSignificantly && touchDuration < tapThreshold {
                // Quick tap with minimal movement = rotate
                print("🎯 Quick tap detected - rotate")
                rotatePieceWithFeedback(piece)
            } else if totalMovement < dragThreshold {
                // Stationary touch (regardless of duration) = rotate
                print("🎯 Stationary touch - rotate")
                rotatePieceWithFeedback(piece)
            }
            
            // Reset touch state
            piece.isBeingDragged = false
            isDragging = false
            hasMovedSignificantly = false
        }
        
        if touchedNode.name == "restartButton" || touchedNode.parent?.name == "restartButton" {
            restartGame()
        }
        
        if touchedNode.name == "resumeButton" || touchedNode.parent?.name == "resumeButton" {
            togglePause()
        }
        
        if touchedNode.name == "closeSettings" || touchedNode.parent?.name == "closeSettings" {
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHaptic(.light)
            hideSettings()
        }
        
        if touchedNode.name == "soundToggle" || touchedNode.parent?.name == "soundToggle" {
            // Toggle sound setting
            SoundManager.shared.setSoundEnabled(!SoundManager.shared.soundEnabled)
            
            // Update the button by recreating it
            updateSettingsButton(name: "soundToggle", 
                               text: "SOUND: \(SoundManager.shared.soundEnabled ? "ON" : "OFF")",
                               color: SoundManager.shared.soundEnabled ? .systemGreen : .systemRed,
                               position: CGPoint(x: 0, y: size.height * 0.08))
            
            // Play feedback only if sound is now enabled
            if SoundManager.shared.soundEnabled {
                SoundManager.shared.playSound(.buttonTap)
            }
            SoundManager.shared.playHaptic(.medium)
        }
        
        if touchedNode.name == "musicToggle" || touchedNode.parent?.name == "musicToggle" {
            // Toggle music setting
            SoundManager.shared.setMusicEnabled(!SoundManager.shared.musicEnabled)
            
            // Update the button by recreating it
            updateSettingsButton(name: "musicToggle", 
                               text: "MUSIC: \(SoundManager.shared.musicEnabled ? "ON" : "OFF")",
                               color: SoundManager.shared.musicEnabled ? .systemGreen : .systemRed,
                               position: CGPoint(x: 0, y: size.height * 0.01))
            
            // Play feedback
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHaptic(.medium)
        }
        
        if touchedNode.name == "hapticToggle" || touchedNode.parent?.name == "hapticToggle" {
            // Toggle haptic setting
            SoundManager.shared.setHapticEnabled(!SoundManager.shared.hapticEnabled)
            
            // Update the button by recreating it
            updateSettingsButton(name: "hapticToggle", 
                               text: "HAPTIC: \(SoundManager.shared.hapticEnabled ? "ON" : "OFF")",
                               color: SoundManager.shared.hapticEnabled ? .systemGreen : .systemRed,
                               position: CGPoint(x: 0, y: -size.height * 0.06))
            
            SoundManager.shared.playSound(.buttonTap)
            // Play haptic feedback only if haptic is now enabled
            if SoundManager.shared.hapticEnabled {
                SoundManager.shared.playHaptic(.medium)
            }
        }
        
        if touchedNode.name == "closeDebug" || touchedNode.parent?.name == "closeDebug" {
            hideDebugOverlay()
        }
        
        if touchedNode.name == "manualGenerate" || touchedNode.parent?.name == "manualGenerate" {
            print("🎯 DEBUG: Manual generate button pressed")
            hideDebugOverlay()
            gameManager.forceGenerateNextPiece()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle interrupted touches (e.g., phone call, notification)
        isDragging = false
        hasMovedSignificantly = false
        
        if let piece = currentPiece {
            piece.isBeingDragged = false
            // No need to restart falling since we never stopped it
        }
        
        hideDropZoneIndicator()
        
        // Reset touch timing
        lastTouchTime = 0
    }
    
    private func restartGame() {
        // COMPREHENSIVE CLEANUP: Stop all actions first
        removeAllActions()
        
        // Stop all timers and falling
        stopAutoFall()
        
        // Clean up current piece if it exists
        if let piece = currentPiece {
            piece.removeAllActions()
            piece.removeFromParent()
        }
        
        // Reset game state
        currentPiece = nil
        gameIsPaused = false
        isGameOver = false
        isFalling = false
        piecesPlaced = 0
        consecutiveCorrect = 0
        currentLevel = 1
        
        // Clean up visual effects
        cleanupOldVisualEffects()
        
        // Remove all game elements
        removeAllChildren()
        
        // Clear any cached textures to free memory
        VisualManager.shared.clearCache()
        
        // Recreate the game
        setupScene()
        setupGameComponents()
        setupUI()
        startGame()
        
        print("🧩 RESTART: Game restarted with full cleanup")
    }

    
    private func selectTheme(_ theme: GameTheme) {
        SoundManager.shared.playSound(.buttonTap)
        SoundManager.shared.playHaptic(.medium)
        
        // Set the new theme
        VisualManager.shared.setTheme(theme)
        
        // Visual feedback for theme change
        VisualManager.shared.shakeScreen(self, intensity: 5.0, duration: 0.3)
        
        // Update the background immediately
        if let backgroundSprite = children.first(where: { $0.zPosition == -10 }) as? SKSpriteNode {
            let newBackgroundTexture = VisualManager.shared.generateThemeBackground(size: size)
            backgroundSprite.texture = newBackgroundTexture
        }
        
        // Refresh the settings overlay with new theme
        createEnhancedSettingsOverlay()
        
        // Show theme change feedback
        let feedbackLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        feedbackLabel.text = "Theme changed to \(theme.displayName)!"
        feedbackLabel.fontSize = 20
        feedbackLabel.fontColor = theme.primaryColor
        feedbackLabel.position = CGPoint(x: 0, y: size.height * 0.3)
        feedbackLabel.zPosition = 200
        addChild(feedbackLabel)
        
        feedbackLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func resetHighScore() {
        SoundManager.shared.playSound(.buttonTap)
        SoundManager.shared.playHaptic(.warning)
        
        // Reset the high score
        gameManager.resetHighScore()
        
        // Update the high score display
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = "Best: 0"
        }
        
        // Refresh the settings overlay to show updated stats
        createEnhancedSettingsOverlay()
        
        // Show confirmation feedback
        let feedbackLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        feedbackLabel.text = "High Score Reset!"
        feedbackLabel.fontSize = 18
        feedbackLabel.fontColor = .systemOrange
        feedbackLabel.position = CGPoint(x: 0, y: size.height * 0.3)
        feedbackLabel.zPosition = 200
        addChild(feedbackLabel)
        
        feedbackLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func addSuccessEffect(at position: CGPoint) {
        // Use the enhanced particle system
        VisualManager.shared.createSparkleEffect(at: position, in: self)
    }
    
    func puzzleCompleted() {
        print("🧩 puzzleCompleted() called")
        updateCompletionLabel()
        addPuzzleCompletionEffect()
    }
    
    private func addPuzzleCompletionEffect() {
        // Create spectacular completion effect
        VisualManager.shared.createRowCompletionEffect(at: CGPoint.zero, in: self)
        VisualManager.shared.shakeScreen(self, intensity: 15.0, duration: 1.0)
        VisualManager.shared.createFloatingScoreLabel(score: 1000, at: CGPoint(x: 0, y: 100), in: self)
        
        // Screen flash effect for puzzle completion
        let flash = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        flash.fillColor = .white
        flash.alpha = 0
        flash.zPosition = 20
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1),
            SKAction.fadeAlpha(to: 0, duration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showSettings() {
        gameIsPaused = true
        
        // Create settings overlay
        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.name = "settingsOverlay"
        overlay.zPosition = 100
        addChild(overlay)
        
        // Settings title
        let settingsTitle = SKLabelNode(fontNamed: "Arial-Bold")
        settingsTitle.text = "SETTINGS"
        settingsTitle.fontSize = 32
        settingsTitle.fontColor = .white
        settingsTitle.position = CGPoint(x: 0, y: size.height * 0.2)  // CENTER-BASED
        settingsTitle.horizontalAlignmentMode = .center
        settingsTitle.zPosition = 101
        addChild(settingsTitle)
        
        // Sound toggle button
        createBeautifulOverlayButton(
            text: "SOUND: \(SoundManager.shared.soundEnabled ? "ON" : "OFF")",
            size: CGSize(width: 200, height: 50),
            position: CGPoint(x: 0, y: size.height * 0.08),
            color: SoundManager.shared.soundEnabled ? .systemGreen : .systemRed,
            name: "soundToggle",
            fontSize: 18,
            zPosition: 101
        )
        
        // Music toggle button
        createBeautifulOverlayButton(
            text: "MUSIC: \(SoundManager.shared.musicEnabled ? "ON" : "OFF")",
            size: CGSize(width: 200, height: 50),
            position: CGPoint(x: 0, y: size.height * 0.01),
            color: SoundManager.shared.musicEnabled ? .systemGreen : .systemRed,
            name: "musicToggle",
            fontSize: 18,
            zPosition: 101
        )
        
        // Haptic toggle button
        createBeautifulOverlayButton(
            text: "HAPTIC: \(SoundManager.shared.hapticEnabled ? "ON" : "OFF")",
            size: CGSize(width: 200, height: 50),
            position: CGPoint(x: 0, y: -size.height * 0.06),
            color: SoundManager.shared.hapticEnabled ? .systemGreen : .systemRed,
            name: "hapticToggle",
            fontSize: 18,
            zPosition: 101
        )
        
        // Close button
        createBeautifulOverlayButton(
            text: "CLOSE",
            size: CGSize(width: 100, height: 50),
            position: CGPoint(x: 0, y: -size.height * 0.2),
            color: .systemGreen,
            name: "closeSettings",
            fontSize: 18,
            zPosition: 101
        )
    }
    
    private func hideSettings() {
        hideSettingsOverlay()
        
        gameIsPaused = false
        if let piece = currentPiece {
            startAutoFall(for: piece)
        }
    }
    
    private func showDebugInfo() {
        print("🎯 DEBUG: showDebugInfo() called")
        
        // Get game state from GameManager
        let gameState = gameManager.getGameState()
        print("🎯 DEBUG: Current game state:\n\(gameState)")
        
        // Create debug overlay
        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.name = "debugOverlay"
        overlay.zPosition = 100
        addChild(overlay)
        
        // Debug title
        let debugTitle = SKLabelNode(fontNamed: "Arial-Bold")
        debugTitle.text = "DEBUG INFO"
        debugTitle.fontSize = 24
        debugTitle.fontColor = .orange
        debugTitle.position = CGPoint(x: 0, y: size.height * 0.35)  // CENTER-BASED
        debugTitle.horizontalAlignmentMode = .center
        debugTitle.zPosition = 101
        addChild(debugTitle)
        
        // Game state display
        let stateLines = gameState.components(separatedBy: "\n")
        for (index, line) in stateLines.enumerated() {
            let stateLabel = SKLabelNode(fontNamed: "Arial")
            stateLabel.text = line
            stateLabel.fontSize = 14
            stateLabel.fontColor = .white
            stateLabel.position = CGPoint(x: 0, y: size.height * (0.25 - Double(index) * 0.05))  // CENTER-BASED
            stateLabel.horizontalAlignmentMode = .center
            stateLabel.zPosition = 101
            addChild(stateLabel)
        }
        
        // Manual piece generation button
        let generateButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        generateButton.fillColor = .green
        generateButton.strokeColor = .white
        generateButton.position = CGPoint(x: 0, y: -size.height * 0.1)  // CENTER-BASED: negative y for below center
        generateButton.name = "manualGenerate"
        generateButton.zPosition = 101
        addChild(generateButton)
        
        let generateLabel = SKLabelNode(fontNamed: "Arial-Bold")
        generateLabel.text = "FORCE GENERATE PIECE"
        generateLabel.fontSize = 16
        generateLabel.fontColor = .white
        generateLabel.horizontalAlignmentMode = .center
        generateButton.addChild(generateLabel)
        
        // Close button
        let closeButton = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 10)
        closeButton.fillColor = .red
        closeButton.strokeColor = .white
        closeButton.position = CGPoint(x: 0, y: -size.height * 0.25)  // CENTER-BASED: negative y for below center
        closeButton.name = "closeDebug"
        closeButton.zPosition = 101
        addChild(closeButton)
        
        let closeLabel = SKLabelNode(fontNamed: "Arial-Bold")
        closeLabel.text = "CLOSE"
        closeLabel.fontSize = 18
        closeLabel.fontColor = .white
        closeLabel.horizontalAlignmentMode = .center
        closeButton.addChild(closeLabel)
    }
    
    private func hideDebugOverlay() {
        childNode(withName: "debugOverlay")?.removeFromParent()
        children.filter { $0.zPosition >= 100 }.forEach { $0.removeFromParent() }
    }
    
    // MARK: - Enhanced Falling Mechanics
    
    private func startAutoFall(for piece: PuzzlePiece) {
        guard !gameIsPaused && !isGameOver else { return }
        
        isFalling = true
        
        // Set up falling animation with more compact movement
        let fallDistance: CGFloat = 30.0  // Fall in smaller increments
        let fallSpeed: TimeInterval = 0.3 // Slightly faster falling
        
        // Create simple, responsive falling animation with safety checks
        let fallAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -fallDistance, duration: fallSpeed),
            SKAction.run { [weak self, weak piece] in
                // Ensure both self and piece are still valid before checking collision
                guard let self = self, let piece = piece else { return }
                
                // Perform collision check on main thread
                DispatchQueue.main.async {
                    self.checkFallCollision(for: piece)
                }
            }
        ])
        
        piece.run(SKAction.repeatForever(fallAction), withKey: "falling")
    }
    
    private func checkFallCollision(for piece: PuzzlePiece) {
        // Ensure we're on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.checkFallCollision(for: piece)
            }
            return
        }
        
        // Stop if game is paused, piece is no longer current, or objects are nil
        guard !gameIsPaused && !isGameOver,
              let currentPiece = currentPiece,
              currentPiece == piece,
              let gameGrid = gameGrid else {
            // CLEANUP FIX: Ensure all actions are removed when stopping collision check
            piece.removeAllActions()
            isFalling = false
            return
        }
        
        // Continue falling even while being dragged - this allows natural Tetris-like movement
        // The piece falls vertically while the user can move it horizontally
        
        // Convert piece position to grid coordinates
        let piecePositionInGrid = convert(piece.position, to: gameGrid)
        
        // Check if piece is still above the grid (spawning area)
        let gridTop = CGFloat(gameGrid.rows) * gameGrid.cellSize / 2.0
        if piecePositionInGrid.y > gridTop {
            return // Continue falling
        }
        
        // Piece is in grid area - check for collisions
        guard let targetGridPos = gameGrid.getGridPosition(for: piecePositionInGrid) else {
            // Outside grid bounds - land the piece
            piece.removeAction(forKey: "falling")
            isFalling = false
            landPiece()
            return
        }
        
        let targetRow = targetGridPos.row
        let targetColumn = targetGridPos.column
        
        // Check bounds
        guard targetRow >= 0 && targetRow < gameGrid.rows && 
              targetColumn >= 0 && targetColumn < gameGrid.columns else {
            piece.removeAction(forKey: "falling")
            isFalling = false
            landPiece()
            return
        }
        
        // Check if target cell is occupied
        if gameGrid.grid[targetRow][targetColumn] != nil {
            piece.removeAllActions()
            isFalling = false
            landPiece()
            return
        }
        
        // Enhanced collision detection for smooth stacking
        let pieceRadius = gameGrid.cellSize / 2.0
        
        // Check the cell directly below for precise stacking
        let belowRow = targetRow + 1
        if belowRow >= 0 && belowRow < gameGrid.rows {
            if gameGrid.grid[belowRow][targetColumn] != nil {
                let pieceBelowPosition = gameGrid.getWorldPosition(row: belowRow, column: targetColumn)
                let pieceBelowTop = pieceBelowPosition.y + pieceRadius
                let currentPieceBottom = piece.position.y - pieceRadius
                
                // Smooth collision detection with small buffer
                if currentPieceBottom <= pieceBelowTop + 3.0 {
                    piece.removeAllActions()
                    isFalling = false
                    landPiece()
                    return
                }
            }
        }
        
        // Check if reached bottom row
        if targetRow >= gameGrid.rows - 1 {
            piece.removeAllActions()
            isFalling = false
            landPiece()
            return
        }
        
        // Additional precision check for any pieces in the same column
        for checkRow in 0..<gameGrid.rows {
            if gameGrid.grid[checkRow][targetColumn] != nil {
                let existingPosition = gameGrid.getWorldPosition(row: checkRow, column: targetColumn)
                let distanceY = abs(piece.position.y - existingPosition.y)
                
                if distanceY < gameGrid.cellSize + 2.0 {
                    piece.removeAllActions()
                    isFalling = false
                    landPiece()
                    return
                }
            }
        }
        
        // Continue falling - no collision detected
    }
    
    private func stopAutoFall() {
        // Stop falling animation for current piece - remove ALL actions to prevent accumulation
        if let piece = currentPiece {
            piece.removeAllActions()
        }
        
        // Clean up any remaining timer
        fallingTimer?.invalidate()
        fallingTimer = nil
        isFalling = false
        
        print("🧩 DEBUG: Stopped auto-fall and cleaned up actions")
    }
    
    private func landPiece() {
        guard let piece = currentPiece else { return }
        
        print("🧩 Piece landed! Auto-placing...")
        
        // Use the corrected getGridPosition method for accurate positioning
        let piecePositionInGrid = convert(piece.position, to: gameGrid)
        
        guard let gridPos = gameGrid.getGridPosition(for: piecePositionInGrid) else {
            print("🧩 ERROR: Could not determine grid position for piece")
            return
        }
        
        let currentColumn = gridPos.column
        
        print("🧩 DEBUG: Piece grid position: \(piecePositionInGrid)")
        print("🧩 DEBUG: Calculated column using getGridPosition: \(currentColumn)")
        
        // FIXED STACKING: Find the correct landing row by checking from BOTTOM up
        // Remember: row 0 is TOP, row (rows-1) is BOTTOM in the visual grid
        var landingRow = gameGrid.rows - 1  // Start at bottom row
        
        // Check from bottom row (highest index) upward to find first empty spot
        for row in (0..<gameGrid.rows).reversed() {
            if gameGrid.grid[row][currentColumn] == nil {
                landingRow = row  // First empty row from bottom
                break  // Found landing spot
            }
        }
        
        // SAFETY CHECK: Ensure landing row is within bounds
        landingRow = max(0, min(gameGrid.rows - 1, landingRow))
        
        print("🧩 Landing piece at row \(landingRow), column \(currentColumn)")
        
        // Get the exact world position for perfect grid alignment
        let landingPosition = gameGrid.getWorldPosition(row: landingRow, column: currentColumn)
        
        // PRECISE POSITIONING: Ensure piece lands exactly at grid position
        piece.position = landingPosition
        
        print("🧩 DEBUG: Landing position: \(landingPosition)")
        
        // Place the piece immediately with proper grid registration
        attemptPiecePlacement(piece: piece, row: landingRow, column: currentColumn)
        
        showDropFeedback("Piece landed!", color: .cyan)
        
        // Update preview window with next pieces
        let nextPieces = gameManager.getNextPieces(count: 3)
        updatePreviewWindow(with: nextPieces)
        
        // Update progress indicators
        updateProgressIndicators()
    }
    
    private func triggerGameOverFromOverflow() {
        print("🧩 Game over due to overflow!")
        
        // Stop all timers and falling
        stopAutoFall()
        
        // Remove current piece
        currentPiece?.removeFromParent()
        currentPiece = nil
        
        // Show game over message
        showDropFeedback("OVERFLOW - GAME OVER!", color: .red)
        
        // Trigger game over through delegate
        gameManager.delegate?.gameDidEnd(success: false, finalScore: gameManager.score)
        
        // Play game over sound
        SoundManager.shared.playSound(.gameOver)
        SoundManager.shared.playHaptic(.error)
    }
    
    private func checkForSpawnOverflow() -> Bool {
        // Check if spawn area (80 points above grid) is actually blocked by pieces
        // The spawn area should only be blocked if pieces extend above the grid bounds
        
        print("🧩 DEBUG: checkForSpawnOverflow() called")
        
        let columnsToCheck = [gameGrid.columns / 2 - 1, gameGrid.columns / 2, gameGrid.columns / 2 + 1]
        print("🧩 DEBUG: Checking columns: \(columnsToCheck)")
        
        for column in columnsToCheck {
            // Make sure column is within bounds
            guard column >= 0 && column < gameGrid.columns else { 
                print("🧩 DEBUG: Column \(column) out of bounds, skipping")
                continue 
            }
            
            // Check if the entire column is filled (all 6 rows occupied)
            var columnIsFull = true
            var occupiedCount = 0
            for row in 0..<gameGrid.rows {
                if gameGrid.grid[row][column] == nil {
                    columnIsFull = false
                } else {
                    occupiedCount += 1
                }
            }
            
            print("🧩 DEBUG: Column \(column) - occupied: \(occupiedCount)/\(gameGrid.rows), full: \(columnIsFull)")
            
            // Only trigger overflow if the column is completely full
            // This means you can fill all 6 stacks before overflow triggers
            if columnIsFull {
                print("🧩 Overflow detected: Column \(column) is completely full (6/6 stacks)")
                return true
            }
        }
        
        print("🧩 DEBUG: No overflow detected - spawn area is clear")
        return false // No overflow - spawn area is clear
    }
    
    private func handlePauseButton() {
        print("🎯 DEBUG: Pause button touched")
        SoundManager.shared.playSound(.buttonTap)
        SoundManager.shared.playHaptic(.light)
        togglePause()
    }
    
    private func showSettingsOverlay() {
        print("🎯 DEBUG: Settings button touched")
        SoundManager.shared.playSound(.buttonTap)
        SoundManager.shared.playHaptic(.light)
        
        // Create enhanced settings overlay with theme options
        createEnhancedSettingsOverlay()
    }
    
    private func createEnhancedSettingsOverlay() {
        // Remove any existing overlay
        hideSettingsOverlay()
        
        // Create semi-transparent background
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.85), size: size)
        overlay.position = CGPoint.zero
        overlay.zPosition = 100
        overlay.name = "settingsOverlay"
        addChild(overlay)
        
        // Create larger, better proportioned settings panel
        let panelSize = CGSize(width: size.width * 0.9, height: size.height * 0.85)
        let panel = VisualManager.shared.createGlassmorphismPanel(size: panelSize)
        panel.position = CGPoint.zero
        panel.zPosition = 101
        overlay.addChild(panel)
        
        // Add elegant border to panel
        let border = SKShapeNode(rect: CGRect(origin: CGPoint(x: -panelSize.width/2, y: -panelSize.height/2), size: panelSize))
        border.strokeColor = VisualManager.shared.getCurrentTheme().primaryColor
        border.lineWidth = 2
        border.fillColor = .clear
        border.zPosition = 102
        panel.addChild(border)
        
        // Main title with better styling
        let titleLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if titleLabel.fontName == nil {
            titleLabel.fontName = "Helvetica-Bold"
        }
        titleLabel.text = "⚙️ GAME SETTINGS"
        titleLabel.fontSize = 32
        titleLabel.fontColor = VisualManager.shared.getCurrentTheme().primaryColor
        titleLabel.position = CGPoint(x: 0, y: panelSize.height/2 - 60)
        titleLabel.zPosition = 103
        panel.addChild(titleLabel)
        
        // Removed glow effect to prevent double text
        
        // Create organized sections
        createThemeSection(in: panel, panelSize: panelSize)
        createAudioSection(in: panel, panelSize: panelSize)
        createGameplaySection(in: panel, panelSize: panelSize)
        
        // Close button with better positioning
        createSettingsCloseButton(in: panel, panelSize: panelSize)
    }
    
    private func createThemeButton(theme: GameTheme, position: CGPoint, size: CGSize, in parent: SKNode) {
        let isCurrentTheme = VisualManager.shared.getCurrentTheme() == theme
        let buttonColor = isCurrentTheme ? theme.primaryColor : UIColor.darkGray.withAlphaComponent(0.8)
        
        let buttonTexture = VisualManager.shared.generateButtonTexture(size: size, baseColor: buttonColor)
        let buttonSprite = SKSpriteNode(texture: buttonTexture)
        buttonSprite.position = position
        buttonSprite.name = "themeButton_\(theme.rawValue)"
        buttonSprite.zPosition = 103
        parent.addChild(buttonSprite)
        
        // Add theme color indicator
        let colorIndicator = SKSpriteNode(color: theme.primaryColor, size: CGSize(width: 12, height: 12))
        colorIndicator.position = CGPoint(x: -size.width/2 + 15, y: 0)
        colorIndicator.zPosition = 1
        buttonSprite.addChild(colorIndicator)
        
        let label = SKLabelNode(fontNamed: "SF Pro Text")
        if label.fontName == nil {
            label.fontName = "Helvetica-Bold"
        }
        label.text = isCurrentTheme ? "\(theme.displayName) ✓" : theme.displayName
        label.fontSize = 13
        label.fontColor = isCurrentTheme ? .white : .lightGray
        label.position = CGPoint(x: 5, y: 0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 104
        buttonSprite.addChild(label)
        
        // Add subtle animation for current theme
        if isCurrentTheme {
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            buttonSprite.run(SKAction.repeatForever(pulseAction))
        }
    }
    
    private func createThemeSection(in parent: SKNode, panelSize: CGSize) {
        let sectionY = panelSize.height/2 - 140
        
        // Theme section header
        let themeHeader = createSectionHeader(text: "🎨 VISUAL THEMES", position: CGPoint(x: 0, y: sectionY))
        parent.addChild(themeHeader)
        
        // Current theme indicator
        let currentThemeLabel = SKLabelNode(fontNamed: "SF Pro Text")
        if currentThemeLabel.fontName == nil {
            currentThemeLabel.fontName = "Helvetica"
        }
        currentThemeLabel.text = "Active: \(VisualManager.shared.getCurrentTheme().displayName)"
        currentThemeLabel.fontSize = 16
        currentThemeLabel.fontColor = VisualManager.shared.getCurrentTheme().primaryColor
        currentThemeLabel.position = CGPoint(x: 0, y: sectionY - 30)
        currentThemeLabel.zPosition = 103
        parent.addChild(currentThemeLabel)
        
        // Theme buttons in a grid layout (2 columns)
        let buttonSize = CGSize(width: 130, height: 32)
        let horizontalSpacing: CGFloat = 75  // Increased spacing between columns
        let verticalSpacing: CGFloat = 40    // Spacing between rows
        var row = 0
        var col = 0
        
        for theme in GameTheme.allCases {
            if theme.isUnlocked {
                let xPos = (col == 0) ? -horizontalSpacing : horizontalSpacing
                let yPos = sectionY - 70 - (CGFloat(row) * verticalSpacing)
                
                createThemeButton(theme: theme, position: CGPoint(x: xPos, y: yPos), size: buttonSize, in: parent)
                
                col += 1
                if col >= 2 {
                    col = 0
                    row += 1
                }
            }
        }
    }
    
    private func createAudioSection(in parent: SKNode, panelSize: CGSize) {
        let sectionY = panelSize.height/2 - 340  // Moved down to give more space
        
        // Audio section header
        let audioHeader = createSectionHeader(text: "🔊 AUDIO SETTINGS", position: CGPoint(x: 0, y: sectionY))
        parent.addChild(audioHeader)
        
        let buttonSize = CGSize(width: 170, height: 38)
        let spacing: CGFloat = 95  // Increased spacing to prevent overlap
        
        // Sound toggle
        let soundText = SoundManager.shared.soundEnabled ? "🔊 SOUND: ON" : "🔇 SOUND: OFF"
        let soundColor = SoundManager.shared.soundEnabled ? UIColor.systemGreen : UIColor.systemRed
        
        createSettingsButton(
            text: soundText,
            size: buttonSize,
            position: CGPoint(x: -spacing, y: sectionY - 50),
            color: soundColor,
            name: "soundToggle",
            fontSize: 14,
            in: parent
        )
        
        // Music toggle
        let musicText = SoundManager.shared.musicEnabled ? "🎵 MUSIC: ON" : "🎵 MUSIC: OFF"
        let musicColor = SoundManager.shared.musicEnabled ? UIColor.systemGreen : UIColor.systemRed
        
        createSettingsButton(
            text: musicText,
            size: buttonSize,
            position: CGPoint(x: spacing, y: sectionY - 50),
            color: musicColor,
            name: "musicToggle",
            fontSize: 14,
            in: parent
        )
        
        // Haptic toggle (centered below)
        let hapticText = SoundManager.shared.hapticEnabled ? "📳 HAPTICS: ON" : "📳 HAPTICS: OFF"
        let hapticColor = SoundManager.shared.hapticEnabled ? UIColor.systemGreen : UIColor.systemRed
        
        createSettingsButton(
            text: hapticText,
            size: buttonSize,
            position: CGPoint(x: 0, y: sectionY - 100),
            color: hapticColor,
            name: "hapticToggle",
            fontSize: 14,
            in: parent
        )
    }
    
    private func createGameplaySection(in parent: SKNode, panelSize: CGSize) {
        let sectionY = panelSize.height/2 - 500  // Moved down to give more space
        
        // Gameplay section header
        let gameplayHeader = createSectionHeader(text: "🎮 GAMEPLAY", position: CGPoint(x: 0, y: sectionY))
        parent.addChild(gameplayHeader)
        
        // Game stats
        let statsLabel = SKLabelNode(fontNamed: "SF Pro Text")
        if statsLabel.fontName == nil {
            statsLabel.fontName = "Helvetica"
        }
        statsLabel.text = "High Score: \(gameManager.highScore) • Current Score: \(gameManager.score)"
        statsLabel.fontSize = 14
        statsLabel.fontColor = .lightGray
        statsLabel.position = CGPoint(x: 0, y: sectionY - 40)
        statsLabel.zPosition = 103
        parent.addChild(statsLabel)
        
        // Reset high score button
        createSettingsButton(
            text: "🔄 RESET HIGH SCORE",
            size: CGSize(width: 200, height: 35),
            position: CGPoint(x: 0, y: sectionY - 80),
            color: .systemOrange,
            name: "resetHighScore",
            fontSize: 14,
            in: parent
        )
    }
    
    private func createSectionHeader(text: String, position: CGPoint) -> SKLabelNode {
        let header = SKLabelNode(fontNamed: "SF Pro Display")
        if header.fontName == nil {
            header.fontName = "Helvetica-Bold"
        }
        header.text = text
        header.fontSize = 20
        header.fontColor = .white
        header.position = position
        header.zPosition = 103
        
        // Add underline effect
        let underline = SKSpriteNode(color: VisualManager.shared.getCurrentTheme().primaryColor, size: CGSize(width: 200, height: 2))
        underline.position = CGPoint(x: 0, y: -15)
        underline.alpha = 0.7
        header.addChild(underline)
        
        return header
    }
    
    private func hideSettingsOverlay() {
        childNode(withName: "settingsOverlay")?.removeFromParent()
        
        // Also remove any settings-related buttons that might have been added directly to the scene
        childNode(withName: "soundToggle")?.removeFromParent()
        childNode(withName: "musicToggle")?.removeFromParent()
        childNode(withName: "hapticToggle")?.removeFromParent()
        childNode(withName: "closeSettings")?.removeFromParent()
        childNode(withName: "resetHighScore")?.removeFromParent()
        
        // Remove any theme buttons
        for theme in GameTheme.allCases {
            childNode(withName: "themeButton_\(theme.rawValue)")?.removeFromParent()
        }
    }
    
    private func createSettingsButton(text: String, size: CGSize, position: CGPoint, color: UIColor, name: String, fontSize: CGFloat, in parent: SKNode) {
        // Create button texture
        let buttonTexture = VisualManager.shared.generateButtonTexture(size: size, baseColor: color)
        let buttonSprite = SKSpriteNode(texture: buttonTexture)
        buttonSprite.position = position
        buttonSprite.name = name
        buttonSprite.zPosition = 103
        parent.addChild(buttonSprite)
        
        // Add main label without shadow to prevent double text
        let label = SKLabelNode(fontNamed: "SF Pro Display")
        if label.fontName == nil {
            label.fontName = "Helvetica-Bold"
        }
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        
        buttonSprite.addChild(label)
    }
    
    private func createSettingsCloseButton(in parent: SKNode, panelSize: CGSize) {
        createSettingsButton(
            text: "✕ CLOSE",
            size: CGSize(width: 140, height: 45),
            position: CGPoint(x: 0, y: -panelSize.height/2 + 50),  // Moved up slightly
            color: .systemRed,
            name: "closeSettings",
            fontSize: 16,
            in: parent
        )
    }
    
    private func setupPreviewWindow() {
        let topEdge = self.size.height / 2
        let rightEdge = self.size.width / 2
        // Preview window background - adjust size if necessary
        let previewWindowSize = CGSize(width: max(gameGrid.cellSize * 1.2, 60), height: max(gameGrid.cellSize * 1.2 + 20, 70))
        previewWindow = SKSpriteNode(color: .black, size: previewWindowSize)
        // Positioned top-right, below pause button
        previewWindow.position = CGPoint(x: rightEdge - previewWindowSize.width/2 - 15, y: topEdge - 80 - previewWindowSize.height/2) 
        previewWindow.alpha = 0.8
        previewWindow.zPosition = 1
        addChild(previewWindow)
        
        // Preview title
        previewTitleLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if previewTitleLabel.fontName == nil {
            previewTitleLabel.fontName = "Helvetica-Bold"
        }
        previewTitleLabel.text = "NEXT"
        previewTitleLabel.fontSize = 12 // Slightly larger
        previewTitleLabel.fontColor = .white
        previewTitleLabel.position = CGPoint(x: 0, y: previewWindowSize.height/2 - 15) // Adjusted for new size
        previewTitleLabel.horizontalAlignmentMode = .center
        previewWindow.addChild(previewTitleLabel)
        
        // Container for next pieces
        nextPiecesContainer = SKNode()
        nextPiecesContainer.position = CGPoint(x: 0, y: 0) 
        previewWindow.addChild(nextPiecesContainer)
    }
    
    private func setupGridEnhancements() {
        // Remove duplicate grid lines - GameGrid already has its own grid lines
        // This should fix the alignment issue
        
        // Grid lines container - keeping for potential future use
        gridLines = SKNode()
        gridLines.zPosition = 0.5
        addChild(gridLines)
        
        // Don't create duplicate grid lines - GameGrid handles this
    }
    
    private func createGridLines() {
        gridLines.removeAllChildren()
        
        let gridSize = CGSize(width: CGFloat(gameGrid.columns) * gameGrid.cellSize, 
                             height: CGFloat(gameGrid.rows) * gameGrid.cellSize)
        
        // Vertical lines
        for i in 0...gameGrid.columns {
            let line = SKSpriteNode(color: .gray, size: CGSize(width: 1, height: gridSize.height))
            line.alpha = 0.3
            line.position = CGPoint(x: CGFloat(i) * gameGrid.cellSize - gridSize.width/2, y: 0)
            gridLines.addChild(line)
        }
        
        // Horizontal lines
        for i in 0...gameGrid.rows {
            let line = SKSpriteNode(color: .gray, size: CGSize(width: gridSize.width, height: 1))
            line.alpha = 0.3
            line.position = CGPoint(x: 0, y: CGFloat(i) * gameGrid.cellSize - gridSize.height/2)
            gridLines.addChild(line)
        }
        
        gridLines.position = gameGrid.position
    }
    
    private func updateProgressIndicators() {
        // Update progress based on placed pieces
        let totalPieces = gameGrid.rows * gameGrid.columns
        let placedPieces = gameGrid.getPlacedPiecesCount()
        let progress = Float(placedPieces) / Float(totalPieces)
        
        // Update progress bar
        let maxWidth: CGFloat = 196 // Slightly less than bar width for padding
        progressFill.size = CGSize(width: CGFloat(progress) * maxWidth, height: 18)
        progressFill.color = VisualManager.shared.getCurrentTheme().primaryColor
        
        // Update labels
        let percentage = Int(progress * 100)
        progressPercentLabel.text = "\(percentage)%"
        // Removed piece count label update - cleaner UI
    }
    
    private func updatePreviewWindow(with nextPieces: [PuzzlePiece]) {
        // Clear existing preview pieces
        nextPiecesContainer.removeAllChildren()
        
        // Show only 1 next piece (simplified)
        guard let firstPiece = nextPieces.first else { return }
        
        let previewPiece = SKSpriteNode(texture: firstPiece.texture)
        // Scale preview piece according to cell size, but not too large
        let previewCellSize = min(gameGrid.cellSize * 0.6, 40) // Cap max size for preview
        previewPiece.size = CGSize(width: previewCellSize, height: previewCellSize)
        previewPiece.position = CGPoint(x: 0, y: 0) // Centered in container
        previewPiece.alpha = 1.0 
        nextPiecesContainer.addChild(previewPiece)
    }
    
    private func showDropZoneHighlight(at gridPosition: (row: Int, column: Int)) {
        clearDropZoneHighlights()
        
        let highlight = SKSpriteNode(color: .green, size: CGSize(width: gameGrid.cellSize - 4, height: gameGrid.cellSize - 4))
        highlight.alpha = 0.5
        highlight.position = gameGrid.getWorldPosition(row: gridPosition.row, column: gridPosition.column)
        highlight.zPosition = 0.8
        gameGrid.addChild(highlight)
        dropZoneHighlights.append(highlight)
    }
    
    private func clearDropZoneHighlights() {
        dropZoneHighlights.forEach { $0.removeFromParent() }
        dropZoneHighlights.removeAll()
    }
    
    private func showPieceShadow(for piece: PuzzlePiece, at position: CGPoint) {
        removePieceShadow()
        
        pieceShadow = SKSpriteNode(texture: piece.texture)
        pieceShadow?.size = piece.size
        pieceShadow?.position = position
        pieceShadow?.alpha = 0.3
        pieceShadow?.color = .black
        pieceShadow?.colorBlendFactor = 0.8
        pieceShadow?.zPosition = piece.zPosition - 0.1
        gameGrid.addChild(pieceShadow!)
    }
    
    private func removePieceShadow() {
        pieceShadow?.removeFromParent()
        pieceShadow = nil
    }
    
    private func setupTabSystem() {
        // Create tab bar at bottom of screen
        tabBar = SKNode()
        tabBar.position = CGPoint(x: 0, y: -size.height * 0.45) // Bottom of screen
        tabBar.zPosition = 2
        addChild(tabBar)
        
        // Tab bar background
        let tabBarBackground = SKSpriteNode(color: .black, size: CGSize(width: size.width, height: 60))
        tabBarBackground.alpha = 0.8
        tabBarBackground.position = CGPoint.zero
        tabBar.addChild(tabBarBackground)
        
        // Home tab
        homeTab = createTab(text: "🏠 HOME", position: CGPoint(x: -size.width * 0.2, y: 0), isSelected: true)
        homeTab.name = "homeTab"
        tabBar.addChild(homeTab)
        
        // Settings tab
        settingsTab = createTab(text: "⚙️ SETTINGS", position: CGPoint(x: size.width * 0.2, y: 0), isSelected: false)
        settingsTab.name = "settingsTab"
        tabBar.addChild(settingsTab)
    }
    
    private func createTab(text: String, position: CGPoint, isSelected: Bool) -> SKSpriteNode {
        let tabSize = CGSize(width: 140, height: 50)
        let tabColor = isSelected ? VisualManager.shared.getCurrentTheme().primaryColor : .darkGray
        
        let tab = SKSpriteNode(color: tabColor, size: tabSize)
        tab.position = position
        
        let label = SKLabelNode(fontNamed: "Arial-Bold")
        label.text = text
        label.fontSize = 16
        label.fontColor = .white
        label.position = CGPoint.zero
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        tab.addChild(label)
        
        return tab
    }
    
    private func switchToTab(_ tabType: TabType) {
        currentTab = tabType
        
        // Update tab appearance
        switch tabType {
        case .home:
            homeTab.color = VisualManager.shared.getCurrentTheme().primaryColor
            settingsTab.color = .darkGray
            hideSettingsOverlay()
        case .settings:
            homeTab.color = .darkGray
            settingsTab.color = VisualManager.shared.getCurrentTheme().primaryColor
            createEnhancedSettingsOverlay()
        }
    }
    
    private func rotatePiece() {
        guard let piece = currentPiece else { return }
        
        piece.rotatePiece()
        
        // Show feedback about rotation
        if isFalling {
            showDropFeedback("Rotated while falling!", color: .orange)
        } else {
            showDropFeedback("Rotated!", color: .cyan)
        }
    }
    
    private func togglePause() {
        gameIsPaused.toggle()
        
        if gameIsPaused {
            stopAutoFall()
            // Pause background music
            SoundManager.shared.pauseBackgroundMusic()
            // Show pause overlay
            showPauseOverlay()
        } else {
            // Resume game
            hidePauseOverlay()
            // Resume background music
            SoundManager.shared.resumeBackgroundMusic()
            if let piece = currentPiece, !isFalling {
                startAutoFall(for: piece)
            }
        }
        
        // Update pause button text
        updatePauseButtonText()
    }
    
    private func updatePauseButtonText() {
        if let pauseButton = childNode(withName: "pauseButton") as? SKLabelNode {
            pauseButton.text = gameIsPaused ? "▶️" : "⏸"
        }
    }
    
    private func showPauseOverlay() {
        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.name = "pauseOverlay"
        overlay.zPosition = 100
        addChild(overlay)
        
        let pauseText = SKLabelNode(fontNamed: "SF Pro Display")
        if pauseText.fontName == nil {
            pauseText.fontName = "Helvetica-Bold"
        }
        pauseText.text = "PAUSED"
        pauseText.fontSize = 36
        pauseText.fontColor = .white
        pauseText.position = CGPoint(x: 0, y: size.height * 0.1)  // CENTER-BASED: slightly above center
        pauseText.horizontalAlignmentMode = .center
        pauseText.name = "pauseText"
        addChild(pauseText)
        
        // Add RESUME button - create it properly within the overlay
        createSettingsButton(
            text: "RESUME",
            size: CGSize(width: 120, height: 50),
            position: CGPoint(x: 0, y: -size.height * 0.1),
            color: .systemGreen,
            name: "resumeButton",
            fontSize: 18,
            in: self
        )
    }
    
    private func hidePauseOverlay() {
        childNode(withName: "pauseOverlay")?.removeFromParent()
        childNode(withName: "pauseText")?.removeFromParent()
        childNode(withName: "resumeButton")?.removeFromParent()
    }
    
    private func showGameOverScreen(success: Bool, finalScore: Int) {
        isGameOver = true
        stopAutoFall()
        
        // Create game over overlay
        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.name = "gameOverOverlay"
        overlay.zPosition = 100
        addChild(overlay)
        
        // Game over text
        let gameOverText = SKLabelNode(fontNamed: "SF Pro Display")
        if gameOverText.fontName == nil {
            gameOverText.fontName = "Helvetica-Bold"
        }
        gameOverText.text = success ? "PUZZLE COMPLETE!" : "GAME OVER"
        gameOverText.fontSize = 32
        gameOverText.fontColor = success ? .green : .red
        gameOverText.position = CGPoint(x: 0, y: size.height * 0.1)  // CENTER-BASED
        gameOverText.horizontalAlignmentMode = .center
        gameOverText.zPosition = 101
        addChild(gameOverText)
        
        // Final score
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Final Score: \(finalScore)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: -50)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        scoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 10)
        restartButton.fillColor = .green
        restartButton.strokeColor = .white
        restartButton.position = CGPoint(x: 0, y: -size.height * 0.15)  // CENTER-BASED: negative y for below center
        restartButton.name = "restartButton"
        restartButton.zPosition = 101
        addChild(restartButton)
        
        let restartLabel = SKLabelNode(fontNamed: "SF Pro Display")
        if restartLabel.fontName == nil {
            restartLabel.fontName = "Helvetica-Bold"
        }
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -7)
        restartLabel.horizontalAlignmentMode = .center
        restartButton.addChild(restartLabel)
    }
}

// MARK: - GameManagerDelegate

extension GameScene: GameManagerDelegate {
    func gameDidEnd(success: Bool, finalScore: Int) {
        // 🔊 AUDIO FEEDBACK: Play game over sound
        SoundManager.shared.playSound(.gameOver)
        SoundManager.shared.playHaptic(success ? .success : .error)
        
        showGameOverScreen(success: success, finalScore: finalScore)
    }
    
    func scoreDidUpdate(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
        
        // Update high score display if needed
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = "Best: \(gameManager.highScore)"
        }
    }
    
    func nextPieceGenerated(_ piece: PuzzlePiece) {
        print("🎯 DEBUG: nextPieceGenerated called with piece \(piece.pieceID)")
        print("🎯 DEBUG: Piece row: \(piece.correctRow), column: \(piece.correctColumn)")
        print("🎯 DEBUG: Current game state - paused: \(gameIsPaused), gameOver: \(isGameOver)")
        print("🎯 DEBUG: Previous currentPiece exists: \(currentPiece != nil)")
        print("🎯 DEBUG: Piece parent: \(piece.parent != nil ? "HAS PARENT" : "NO PARENT")")
        
        // Check for overflow before spawning new piece - TEMPORARILY DISABLED FOR DEBUGGING
        if false && checkForSpawnOverflow() {
            print("🧩 Cannot spawn piece - spawn area blocked!")
            triggerGameOverFromOverflow()
            return
        }
        
        // 🔊 AUDIO FEEDBACK: Play piece spawn sound
        SoundManager.shared.playSound(.pieceSpawn)
        SoundManager.shared.playHaptic(.light)
        
        // Clear any existing piece first
        if let existingPiece = currentPiece {
            print("🎯 DEBUG: Removing existing piece \(existingPiece.pieceID)")
            existingPiece.removeFromParent()
        }
        
        // SAFETY CHECK: Remove piece from any existing parent before adding
        if piece.parent != nil {
            print("🎯 DEBUG: WARNING - Piece \(piece.pieceID) already has parent, removing...")
            piece.removeFromParent()
        }
        
        // Show a simple text indicator instead of alert - DISABLED for cleaner gameplay
        /*
        let pieceLabel = SKLabelNode(fontNamed: "Arial-Bold")
        pieceLabel.text = "New Piece: \(piece.pieceID)"
        pieceLabel.fontSize = 14
        pieceLabel.fontColor = .green
        pieceLabel.position = CGPoint(x: 0, y: -size.height * 0.25)  // CENTER-BASED: x=0 for center, negative y for lower area
        pieceLabel.horizontalAlignmentMode = .center
        addChild(pieceLabel)
        
        // Remove the label after 2 seconds
        pieceLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
        */
        
        currentPiece = piece
        piece.spawnTime = CACurrentMediaTime()  // Set spawn time for scoring
        print("🎯 DEBUG: currentPiece set to: \(piece.pieceID)")
        
        // IMPROVED POSITIONING:
        // Spawn piece above the grid, centered horizontally relative to the grid.
        // The piece's texture and initial size are now determined by gameManager.setCellSize and gameGrid.cellSize.
        // So, piece.size should be correct.
        
        // Determine spawn X: Use the grid's coordinate system then convert.
        // Spawn in a column that corresponds to its correctColumn, or center if that's too complex.
        // For simplicity, let's try to spawn it aligned with its target column if possible, or center of grid.
        let targetColumnForSpawn = piece.correctColumn
        let spawnXInGridCoords = gameGrid.getWorldPosition(row: 0, column: targetColumnForSpawn).x
        let spawnXInSceneCoords = gameGrid.convert(CGPoint(x: spawnXInGridCoords, y: 0), to: self).x

        // Determine spawn Y: Above the visual top of the grid.
        // gameGrid.position.y is the center of the grid node.
        // Top of grid node content = gameGrid.position.y + (gameGrid.rows * gameGrid.cellSize) / 2
        let gridNodeTopY = gameGrid.position.y + (CGFloat(gameGrid.rows) * gameGrid.cellSize) / 2.0
        let spawnY = gridNodeTopY + gameGrid.cellSize * 0.75 // Spawn about 0.75 cell size above the grid top
        
        piece.position = CGPoint(x: spawnXInSceneCoords, y: spawnY)
        // piece.size is already set based on the texture from GameManager
        
        print("🧩 DEBUG: Piece \(piece.pieceID) spawned at SCENE position: \(piece.position) (Grid Col: \(targetColumnForSpawn))")
        print("🎯 DEBUG: Piece size: \(piece.size), gameGrid.cellSize: \(gameGrid.cellSize)")
        
        // VISIBLE SPAWNING: Make piece immediately visible and interactive
        piece.alpha = 1.0
        
        // SAFETY CHECK: Verify gameGrid exists and is valid
        guard gameGrid != nil else {
            print("🎯 DEBUG: ERROR - gameGrid is nil in nextPieceGenerated!")
            return
        }
        
        // Add piece to the GameScene (not directly to gameGrid yet, allows for free movement before placement)
        // Or, if pieces always spawn and fall within grid's influence area, add to gameGrid.
        // Current logic seems to add to gameGrid, let's maintain that.
        // Ensure piece's position is relative to its parent (gameGrid).
        let piecePositionInGridNode = gameGrid.convert(piece.position, from: self)
        piece.position = piecePositionInGridNode
        
        print("🎯 DEBUG: Adding piece \(piece.pieceID) to gameGrid at grid-local position: \(piece.position)")
        gameGrid.addChild(piece)
        print("🎯 DEBUG: Successfully added piece to gameGrid, children count: \(gameGrid.children.count)")
        
        // Ensure piece is responsive
        ensurePieceResponsiveness()
        
        // Start Tetris-style automatic falling
        print("🧩 Starting auto-fall for piece")
        startAutoFall(for: piece)
        
        // Update preview window with next pieces
        let nextPieces = gameManager.getNextPieces(count: 3)
        updatePreviewWindow(with: nextPieces)
        
        // Update progress indicators
        updateProgressIndicators()
    }
    
    func piecePlacedCorrectly() {
        print("🧩 piecePlacedCorrectly() called")
        updateCompletionLabel()
        updateProgressIndicators()
        if let piece = currentPiece {
            VisualManager.shared.createSparkleEffect(at: piece.position, in: self)
            VisualManager.shared.createFloatingScoreLabel(score: 100, at: piece.position, in: self)
        }
    }
    
    func piecePlacedIncorrectly() {
        print("🧩 piecePlacedIncorrectly() called")
        updateProgressIndicators()
        if let piece = currentPiece {
            VisualManager.shared.shakeNode(piece, intensity: 3.0, duration: 0.2)
            VisualManager.shared.createFloatingScoreLabel(score: -25, at: piece.position, in: self)
        }
    }
    
    // MARK: - Memory Management and Performance Fixes
    
    private func cleanupOldVisualEffects() {
        // Remove old visual effects to prevent memory accumulation
        let effectsToRemove = children.filter { node in
            // Remove nodes with specific names that are temporary effects
            if let name = node.name {
                return name.contains("effect") || 
                       name.contains("sparkle") || 
                       name.contains("floating") ||
                       name.contains("glow") ||
                       name.contains("dropFeedback") ||
                       node.zPosition > 50 // High z-position effects
            }
            return false
        }
        
        for effect in effectsToRemove {
            effect.removeAllActions()
            effect.removeFromParent()
        }
        
        // Clean up old pieces that might be floating around
        let orphanedPieces = children.filter { node in
            if let piece = node as? PuzzlePiece {
                // Remove pieces that aren't the current piece and aren't in the grid
                return piece != currentPiece && piece.parent == self
            }
            return false
        }
        
        for piece in orphanedPieces {
            print("🧩 CLEANUP: Removing orphaned piece \(piece.name ?? "unknown")")
            piece.removeAllActions()
            piece.removeFromParent()
        }
        
        // Clean up particles and other temporary nodes
        let temporaryNodes = children.filter { node in
            node.zPosition > 10 && node.alpha < 0.1 // Faded out temporary nodes
        }
        
        for node in temporaryNodes {
            node.removeAllActions()
            node.removeFromParent()
        }
        
        // Log memory status
        print("🧩 CLEANUP: Scene children count: \(children.count)")
        print("🧩 CLEANUP: GameGrid children count: \(gameGrid?.children.count ?? 0)")
    }
    
    private func ensureProperPieceCleanup() {
        // Ensure gameGrid only contains pieces that should be there
        guard let gameGrid = gameGrid else { return }
        
        var piecesToRemove: [SKNode] = []
        
        for child in gameGrid.children {
            if let piece = child as? PuzzlePiece {
                // Check if this piece is properly placed in the grid array
                var foundInGrid = false
                for row in 0..<gameGrid.rows {
                    for col in 0..<gameGrid.columns {
                        if gameGrid.grid[row][col] === piece {
                            foundInGrid = true
                            break
                        }
                    }
                    if foundInGrid { break }
                }
                
                // If piece is in scene but not in grid array, remove it
                if !foundInGrid && piece != currentPiece {
                    print("🧩 CLEANUP: Found orphaned piece in gameGrid: \(piece.name ?? "unknown")")
                    piecesToRemove.append(piece)
                }
            }
        }
        
        // Remove orphaned pieces
        for piece in piecesToRemove {
            piece.removeAllActions()
            piece.removeFromParent()
        }
    }
} 