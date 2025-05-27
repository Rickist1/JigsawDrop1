import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let containerView = GlassmorphicCard()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let playButton = AnimatedGradientButton()
    private let settingsButton = AnimatedGradientButton()
    private let statsButton = AnimatedGradientButton()
    private let aboutButton = AnimatedGradientButton()
    private let floatingPuzzlePieces: [UIImageView] = (0..<5).map { _ in UIImageView() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        animateFloatingPieces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar for clean homepage look
        navigationController?.setNavigationBarHidden(true, animated: animated)
        animateEntrance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient layer frame when view layout changes
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Animated Background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ThemeManager.Colors.primaryGradientStart.cgColor,
            ThemeManager.Colors.primaryGradientEnd.cgColor,
            ThemeManager.Colors.secondaryGradientEnd.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add animated gradient movement
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            ThemeManager.Colors.secondaryGradientStart.cgColor,
            ThemeManager.Colors.primaryGradientEnd.cgColor,
            ThemeManager.Colors.primaryGradientStart.cgColor
        ]
        animation.duration = 10.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        titleLabel.text = "JigsawDrop"
        titleLabel.font = ThemeManager.Fonts.title(size: 52)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.3
        titleLabel.layer.shadowRadius = 4
        
        // Subtitle Label
        subtitleLabel.text = "Puzzle Your Way to Victory"
        subtitleLabel.font = ThemeManager.Fonts.body(size: 20)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Play Button
        playButton.setTitle("🎮 Play Game", for: .normal)
        playButton.gradientColors = [ThemeManager.Colors.primaryGradientStart, ThemeManager.Colors.primaryGradientEnd]
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Settings Button
        settingsButton.setTitle("⚙️ Settings", for: .normal)
        settingsButton.gradientColors = [UIColor.systemGray2, UIColor.systemGray]
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Stats Button
        statsButton.setTitle("📊 Stats", for: .normal)
        statsButton.gradientColors = [ThemeManager.Colors.secondaryGradientStart, ThemeManager.Colors.secondaryGradientEnd]
        statsButton.translatesAutoresizingMaskIntoConstraints = false
        
        // About Button
        aboutButton.setTitle("ℹ️ About", for: .normal)
        aboutButton.gradientColors = [ThemeManager.Colors.accentColor, UIColor.systemTeal]
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup floating pieces
        setupFloatingPieces()
        
        // Add all views
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(playButton)
        containerView.addSubview(settingsButton)
        containerView.addSubview(statsButton)
        containerView.addSubview(aboutButton)
        
        floatingPuzzlePieces.forEach { view.addSubview($0) }
    }
    
    private func setupFloatingPieces() {
        let pieceImages = ["🧩", "🧩", "🧩", "🧩", "🧩"]
        
        for (index, piece) in floatingPuzzlePieces.enumerated() {
            piece.translatesAutoresizingMaskIntoConstraints = false
            
            // Create label with emoji
            let label = UILabel()
            label.text = pieceImages[index]
            label.font = .systemFont(ofSize: 40)
            label.sizeToFit()
            
            // Convert to image
            let renderer = UIGraphicsImageRenderer(size: label.bounds.size)
            piece.image = renderer.image { context in
                label.layer.render(in: context.cgContext)
            }
            
            piece.alpha = 0.3
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Play Button
            playButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            playButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            playButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Settings Button
            settingsButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            settingsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            settingsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            settingsButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Stats Button
            statsButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 16),
            statsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            statsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            statsButton.heightAnchor.constraint(equalToConstant: 56),
            
            // About Button
            aboutButton.topAnchor.constraint(equalTo: statsButton.bottomAnchor, constant: 16),
            aboutButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            aboutButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            aboutButton.heightAnchor.constraint(equalToConstant: 56),
            aboutButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            
            // Floating pieces (positioned randomly)
            floatingPuzzlePieces[0].topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            floatingPuzzlePieces[0].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            floatingPuzzlePieces[1].topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            floatingPuzzlePieces[1].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            floatingPuzzlePieces[2].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            floatingPuzzlePieces[2].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
            floatingPuzzlePieces[3].topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            floatingPuzzlePieces[3].centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            floatingPuzzlePieces[4].bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            floatingPuzzlePieces[4].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        statsButton.addTarget(self, action: #selector(statsButtonTapped), for: .touchUpInside)
        aboutButton.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
    }
    
    @objc private func playButtonTapped() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Switch to game tab with animation
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.containerView.alpha = 0.8
        } completion: { _ in
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 1 // Game tab
            }
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }
    
    @objc private func settingsButtonTapped() {
        // Switch to settings tab
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2 // Settings tab
        }
    }
    
    @objc private func statsButtonTapped() {
        // Switch to stats tab
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 3 // Stats tab
        }
    }
    
    @objc private func aboutButtonTapped() {
        // Create custom about view
        let aboutView = GlassmorphicCard()
        aboutView.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton(type: .close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .white
        
        let aboutTitle = UILabel()
        aboutTitle.text = "About JigsawDrop"
        aboutTitle.font = ThemeManager.Fonts.heading(size: 28)
        aboutTitle.textColor = .white
        aboutTitle.textAlignment = .center
        aboutTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let aboutText = UILabel()
        aboutText.text = "A fun and challenging jigsaw puzzle game where pieces drop from above. Arrange them to complete beautiful puzzles!\n\nVersion 1.0\nCreated with ❤️"
        aboutText.font = ThemeManager.Fonts.body()
        aboutText.textColor = .white
        aboutText.numberOfLines = 0
        aboutText.textAlignment = .center
        aboutText.translatesAutoresizingMaskIntoConstraints = false
        
        aboutView.addSubview(closeButton)
        aboutView.addSubview(aboutTitle)
        aboutView.addSubview(aboutText)
        
        view.addSubview(aboutView)
        
        NSLayoutConstraint.activate([
            aboutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aboutView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aboutView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            aboutView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            closeButton.topAnchor.constraint(equalTo: aboutView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: aboutView.trailingAnchor, constant: -16),
            
            aboutTitle.topAnchor.constraint(equalTo: aboutView.topAnchor, constant: 60),
            aboutTitle.leadingAnchor.constraint(equalTo: aboutView.leadingAnchor, constant: 20),
            aboutTitle.trailingAnchor.constraint(equalTo: aboutView.trailingAnchor, constant: -20),
            
            aboutText.topAnchor.constraint(equalTo: aboutTitle.bottomAnchor, constant: 20),
            aboutText.leadingAnchor.constraint(equalTo: aboutView.leadingAnchor, constant: 20),
            aboutText.trailingAnchor.constraint(equalTo: aboutView.trailingAnchor, constant: -20),
            aboutText.bottomAnchor.constraint(equalTo: aboutView.bottomAnchor, constant: -40)
        ])
        
        // Animate in
        aboutView.alpha = 0
        aboutView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            aboutView.alpha = 1
            aboutView.transform = .identity
        }
        
        closeButton.addTarget(self, action: #selector(closeAbout(_:)), for: .touchUpInside)
    }
    
    @objc private func closeAbout(_ sender: UIButton) {
        if let aboutView = sender.superview {
            UIView.animate(withDuration: 0.2, animations: {
                aboutView.alpha = 0
                aboutView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                aboutView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Animations
    private func animateEntrance() {
        // Prepare for animation
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        let buttons = [playButton, settingsButton, statsButton, aboutButton]
        buttons.forEach { button in
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: -50, y: 0)
        }
        
        // Animate container
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
        
        // Animate buttons in sequence
        for (index, button) in buttons.enumerated() {
            UIView.animate(withDuration: 0.5, delay: 0.1 + Double(index) * 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                button.alpha = 1
                button.transform = .identity
            }
        }
    }
    
    private func animateFloatingPieces() {
        floatingPuzzlePieces.forEach { piece in
            // Random floating animation
            let randomDuration = Double.random(in: 3...5)
            let randomDelay = Double.random(in: 0...2)
            
            UIView.animate(withDuration: randomDuration, delay: randomDelay, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                piece.transform = CGAffineTransform(translationX: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20))
                    .rotated(by: CGFloat.random(in: -0.5...0.5))
            })
        }
    }
} 