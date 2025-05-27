import UIKit
import SpriteKit

// MARK: - Theme System
enum GameTheme: String, CaseIterable {
    case classic = "Classic"
    case darkMode = "Dark Mode"
    case sunset = "Sunset"
    case ocean = "Ocean"
    case forest = "Forest"
    case neon = "Neon"
    case cyberpunk = "Cyberpunk"
    case minimalist = "Minimalist"
    case retro = "Retro"
    case nature = "Nature"
    case galaxy = "Galaxy"
    case aurora = "Aurora"
    
    var displayName: String { return rawValue }
    
    var primaryColor: UIColor {
        switch self {
        case .classic: return UIColor.systemBlue
        case .darkMode: return UIColor.darkGray
        case .sunset: return UIColor.systemOrange
        case .ocean: return UIColor.systemTeal
        case .forest: return UIColor.systemGreen
        case .neon: return UIColor.systemPurple
        case .cyberpunk: return UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) // Cyan
        case .minimalist: return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray
        case .retro: return UIColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0) // Hot pink
        case .nature: return UIColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 1.0) // Bright green
        case .galaxy: return UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1.0) // Purple
        case .aurora: return UIColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1.0) // Teal green
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .classic: return UIColor.systemCyan
        case .darkMode: return UIColor.gray
        case .sunset: return UIColor.systemRed
        case .ocean: return UIColor.systemBlue
        case .forest: return UIColor.systemBrown
        case .neon: return UIColor.systemPink
        case .cyberpunk: return UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0) // Magenta
        case .minimalist: return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light gray
        case .retro: return UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0) // Electric blue
        case .nature: return UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0) // Earth brown
        case .galaxy: return UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Pink
        case .aurora: return UIColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0) // Purple
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .classic: return UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        case .darkMode: return UIColor.black
        case .sunset: return UIColor(red: 0.2, green: 0.1, blue: 0.05, alpha: 1.0)
        case .ocean: return UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0)
        case .forest: return UIColor(red: 0.05, green: 0.15, blue: 0.05, alpha: 1.0)
        case .neon: return UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0)
        case .cyberpunk: return UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        case .minimalist: return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        case .retro: return UIColor(red: 0.1, green: 0.05, blue: 0.2, alpha: 1.0)
        case .nature: return UIColor(red: 0.1, green: 0.2, blue: 0.05, alpha: 1.0)
        case .galaxy: return UIColor(red: 0.05, green: 0.0, blue: 0.15, alpha: 1.0)
        case .aurora: return UIColor(red: 0.0, green: 0.1, blue: 0.15, alpha: 1.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .classic: return UIColor.white
        case .darkMode: return UIColor.lightGray
        case .sunset: return UIColor.white
        case .ocean: return UIColor.white
        case .forest: return UIColor.lightGray
        case .neon: return UIColor.white
        case .cyberpunk: return UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0) // Light cyan
        case .minimalist: return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Dark gray
        case .retro: return UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha: 1.0) // Light pink
        case .nature: return UIColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0) // Light cream
        case .galaxy: return UIColor(red: 0.9, green: 0.8, blue: 1.0, alpha: 1.0) // Light purple
        case .aurora: return UIColor(red: 0.8, green: 1.0, blue: 0.9, alpha: 1.0) // Light mint
        }
    }
    
    var isUnlocked: Bool {
        switch self {
        case .classic: return true // Always unlocked
        case .darkMode: return UserDefaults.standard.bool(forKey: "theme_darkMode_unlocked")
        case .sunset: return UserDefaults.standard.bool(forKey: "theme_sunset_unlocked")
        case .ocean: return UserDefaults.standard.bool(forKey: "theme_ocean_unlocked")
        case .forest: return UserDefaults.standard.bool(forKey: "theme_forest_unlocked")
        case .neon: return UserDefaults.standard.bool(forKey: "theme_neon_unlocked")
        case .cyberpunk: return UserDefaults.standard.bool(forKey: "theme_cyberpunk_unlocked")
        case .minimalist: 
            let isUnlocked = UserDefaults.standard.bool(forKey: "theme_minimalist_unlocked")
            print("🎨 Minimalist theme unlock status: \(isUnlocked)")
            return isUnlocked
        case .retro: return UserDefaults.standard.bool(forKey: "theme_retro_unlocked")
        case .nature: return UserDefaults.standard.bool(forKey: "theme_nature_unlocked")
        case .galaxy: return UserDefaults.standard.bool(forKey: "theme_galaxy_unlocked")
        case .aurora: return UserDefaults.standard.bool(forKey: "theme_aurora_unlocked")
        }
    }
    
    func unlock() {
        let key = "theme_\(rawValue.lowercased().replacingOccurrences(of: " ", with: ""))_unlocked"
        UserDefaults.standard.set(true, forKey: key)
        print("🎨 Unlocked theme: \(displayName) with key: \(key)")
    }
}

class VisualManager {
    static let shared = VisualManager()
    
    private var cachedTextures: [String: SKTexture] = [:]
    private var currentTheme: GameTheme = .classic
    
    private init() {
        loadCurrentTheme()
        unlockInitialThemes()
    }
    
