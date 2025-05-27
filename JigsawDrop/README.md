# Jigsaw Drop

A unique iOS puzzle game that combines the fast-paced mechanics of Tetris with the strategic challenge of jigsaw puzzles.

## Game Description

Jigsaw Drop is an innovative mobile game where puzzle pieces fall from the top of the screen like Tetris blocks, but instead of forming lines, your goal is to correctly assemble a complete jigsaw puzzle. The game follows these core mechanics:

- **Row-by-Row Progression**: Pieces fall in order of rows, starting with the bottom row first
- **Random Order**: Within each row, pieces fall in random order, requiring you to identify and place them correctly
- **Real-Time Placement**: You must move and rotate falling pieces to their correct positions before they land
- **Strategic Thinking**: Incorrect placements can be corrected later, but too many mistakes will end the game

## How to Play

### Controls
- **Drag**: Move the falling piece left or right
- **Tap/Double-tap**: Rotate the piece 90 degrees
- **Rotate Button**: Alternative method to rotate pieces
- **Pause Button**: Pause/resume the game

### Gameplay Mechanics
1. Pieces fall one at a time for the current row (starting from the bottom)
2. Position and rotate each piece to match its correct location in the puzzle
3. When correctly placed, pieces turn green and lock in place
4. Complete all pieces in a row to advance to the next row above
5. Complete all rows to win the game

### Scoring System
- **+100 points**: Correctly placed piece
- **-25 points**: Incorrectly placed piece
- **+500 points**: Complete a row
- **Game Speed**: Increases as you progress

### Win/Lose Conditions
- **Win**: Complete all rows of the puzzle
- **Lose**: Accumulate too many incorrectly placed pieces (15+ mistakes)

## Features

### Core Game Features
- 6x6 puzzle grid with unique colored pieces
- Row-by-row progression system
- Piece rotation and movement controls
- Visual feedback for correct/incorrect placements
- Progressive difficulty with increasing fall speed

### User Interface
- **Homepage**: Modern welcome screen with navigation to game and settings
- **Settings**: Customizable sound effects, music, and difficulty options
- Real-time score tracking
- Current row indicator
- Pause/resume functionality
- Game over screen with restart option
- Visual grid with highlighted current row
- Easy navigation between homepage and game

### Visual Design
- Clean, modern interface optimized for iOS devices
- Color-coded puzzle pieces for easy identification
- Smooth animations and visual feedback
- Portrait and landscape orientation support

## Technical Implementation

### Architecture
- **SpriteKit**: Game rendering and animation engine
- **MVC Pattern**: Clean separation of game logic and presentation
- **Delegate Pattern**: Communication between game components

### Key Classes
- `GameScene`: Main SpriteKit scene managing game display and user input
- `GameManager`: Core game logic, scoring, and state management
- `GameGrid`: Grid management and piece placement logic
- `PuzzlePiece`: Individual puzzle piece with placement validation
- `GameViewController`: UIKit integration and scene presentation

### Game Components
- **Puzzle Piece System**: Unique pieces with position validation
- **Grid Management**: 6x6 grid with row-based progression
- **Scoring Engine**: Point system with multiple scoring events
- **Timer System**: Automatic piece dropping with variable speed
- **Input Handling**: Touch-based movement and rotation controls

## Installation

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run the project
4. The game will launch automatically

## Requirements

- iOS 13.0 or later
- Xcode 12.0 or later
- Swift 5.0 or later

## Game Tips

1. **Study the Pattern**: Each piece shows its intended coordinates (row, column)
2. **Plan Ahead**: Consider where pieces belong before they land
3. **Use Rotation**: Don't forget pieces may need to be rotated to fit correctly
4. **Manage Mistakes**: A few wrong placements are okay, but don't let them accumulate
5. **Stay Calm**: The game speed increases, but accuracy is more important than speed

## Future Enhancements

- Multiple difficulty levels (different grid sizes)
- Custom puzzle images
- Power-ups and special abilities
- Multiplayer modes
- Achievement system
- Leaderboards and social features

Enjoy playing Jigsaw Drop! 