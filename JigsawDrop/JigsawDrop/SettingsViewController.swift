import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Settings Cards
    private let soundCard = GlassmorphicCard()
    private let musicCard = GlassmorphicCard()
    private let difficultyCard = GlassmorphicCard()
    
    // Controls
    private let soundToggle = UISwitch()
    private let musicToggle = UISwitch()
    private let difficultySegmentedControl = UISegmentedControl(items: ["Easy", "Medium", "Hard"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        // Title Label
        titleLabel.text = "⚙️ Settings"
        titleLabel.font = ThemeManager.Fonts.title(size: 36)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.3
        titleLabel.layer.shadowRadius = 4
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup cards
        setupSoundCard()
        setupMusicCard()
        setupDifficultyCard()
        
        // Add views
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(soundCard)
        contentView.addSubview(musicCard)
        contentView.addSubview(difficultyCard)
    }
    
    private func setupSoundCard() {
        soundCard.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = "🔊"
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Sound Effects"
        titleLabel.font = ThemeManager.Fonts.heading(size: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Enable game sound effects"
        subtitleLabel.font = ThemeManager.Fonts.body(size: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        soundToggle.isOn = true
        soundToggle.onTintColor = ThemeManager.Colors.accentColor
        soundToggle.translatesAutoresizingMaskIntoConstraints = false
        
        soundCard.addSubview(iconLabel)
        soundCard.addSubview(titleLabel)
        soundCard.addSubview(subtitleLabel)
        soundCard.addSubview(soundToggle)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: soundCard.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: soundCard.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: soundCard.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: soundCard.bottomAnchor, constant: -16),
            
            soundToggle.trailingAnchor.constraint(equalTo: soundCard.trailingAnchor, constant: -20),
            soundToggle.centerYAnchor.constraint(equalTo: soundCard.centerYAnchor)
        ])
    }
    
    private func setupMusicCard() {
        musicCard.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = "🎵"
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Background Music"
        titleLabel.font = ThemeManager.Fonts.heading(size: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Play ambient background music"
        subtitleLabel.font = ThemeManager.Fonts.body(size: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        musicToggle.isOn = true
        musicToggle.onTintColor = ThemeManager.Colors.accentColor
        musicToggle.translatesAutoresizingMaskIntoConstraints = false
        
        musicCard.addSubview(iconLabel)
        musicCard.addSubview(titleLabel)
        musicCard.addSubview(subtitleLabel)
        musicCard.addSubview(musicToggle)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: musicCard.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: musicCard.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: musicCard.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: musicCard.bottomAnchor, constant: -16),
            
            musicToggle.trailingAnchor.constraint(equalTo: musicCard.trailingAnchor, constant: -20),
            musicToggle.centerYAnchor.constraint(equalTo: musicCard.centerYAnchor)
        ])
    }
    
    private func setupDifficultyCard() {
        difficultyCard.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = "🎯"
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Difficulty Level"
        titleLabel.font = ThemeManager.Fonts.heading(size: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose your challenge level"
        subtitleLabel.font = ThemeManager.Fonts.body(size: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        difficultySegmentedControl.selectedSegmentIndex = 1 // Medium by default
        difficultySegmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        difficultySegmentedControl.selectedSegmentTintColor = ThemeManager.Colors.accentColor
        difficultySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        difficultySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        difficultySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        difficultyCard.addSubview(iconLabel)
        difficultyCard.addSubview(titleLabel)
        difficultyCard.addSubview(subtitleLabel)
        difficultyCard.addSubview(difficultySegmentedControl)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: difficultyCard.leadingAnchor, constant: 20),
            iconLabel.topAnchor.constraint(equalTo: difficultyCard.topAnchor, constant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: difficultyCard.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: difficultyCard.trailingAnchor, constant: -20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: difficultyCard.trailingAnchor, constant: -20),
            
            difficultySegmentedControl.leadingAnchor.constraint(equalTo: difficultyCard.leadingAnchor, constant: 20),
            difficultySegmentedControl.trailingAnchor.constraint(equalTo: difficultyCard.trailingAnchor, constant: -20),
            difficultySegmentedControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            difficultySegmentedControl.bottomAnchor.constraint(equalTo: difficultyCard.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Sound Card
            soundCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            soundCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            soundCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            soundCard.heightAnchor.constraint(equalToConstant: 80),
            
            // Music Card
            musicCard.topAnchor.constraint(equalTo: soundCard.bottomAnchor, constant: 16),
            musicCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            musicCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            musicCard.heightAnchor.constraint(equalToConstant: 80),
            
            // Difficulty Card
            difficultyCard.topAnchor.constraint(equalTo: musicCard.bottomAnchor, constant: 16),
            difficultyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            difficultyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            difficultyCard.heightAnchor.constraint(equalToConstant: 120),
            difficultyCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        soundToggle.addTarget(self, action: #selector(soundToggleChanged), for: .valueChanged)
        musicToggle.addTarget(self, action: #selector(musicToggleChanged), for: .valueChanged)
        difficultySegmentedControl.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
    }
    
    @objc private func soundToggleChanged() {
        UserDefaults.standard.set(soundToggle.isOn, forKey: "soundEnabled")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show confirmation
        let message = soundToggle.isOn ? "Sound effects enabled" : "Sound effects disabled"
        CustomAlertView.show(message: message, type: .info, in: view)
    }
    
    @objc private func musicToggleChanged() {
        UserDefaults.standard.set(musicToggle.isOn, forKey: "musicEnabled")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show confirmation
        let message = musicToggle.isOn ? "Background music enabled" : "Background music disabled"
        CustomAlertView.show(message: message, type: .info, in: view)
    }
    
    @objc private func difficultyChanged() {
        UserDefaults.standard.set(difficultySegmentedControl.selectedSegmentIndex, forKey: "difficulty")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show confirmation
        let difficulties = ["Easy", "Medium", "Hard"]
        let selectedDifficulty = difficulties[difficultySegmentedControl.selectedSegmentIndex]
        CustomAlertView.show(message: "Difficulty set to \(selectedDifficulty)", type: .success, in: view)
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        soundToggle.isOn = UserDefaults.standard.bool(forKey: "soundEnabled")
        musicToggle.isOn = UserDefaults.standard.bool(forKey: "musicEnabled")
        difficultySegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "difficulty")
    }
    
    // MARK: - Animations
    private func animateEntrance() {
        let cards = [soundCard, musicCard, difficultyCard]
        
        // Initially hide cards
        cards.forEach { card in
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 50)
        }
        
        // Animate cards in sequence
        for (index, card) in cards.enumerated() {
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }
    }
} 