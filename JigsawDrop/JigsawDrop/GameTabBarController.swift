import UIKit

class GameTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameTabs()
        customizeTabBarAppearance()
        setupAnimatedTabBar()
    }
    
    private func setupGameTabs() {
        // Create Home Tab
        let homeVC = HomeViewController()
        let homeNavController = UINavigationController(rootViewController: homeVC)
        homeNavController.tabBarItem = createGameTabBarItem(
            title: "Home",
            imageName: "house.fill",
            tag: 0
        )
        
        // Create Game Tab
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        let gameNavController = UINavigationController(rootViewController: gameVC)
        gameNavController.tabBarItem = createGameTabBarItem(
            title: "Play",
            imageName: "gamecontroller.fill",
            tag: 1
        )
        
        // Create Settings Tab
        let settingsVC = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = createGameTabBarItem(
            title: "Settings",
            imageName: "gearshape.fill",
            tag: 2
        )
        
        // Create Stats Tab
        let statsVC = StatsViewController()
        let statsNavController = UINavigationController(rootViewController: statsVC)
        statsNavController.tabBarItem = createGameTabBarItem(
            title: "Stats",
            imageName: "chart.bar.fill",
            tag: 3
        )
        
        // Set view controllers
        viewControllers = [homeNavController, gameNavController, settingsNavController, statsNavController]
        
        // Set default selected tab
        selectedIndex = 0
    }
    
    private func createGameTabBarItem(title: String, imageName: String, tag: Int) -> UITabBarItem {
        let item = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            tag: tag
        )
        
        // Add gaming-style badge for certain tabs
        if tag == 1 { // Game tab
            item.badgeColor = ThemeManager.Colors.accentColor
            // Could add a badge for new features or notifications
        }
        
        return item
    }
    
    private func setupAnimatedTabBar() {
        // Replace the default tab bar with our custom animated one
        let animatedTabBar = AnimatedTabBar()
        setValue(animatedTabBar, forKey: "tabBar")
    }
    
    private func customizeTabBarAppearance() {
        // Create modern gaming-inspired appearance
        let appearance = UITabBarAppearance()
        
        // Background with glassmorphic effect
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        // Add subtle border with theme colors
        appearance.shadowColor = ThemeManager.Colors.accentColor.withAlphaComponent(0.3)
        appearance.shadowImage = createGradientImage()
        
        // Normal state styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: ThemeManager.Fonts.body(size: 12)
        ]
        
        // Selected state styling with theme colors
        appearance.stackedLayoutAppearance.selected.iconColor = ThemeManager.Colors.accentColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: ThemeManager.Colors.accentColor,
            .font: ThemeManager.Fonts.heading(size: 12)
        ]
        
        // Apply the appearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Add enhanced glow effect
        tabBar.layer.shadowColor = ThemeManager.Colors.accentColor.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowOpacity = 0.4
        tabBar.layer.shadowRadius = 12
        
        // Add custom selection animation
        delegate = self
    }
    
    private func createGradientImage() -> UIImage {
        let size = CGSize(width: 1, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    ThemeManager.Colors.accentColor.withAlphaComponent(0.8).cgColor,
                    ThemeManager.Colors.primaryGradientEnd.withAlphaComponent(0.4).cgColor,
                    UIColor.clear.cgColor
                ] as CFArray,
                locations: [0.0, 0.5, 1.0]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust tab bar height for modern aesthetic
        var tabFrame = tabBar.frame
        tabFrame.size.height = 90
        tabFrame.origin.y = view.frame.size.height - 90
        tabBar.frame = tabFrame
    }
}

// MARK: - UITabBarControllerDelegate
extension GameTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Add custom animation when switching tabs
        animateTabSelection(for: viewController)
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Add particle effect for special tabs
        if let tabIndex = viewControllers?.firstIndex(of: viewController), tabIndex == 1 {
            // Add confetti for game tab selection
            addConfettiEffect()
        }
    }
    
    private func animateTabSelection(for viewController: UIViewController) {
        guard let tabIndex = viewControllers?.firstIndex(of: viewController),
              let tabBarItems = tabBar.items else { return }
        
        // Create enhanced pulse animation for selected tab
        let pulseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.3
        pulseAnimation.values = [1.0, 1.3, 1.0]
        pulseAnimation.keyTimes = [0.0, 0.5, 1.0]
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Create glow animation
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.duration = 0.3
        glowAnimation.fromValue = 0.0
        glowAnimation.toValue = 0.8
        glowAnimation.autoreverses = true
        
        // Apply animations to the tab bar item view
        if let tabBarButton = getTabBarButton(at: tabIndex) {
            tabBarButton.layer.add(pulseAnimation, forKey: "pulse")
            tabBarButton.layer.shadowColor = ThemeManager.Colors.accentColor.cgColor
            tabBarButton.layer.shadowRadius = 10
            tabBarButton.layer.add(glowAnimation, forKey: "glow")
        }
        
        // Add enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Add selection sound effect
        playTabSelectionSound()
    }
    
    private func getTabBarButton(at index: Int) -> UIView? {
        let tabBarButtons = tabBar.subviews.filter { $0.isKind(of: NSClassFromString("UITabBarButton")!) }
        guard index < tabBarButtons.count else { return nil }
        return tabBarButtons[index]
    }
    
    private func addConfettiEffect() {
        let emitter = ParticleEmitter.createConfettiEmitter()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: tabBar.frame.minY)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        view.layer.addSublayer(emitter)
        
        // Remove emitter after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            emitter.removeFromSuperlayer()
        }
    }
    
    private func playTabSelectionSound() {
        // Placeholder for sound effect - integrate with SoundManager
        // SoundManager.shared.playSound(.tabSelection)
    }
} 