    private func loadCurrentTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "currentTheme"),
           let theme = GameTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    private func unlockInitialThemes() {
        // Unlock some themes by default for demo
        GameTheme.darkMode.unlock()
        GameTheme.sunset.unlock()
        GameTheme.minimalist.unlock()
        GameTheme.ocean.unlock()
    }
    
    func setTheme(_ theme: GameTheme) {
        guard theme.isUnlocked else { return }
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "currentTheme")
        
        // Clear cached textures to regenerate with new theme
        cachedTextures.removeAll()
    }
    
    func getCurrentTheme() -> GameTheme {
        return currentTheme
    }
    
    // MARK: - Enhanced Particle Systems
    
    func createGlassmorphismPanel(size: CGSize, cornerRadius: CGFloat = 20) -> SKNode {
        let panel = SKNode()
        
        // Background blur effect
        let background = SKSpriteNode(color: currentTheme.backgroundColor.withAlphaComponent(0.3), size: size)
        background.zPosition = 0
        panel.addChild(background)
        
        // Border effect
        let border = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        border.strokeColor = currentTheme.primaryColor.withAlphaComponent(0.5)
        border.lineWidth = 2
        border.fillColor = .clear
        border.zPosition = 1
        panel.addChild(border)
        
        // Inner glow
        let innerGlow = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height - 4), cornerRadius: cornerRadius - 2)
        innerGlow.strokeColor = currentTheme.primaryColor.withAlphaComponent(0.2)
        innerGlow.lineWidth = 1
        innerGlow.fillColor = .clear
        innerGlow.zPosition = 2
        panel.addChild(innerGlow)
        
        return panel
    }
    
    func createFloatingParticles(in parent: SKNode, count: Int = 20) {
        for _ in 0..<count {
            let particle = SKSpriteNode(color: currentTheme.primaryColor.withAlphaComponent(0.3), size: CGSize(width: 2, height: 2))
            particle.position = CGPoint(
                x: CGFloat.random(in: -parent.frame.width/2...parent.frame.width/2),
                y: CGFloat.random(in: -parent.frame.height/2...parent.frame.height/2)
            )
            particle.zPosition = -5
            
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...50), duration: TimeInterval.random(in: 3...8)),
                SKAction.fadeOut(withDuration: 1),
                SKAction.removeFromParent()
            ])
            
            particle.run(floatAction)
            parent.addChild(particle)
        }
    }
    
    func createPieceGlowEffect(piece: SKNode, color: UIColor) {
        // Remove existing glow
        piece.childNode(withName: "glowEffect")?.removeFromParent()
        
        let glowNode = SKEffectNode()
        glowNode.name = "glowEffect"
        glowNode.shouldRasterize = true
        
        // Create glow sprite
        let glowSprite = SKSpriteNode(color: color, size: CGSize(width: 70, height: 70))
        glowSprite.alpha = 0.6
        glowNode.addChild(glowSprite)
        
        // Apply blur filter
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(8.0, forKey: "inputRadius")
        glowNode.filter = blurFilter
        
        glowNode.zPosition = -1
        piece.addChild(glowNode)
        
        // Animate glow
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 1.0),
            SKAction.scale(to: 0.8, duration: 1.0)
        ])
        glowNode.run(SKAction.repeatForever(pulseAction))
    }
    
    func createSparkleEffect(at position: CGPoint, in parent: SKNode) {
        let sparkleNode = SKEmitterNode()
        
        // Configure sparkle particles
        sparkleNode.particleBirthRate = 80
        sparkleNode.numParticlesToEmit = 30
        sparkleNode.particleLifetime = 1.2
        sparkleNode.particleLifetimeRange = 0.4
        sparkleNode.particleSpeed = 60
        sparkleNode.particleSpeedRange = 40
        sparkleNode.emissionAngle = 0
        sparkleNode.emissionAngleRange = CGFloat.pi * 2
        sparkleNode.particleScale = 0.3
        sparkleNode.particleScaleRange = 0.2
        sparkleNode.particleScaleSpeed = -0.2
        sparkleNode.particleRotation = 0
        sparkleNode.particleRotationRange = CGFloat.pi * 2
        sparkleNode.particleRotationSpeed = 3.0
        sparkleNode.particleColor = currentTheme.primaryColor
        sparkleNode.particleColorBlendFactor = 0.8
        sparkleNode.particleAlpha = 1.0
        sparkleNode.particleAlphaRange = 0.3
        sparkleNode.particleAlphaSpeed = -0.8
        
        // Position and add to parent
        sparkleNode.position = position
        sparkleNode.zPosition = 20
        parent.addChild(sparkleNode)
        
        // Remove after animation
        sparkleNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }
    
    func createExplosionEffect(at position: CGPoint, in parent: SKNode) {
        let explosionNode = SKEmitterNode()
        
        // Configure explosion particles
        explosionNode.particleBirthRate = 150
        explosionNode.numParticlesToEmit = 60
        explosionNode.particleLifetime = 1.8
        explosionNode.particleLifetimeRange = 0.6
        explosionNode.particleSpeed = 120
        explosionNode.particleSpeedRange = 80
        explosionNode.emissionAngle = 0
        explosionNode.emissionAngleRange = CGFloat.pi * 2
        explosionNode.particleScale = 0.6
        explosionNode.particleScaleRange = 0.4
        explosionNode.particleScaleSpeed = -0.3
        explosionNode.particleRotation = 0
        explosionNode.particleRotationRange = CGFloat.pi * 2
        explosionNode.particleRotationSpeed = 5.0
        explosionNode.particleColor = currentTheme.secondaryColor
        explosionNode.particleColorBlendFactor = 1.0
        explosionNode.particleAlpha = 1.0
        explosionNode.particleAlphaRange = 0.4
        explosionNode.particleAlphaSpeed = -0.6
        
        // Add color variation
        explosionNode.particleColorSequence = SKKeyframeSequence(keyframeValues: [
            currentTheme.primaryColor,
            currentTheme.secondaryColor,
            UIColor.white,
            currentTheme.primaryColor.withAlphaComponent(0.0)
        ], times: [0.0, 0.3, 0.6, 1.0])
        
        // Position and add to parent
        explosionNode.position = position
        explosionNode.zPosition = 25
        parent.addChild(explosionNode)
        
        // Remove after animation
        explosionNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func createFloatingScoreLabel(score: Int, at position: CGPoint, in parent: SKNode) {
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "+\(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = currentTheme.primaryColor
        scoreLabel.position = position
        scoreLabel.zPosition = 30
        
        // Add glow effect
        let glowLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        glowLabel.text = "+\(score)"
        glowLabel.fontSize = 26
        glowLabel.fontColor = UIColor.white
        glowLabel.alpha = 0.5
        glowLabel.zPosition = 29
        scoreLabel.addChild(glowLabel)
        
        parent.addChild(scoreLabel)
        
        // Animate the score
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        
        scoreLabel.run(SKAction.group([moveUp, fadeOut, scale])) {
            scoreLabel.removeFromParent()
        }
    }
    
    func createRowCompletionEffect(at position: CGPoint, in parent: SKNode) {
        // Create a spectacular explosion for row completion
        createExplosionEffect(at: position, in: parent)
        
        // Add additional visual flair
        let burstNode = SKEmitterNode()
        burstNode.particleBirthRate = 200
        burstNode.numParticlesToEmit = 100
        burstNode.particleLifetime = 2.0
        burstNode.particleSpeed = 150
        burstNode.particleSpeedRange = 100
        burstNode.emissionAngle = 0
        burstNode.emissionAngleRange = CGFloat.pi * 2
        burstNode.particleScale = 0.8
        burstNode.particleScaleRange = 0.5
        burstNode.particleScaleSpeed = -0.4
        burstNode.particleColor = UIColor.white
        burstNode.particleColorBlendFactor = 1.0
        burstNode.particleAlpha = 1.0
        burstNode.particleAlphaSpeed = -0.5
        
        burstNode.position = position
        burstNode.zPosition = 30
        parent.addChild(burstNode)
        
        burstNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Advanced Animations
    
    func animatePieceDrop(piece: SKNode, to targetPosition: CGPoint, completion: @escaping () -> Void) {
        // Create smooth dropping animation with bounce
        let dropAction = SKAction.move(to: targetPosition, duration: 0.6)
        dropAction.timingMode = .easeIn
        
        // Add subtle rotation during fall
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi / 8, duration: 0.6)
        rotateAction.timingMode = .easeInEaseOut
        
        let dropGroup = SKAction.group([dropAction, rotateAction])
        
        piece.run(dropGroup) {
            // Bounce effect on landing
            self.animatePieceBounce(piece: piece, completion: completion)
        }
    }
    
    func animatePieceBounce(piece: SKNode, completion: @escaping () -> Void) {
        let bounceSequence = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.1),
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        // Correct rotation to normal
        let straightenAction = SKAction.rotate(toAngle: 0, duration: 0.2)
        
        piece.run(SKAction.group([bounceSequence, straightenAction])) {
            completion()
        }
    }
    
    func animateSnapToPlace(piece: SKNode, to targetPosition: CGPoint, completion: @escaping () -> Void) {
        // Quick snap animation with magnetic feel
        let originalScale = piece.xScale
        
        let snapAction = SKAction.move(to: targetPosition, duration: 0.3)
        snapAction.timingMode = .easeOut
        
        let scaleSequence = SKAction.sequence([
            SKAction.scale(to: originalScale * 1.2, duration: 0.1),
            SKAction.scale(to: originalScale * 0.9, duration: 0.1),
            SKAction.scale(to: originalScale, duration: 0.1)
        ])
        
        piece.run(SKAction.group([snapAction, scaleSequence])) {
            completion()
        }
    }
    
    func animatePieceRotation(piece: SKNode, completion: @escaping () -> Void) {
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        
        // Add slight scaling for visual feedback
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        piece.run(SKAction.group([rotateAction, scaleSequence])) {
            completion()
        }
    }
    
    // MARK: - Screen Shake Effects
    
    func shakeScreen(_ scene: SKScene, intensity: CGFloat = 10.0, duration: TimeInterval = 0.5) {
        let originalPosition = scene.position
        
        var shakeActions: [SKAction] = []
        let numberOfShakes = Int(duration * 30) // 30 shakes per second
        
        for _ in 0..<numberOfShakes {
            let randomX = CGFloat.random(in: -intensity...intensity)
            let randomY = CGFloat.random(in: -intensity...intensity)
            let shakePosition = CGPoint(x: originalPosition.x + randomX, y: originalPosition.y + randomY)
            
            shakeActions.append(SKAction.move(to: shakePosition, duration: duration / Double(numberOfShakes)))
        }
        
        // Return to original position
        shakeActions.append(SKAction.move(to: originalPosition, duration: 0.1))
        
        let shakeSequence = SKAction.sequence(shakeActions)
        scene.run(shakeSequence)
    }
    
    func shakeNode(_ node: SKNode, intensity: CGFloat = 5.0, duration: TimeInterval = 0.3) {
        let originalPosition = node.position
        
        var shakeActions: [SKAction] = []
        let numberOfShakes = Int(duration * 20)
        
        for _ in 0..<numberOfShakes {
            let randomX = CGFloat.random(in: -intensity...intensity)
            let randomY = CGFloat.random(in: -intensity...intensity)
            let shakePosition = CGPoint(x: originalPosition.x + randomX, y: originalPosition.y + randomY)
            
            shakeActions.append(SKAction.move(to: shakePosition, duration: duration / Double(numberOfShakes)))
        }
        
        shakeActions.append(SKAction.move(to: originalPosition, duration: 0.1))
        
        let shakeSequence = SKAction.sequence(shakeActions)
        node.run(shakeSequence)
    }
    
    // MARK: - Theme Background Generation
    
    func generateThemeBackground(size: CGSize) -> SKTexture {
        let cacheKey = "background_\(currentTheme.rawValue)_\(size.width)x\(size.height)"
        
        if let cachedTexture = cachedTextures[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            
            // Create theme-specific gradient
            let colors = getThemeGradientColors()
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0.0, 0.5, 1.0])!
            
            // Draw diagonal gradient
            cgContext.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: 0),
                                       end: CGPoint(x: size.width, y: size.height),
                                       options: [])
            
            // Add theme-specific pattern overlay
            addThemePattern(to: cgContext, in: rect)
        }
        
        let texture = SKTexture(image: image)
        cachedTextures[cacheKey] = texture
        return texture
    }
    
    private func getThemeGradientColors() -> [CGColor] {
        switch currentTheme {
        case .classic:
            return [
                UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
                UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            ]
        case .darkMode:
            return [
                UIColor.black.cgColor,
                UIColor.darkGray.cgColor,
                UIColor.black.cgColor
            ]
        case .sunset:
            return [
                UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1.0).cgColor,
                UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.7, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
            ]
        case .ocean:
            return [
                UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
            ]
        case .forest:
            return [
                UIColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1.0).cgColor,
                UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.05, green: 0.2, blue: 0.05, alpha: 1.0).cgColor
            ]
        case .neon:
            return [
                UIColor(red: 0.3, green: 0.0, blue: 0.6, alpha: 1.0).cgColor,
                UIColor(red: 0.6, green: 0.0, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.2, green: 0.0, blue: 0.4, alpha: 1.0).cgColor
            ]
        case .cyberpunk:
            return [
                UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.0, blue: 0.1, alpha: 1.0).cgColor
            ]
        case .minimalist:
            return [
                UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor,
                UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).cgColor
            ]
        case .retro:
            return [
                UIColor(red: 0.2, green: 0.0, blue: 0.4, alpha: 1.0).cgColor,
                UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0).cgColor
            ]
        case .nature:
            return [
                UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1.0).cgColor,
                UIColor(red: 0.4, green: 0.7, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.3, blue: 0.05, alpha: 1.0).cgColor
            ]
        case .galaxy:
            return [
                UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0).cgColor,
                UIColor(red: 0.05, green: 0.0, blue: 0.1, alpha: 1.0).cgColor
            ]
        case .aurora:
            return [
                UIColor(red: 0.0, green: 0.2, blue: 0.3, alpha: 1.0).cgColor,
                UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            ]
        }
    }
    
    private func addThemePattern(to context: CGContext, in rect: CGRect) {
        switch currentTheme {
        case .classic, .darkMode:
            // Add subtle noise pattern
            addNoisePattern(to: context, in: rect, alpha: 0.1)
        case .sunset:
            // Add warm glow spots
            addGlowPattern(to: context, in: rect, color: UIColor.orange, count: 5)
        case .ocean:
            // Add wave-like pattern
            addWavePattern(to: context, in: rect)
        case .forest, .nature:
            // Add organic texture
            addOrganicPattern(to: context, in: rect)
        case .neon, .cyberpunk:
            // Add electric grid pattern
            addGridPattern(to: context, in: rect)
        case .minimalist:
            // Clean, no pattern
            break
        case .retro:
            // Add retro scan lines
            addScanLinePattern(to: context, in: rect)
        case .galaxy:
            // Add star field
            addStarFieldPattern(to: context, in: rect)
        case .aurora:
            // Add flowing aurora pattern
            addAuroraPattern(to: context, in: rect)
        }
    }
    
    private func addNoisePattern(to context: CGContext, in rect: CGRect, alpha: CGFloat) {
        for _ in 0..<200 {
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            let size = CGFloat.random(in: 0.5...2.0)
            
            context.setFillColor(UIColor.white.withAlphaComponent(alpha).cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }
    }
    
    private func addGlowPattern(to context: CGContext, in rect: CGRect, color: UIColor, count: Int) {
        for _ in 0..<count {
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            let radius = CGFloat.random(in: 20...60)
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [color.withAlphaComponent(0.3).cgColor, color.withAlphaComponent(0.0).cgColor] as CFArray,
                                    locations: [0.0, 1.0])!
            
            context.drawRadialGradient(gradient,
                                     startCenter: CGPoint(x: x, y: y), startRadius: 0,
                                     endCenter: CGPoint(x: x, y: y), endRadius: radius,
                                     options: [])
        }
    }
    
    private func addWavePattern(to context: CGContext, in rect: CGRect) {
        context.setStrokeColor(UIColor.cyan.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(1.0)
        
        for i in 0..<10 {
            let path = CGMutablePath()
            let y = rect.height * CGFloat(i) / 10.0
            
            path.move(to: CGPoint(x: 0, y: y))
            
            for x in stride(from: 0, to: rect.width, by: 10) {
                let waveY = y + sin(x * 0.02) * 5.0
                path.addLine(to: CGPoint(x: x, y: waveY))
            }
            
            context.addPath(path)
            context.strokePath()
        }
    }
    
    private func addOrganicPattern(to context: CGContext, in rect: CGRect) {
        context.setFillColor(UIColor.green.withAlphaComponent(0.1).cgColor)
        
        for _ in 0..<50 {
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            let width = CGFloat.random(in: 5...15)
            let height = CGFloat.random(in: 10...30)
            
            let leafRect = CGRect(x: x, y: y, width: width, height: height)
            let leafPath = UIBezierPath(ovalIn: leafRect)
            
            context.addPath(leafPath.cgPath)
            context.fillPath()
        }
    }
    
    private func addGridPattern(to context: CGContext, in rect: CGRect) {
        context.setStrokeColor(UIColor.magenta.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        let gridSize: CGFloat = 30
        
        // Vertical lines
        for x in stride(from: 0, to: rect.width, by: gridSize) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Horizontal lines
        for y in stride(from: 0, to: rect.height, by: gridSize) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        context.strokePath()
    }
    
    private func addScanLinePattern(to context: CGContext, in rect: CGRect) {
        context.setStrokeColor(UIColor.magenta.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(1.0)
        
        for y in stride(from: 0, through: rect.height, by: 4) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        context.strokePath()
    }
    
    private func addStarFieldPattern(to context: CGContext, in rect: CGRect) {
        for _ in 0..<100 {
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            let size = CGFloat.random(in: 0.5...3.0)
            let alpha = CGFloat.random(in: 0.3...1.0)
            
            context.setFillColor(UIColor.white.withAlphaComponent(alpha).cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }
    }
    
    private func addAuroraPattern(to context: CGContext, in rect: CGRect) {
        let colors = [
            UIColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 0.3).cgColor,
            UIColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.3).cgColor,
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.3).cgColor
        ]
        
        for (index, color) in colors.enumerated() {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [color, UIColor.clear.cgColor] as CFArray,
                                    locations: [0.0, 1.0])!
            
            let startY = rect.height * CGFloat(index) / CGFloat(colors.count)
            let endY = startY + rect.height / CGFloat(colors.count)
            
            context.drawLinearGradient(gradient,
                                     start: CGPoint(x: 0, y: startY),
                                     end: CGPoint(x: rect.width, y: endY),
                                     options: [])
        }
    }
    
    // MARK: - Puzzle Piece Generation
    
    func generatePuzzlePieceTexture(size: CGSize, color: UIColor, hasTopTab: Bool = false, hasRightTab: Bool = false, hasBottomTab: Bool = false, hasLeftTab: Bool = false) -> SKTexture {
        
        let cacheKey = "puzzlePiece_\(size.width)x\(size.height)_\(color.hashValue)_\(hasTopTab)_\(hasRightTab)_\(hasBottomTab)_\(hasLeftTab)_\(currentTheme.rawValue)"
        
        if let cachedTexture = cachedTextures[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Create the puzzle piece path
            let path = createPuzzlePiecePath(size: size, hasTopTab: hasTopTab, hasRightTab: hasRightTab, hasBottomTab: hasBottomTab, hasLeftTab: hasLeftTab)
            
            // Add gradient background based on theme
            let gradientColors = getThemeAdjustedPieceColors(baseColor: color)
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: gradientColors as CFArray,
                                    locations: [0.0, 0.5, 1.0])!
            
            cgContext.saveGState()
            cgContext.addPath(path)
            cgContext.clip()
            
            // Draw gradient
            cgContext.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: 0),
                                       end: CGPoint(x: size.width, y: size.height),
                                       options: [])
            
            cgContext.restoreGState()
            
            // Add puzzle piece border
            cgContext.addPath(path)
            cgContext.setStrokeColor(currentTheme.textColor.withAlphaComponent(0.8).cgColor)
            cgContext.setLineWidth(3.0)
            cgContext.strokePath()
            
            // Add inner highlight for 3D effect
            cgContext.addPath(path)
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.4).cgColor)
            cgContext.setLineWidth(1.5)
            cgContext.strokePath()
            
            // Add texture pattern
            addTexturePattern(to: cgContext, in: CGRect(origin: .zero, size: size), path: path)
        }
        
        let texture = SKTexture(image: image)
        cachedTextures[cacheKey] = texture
        return texture
    }
    
    private func getThemeAdjustedPieceColors(baseColor: UIColor) -> [CGColor] {
        switch currentTheme {
        case .classic:
            return [
                baseColor.cgColor,
                baseColor.withBrightness(brightness: 0.8).cgColor,
                baseColor.withBrightness(brightness: 1.2).cgColor
            ]
        case .darkMode:
            return [
                baseColor.withBrightness(brightness: 0.6).cgColor,
                baseColor.withBrightness(brightness: 0.4).cgColor,
                baseColor.withBrightness(brightness: 0.8).cgColor
            ]
        case .sunset:
            return [
                baseColor.blended(with: UIColor.orange, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.red, ratio: 0.2).cgColor,
                baseColor.blended(with: UIColor.yellow, ratio: 0.1).cgColor
            ]
        case .ocean:
            return [
                baseColor.blended(with: UIColor.blue, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.cyan, ratio: 0.2).cgColor,
                baseColor.blended(with: UIColor.white, ratio: 0.1).cgColor
            ]
        case .forest:
            return [
                baseColor.blended(with: UIColor.green, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.brown, ratio: 0.2).cgColor,
                baseColor.blended(with: UIColor.yellow, ratio: 0.1).cgColor
            ]
        case .neon:
            return [
                baseColor.blended(with: currentTheme.primaryColor, ratio: 0.4).cgColor,
                baseColor.blended(with: currentTheme.secondaryColor, ratio: 0.3).cgColor,
                UIColor.white.cgColor
            ]
        case .cyberpunk:
            return [
                baseColor.blended(with: UIColor.cyan, ratio: 0.4).cgColor,
                baseColor.blended(with: UIColor.magenta, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.white, ratio: 0.2).cgColor
            ]
        case .minimalist:
            return [
                baseColor.withBrightness(brightness: 0.9).cgColor,
                baseColor.withBrightness(brightness: 0.7).cgColor,
                baseColor.withBrightness(brightness: 1.1).cgColor
            ]
        case .retro:
            return [
                baseColor.blended(with: UIColor.magenta, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.cyan, ratio: 0.2).cgColor,
                baseColor.blended(with: UIColor.yellow, ratio: 0.1).cgColor
            ]
        case .nature:
            return [
                baseColor.blended(with: UIColor.green, ratio: 0.4).cgColor,
                baseColor.blended(with: UIColor.brown, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.yellow, ratio: 0.2).cgColor
            ]
        case .galaxy:
            return [
                baseColor.blended(with: UIColor.purple, ratio: 0.4).cgColor,
                baseColor.blended(with: UIColor.blue, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.white, ratio: 0.2).cgColor
            ]
        case .aurora:
            return [
                baseColor.blended(with: UIColor.cyan, ratio: 0.3).cgColor,
                baseColor.blended(with: UIColor.green, ratio: 0.2).cgColor,
                baseColor.blended(with: UIColor.purple, ratio: 0.1).cgColor
            ]
        }
    }
    
    private func createPuzzlePiecePath(size: CGSize, hasTopTab: Bool, hasRightTab: Bool, hasBottomTab: Bool, hasLeftTab: Bool) -> CGPath {
        let path = CGMutablePath()
        let cornerRadius: CGFloat = 8.0
        let tabSize: CGFloat = size.width * 0.25
        let tabDepth: CGFloat = size.height * 0.15
        
        // Start at top-left corner
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge with optional tab
        if hasTopTab {
            let tabCenter = size.width / 2
            path.addLine(to: CGPoint(x: tabCenter - tabSize/2, y: 0))
            // Draw tab curve
            path.addCurve(to: CGPoint(x: tabCenter + tabSize/2, y: 0),
                         control1: CGPoint(x: tabCenter - tabSize/4, y: -tabDepth),
                         control2: CGPoint(x: tabCenter + tabSize/4, y: -tabDepth))
        }
        path.addLine(to: CGPoint(x: size.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: size.width - cornerRadius, y: cornerRadius),
                   radius: cornerRadius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: false)
        
        // Right edge with optional tab
        if hasRightTab {
            let tabCenter = size.height / 2
            path.addLine(to: CGPoint(x: size.width, y: tabCenter - tabSize/2))
            // Draw tab curve
            path.addCurve(to: CGPoint(x: size.width, y: tabCenter + tabSize/2),
                         control1: CGPoint(x: size.width + tabDepth, y: tabCenter - tabSize/4),
                         control2: CGPoint(x: size.width + tabDepth, y: tabCenter + tabSize/4))
        }
        path.addLine(to: CGPoint(x: size.width, y: size.height - cornerRadius))
        path.addArc(center: CGPoint(x: size.width - cornerRadius, y: size.height - cornerRadius),
                   radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: false)
        
        // Bottom edge with optional tab
        if hasBottomTab {
            let tabCenter = size.width / 2
            path.addLine(to: CGPoint(x: tabCenter + tabSize/2, y: size.height))
            // Draw tab curve
            path.addCurve(to: CGPoint(x: tabCenter - tabSize/2, y: size.height),
                         control1: CGPoint(x: tabCenter + tabSize/4, y: size.height + tabDepth),
                         control2: CGPoint(x: tabCenter - tabSize/4, y: size.height + tabDepth))
        }
        path.addLine(to: CGPoint(x: cornerRadius, y: size.height))
        path.addArc(center: CGPoint(x: cornerRadius, y: size.height - cornerRadius),
                   radius: cornerRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: false)
        
        // Left edge with optional tab
        if hasLeftTab {
            let tabCenter = size.height / 2
            path.addLine(to: CGPoint(x: 0, y: tabCenter + tabSize/2))
            // Draw tab curve
            path.addCurve(to: CGPoint(x: 0, y: tabCenter - tabSize/2),
                         control1: CGPoint(x: -tabDepth, y: tabCenter + tabSize/4),
                         control2: CGPoint(x: -tabDepth, y: tabCenter - tabSize/4))
        }
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                   radius: cornerRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: false)
        
        path.closeSubpath()
        return path
    }
    
    private func addTexturePattern(to context: CGContext, in rect: CGRect, path: CGPath) {
        context.saveGState()
        context.addPath(path)
        context.clip()
        
        // Add subtle noise texture
        for _ in 0..<100 {
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            let size = CGFloat.random(in: 0.5...2.0)
            
            context.setFillColor(UIColor.white.withAlphaComponent(0.1).cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }
        
        context.restoreGState()
    }
    
    // MARK: - Button Generation
    
    func generateButtonTexture(size: CGSize, baseColor: UIColor, isPressed: Bool = false) -> SKTexture {
        let cacheKey = "button_\(size.width)x\(size.height)_\(baseColor.hashValue)_\(isPressed)_\(currentTheme.rawValue)"
        
        if let cachedTexture = cachedTextures[cacheKey] {
            return cachedTexture
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            let cornerRadius: CGFloat = min(size.width, size.height) * 0.2
            
            // Create rounded rectangle path
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerRadius)
            
            // Button gradient based on theme - with safety checks
            let themeAdjustedColor = baseColor.blended(with: currentTheme.primaryColor, ratio: 0.2)
            let lightColor = isPressed ? themeAdjustedColor.withBrightness(brightness: 0.7) : themeAdjustedColor.withBrightness(brightness: 1.3)
            let darkColor = isPressed ? themeAdjustedColor.withBrightness(brightness: 0.5) : themeAdjustedColor.withBrightness(brightness: 0.8)
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [lightColor.cgColor, darkColor.cgColor] as CFArray,
                                    locations: [0.0, 1.0])!
            
            cgContext.saveGState()
            cgContext.addPath(path.cgPath)
            cgContext.clip()
            
            // Draw gradient
            cgContext.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: 0),
                                       end: CGPoint(x: 0, y: size.height),
                                       options: [])
            
            cgContext.restoreGState()
            
            // Add border
            cgContext.addPath(path.cgPath)
            cgContext.setStrokeColor(currentTheme.textColor.withAlphaComponent(0.8).cgColor)
            cgContext.setLineWidth(2.0)
            cgContext.strokePath()
            
            // Add inner glow for pressed state
            if isPressed {
                cgContext.addPath(path.cgPath)
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
                cgContext.setLineWidth(1.0)
                cgContext.strokePath()
            }
        }
        
        let texture = SKTexture(image: image)
        cachedTextures[cacheKey] = texture
        return texture
    }
    
    // MARK: - Background Generation
    
    func generateBackgroundTexture(size: CGSize) -> SKTexture {
        // Use the new theme background system
        return generateThemeBackground(size: size)
    }
    
    // MARK: - Loading Screen Animation
    
    func createLoadingScreen(in scene: SKScene, completion: @escaping () -> Void) {
        // Create loading background - properly positioned to cover full screen
        let loadingBackground = SKSpriteNode(color: currentTheme.backgroundColor, size: scene.size)
        loadingBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        loadingBackground.zPosition = 1000
        loadingBackground.name = "loadingScreen"
        scene.addChild(loadingBackground)
        
        // Create title - positioned at true screen center
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "JIGSAW DROP"
        titleLabel.fontSize = 48
        titleLabel.fontColor = currentTheme.primaryColor
        titleLabel.position = CGPoint(x: 0, y: 50) // Slightly above center
        titleLabel.alpha = 0
        titleLabel.zPosition = 1001
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        loadingBackground.addChild(titleLabel)
        
        // Create loading label - positioned below title
        let loadingLabel = SKLabelNode(fontNamed: "Helvetica")
        loadingLabel.text = "Loading..."
        loadingLabel.fontSize = 24
        loadingLabel.fontColor = currentTheme.textColor
        loadingLabel.position = CGPoint(x: 0, y: 0) // At center of background
        loadingLabel.alpha = 0
        loadingLabel.zPosition = 1001
        loadingLabel.horizontalAlignmentMode = .center
        loadingLabel.verticalAlignmentMode = .center
        loadingBackground.addChild(loadingLabel)
        
        // Create animated puzzle pieces
        createLoadingPuzzlePieces(in: loadingBackground, sceneSize: scene.size)
        
        // Animate title appearance
        titleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.8),
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Animate loading label
        loadingLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ]))
        ]))
        
        // Complete loading after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            loadingBackground.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ])) {
                completion()
            }
        }
    }
    
    private func createLoadingPuzzlePieces(in parent: SKNode, sceneSize: CGSize) {
        let pieceSize: CGFloat = 40
        let gridSize = 4
        let spacing: CGFloat = 5
        let totalWidth = CGFloat(gridSize) * (pieceSize + spacing) - spacing
        let totalHeight = CGFloat(gridSize) * (pieceSize + spacing) - spacing
        let startX = -totalWidth / 2
        let startY = -totalHeight / 2 - 100 // Position below the title
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let piece = createLoadingPuzzlePiece(size: pieceSize, row: row, col: col, gridSize: gridSize)
                
                let finalX = startX + CGFloat(col) * (pieceSize + spacing) + pieceSize / 2
                let finalY = startY + CGFloat(row) * (pieceSize + spacing) + pieceSize / 2
                
                // Start pieces scattered around the screen
                let randomAngle = CGFloat.random(in: 0...(2 * CGFloat.pi))
                let randomDistance = CGFloat.random(in: 200...400)
                let startX = cos(randomAngle) * randomDistance
                let startY = sin(randomAngle) * randomDistance
                
                piece.position = CGPoint(x: startX, y: startY)
                piece.alpha = 0
                piece.zRotation = CGFloat.random(in: 0...(2 * CGFloat.pi))
                piece.zPosition = 1002
                parent.addChild(piece)
                
                // Animate pieces flying in and assembling
                let delay = Double.random(in: 0.5...2.0)
                piece.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.3),
                        SKAction.move(to: CGPoint(x: finalX, y: finalY), duration: 1.0),
                        SKAction.rotate(toAngle: 0, duration: 1.0)
                    ]),
                    SKAction.scale(to: 1.1, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ]))
            }
        }
    }
    
    private func createLoadingPuzzlePiece(size: CGFloat, row: Int, col: Int, gridSize: Int) -> SKSpriteNode {
        let hasTopTab = row > 0 && Bool.random()
        let hasRightTab = col < gridSize - 1 && Bool.random()
        let hasBottomTab = row < gridSize - 1 && Bool.random()
        let hasLeftTab = col > 0 && Bool.random()
        
        let hue = CGFloat(row * gridSize + col) / CGFloat(gridSize * gridSize)
        let color = UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1.0)
        
        let texture = generatePuzzlePieceTexture(
            size: CGSize(width: size, height: size),
            color: color,
            hasTopTab: hasTopTab,
            hasRightTab: hasRightTab,
            hasBottomTab: hasBottomTab,
            hasLeftTab: hasLeftTab
        )
        
        return SKSpriteNode(texture: texture)
    }
    
    // MARK: - Utility Functions
    
    func clearCache() {
        cachedTextures.removeAll()
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    func withBrightness(brightness: CGFloat) -> UIColor {
        // Clamp brightness to valid range
        let clampedBrightness = max(0.0, min(1.0, brightness))
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: clampedBrightness, alpha: alpha)
        }
        
        // Fallback: try to adjust using RGB components
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            // Simple brightness adjustment by scaling RGB components
            let factor = clampedBrightness
            return UIColor(red: min(1.0, r * factor), green: min(1.0, g * factor), blue: min(1.0, b * factor), alpha: a)
        }
        
        // Last resort: return original color
        print("⚠️ Warning: Failed to adjust brightness, returning original color")
        return self
    }
    
    func blended(with color: UIColor, ratio: CGFloat) -> UIColor {
        // Clamp ratio to valid range
        let clampedRatio = max(0.0, min(1.0, ratio))
        
        // Convert both colors to RGBA components to ensure consistency
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        // Get RGBA components from both colors with fallback
        let success1 = self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        let success2 = color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        guard success1 && success2 else {
            // If we can't get RGBA components, return the original color
            print("⚠️ Warning: Failed to blend colors, returning original color")
            return self
        }
        
        // Blend the components
        let r = (1 - clampedRatio) * r1 + clampedRatio * r2
        let g = (1 - clampedRatio) * g1 + clampedRatio * g2
        let b = (1 - clampedRatio) * b1 + clampedRatio * b2
        let a = (1 - clampedRatio) * a1 + clampedRatio * a2
        
        // Clamp all components to valid range
        let clampedR = max(0.0, min(1.0, r))
        let clampedG = max(0.0, min(1.0, g))
        let clampedB = max(0.0, min(1.0, b))
        let clampedA = max(0.0, min(1.0, a))
        
        return UIColor(red: clampedR, green: clampedG, blue: clampedB, alpha: clampedA)
    }
} 