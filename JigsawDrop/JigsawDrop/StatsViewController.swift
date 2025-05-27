import UIKit

class StatsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Stats Cards
    private let gamesPlayedCard = GlassmorphicCard()
    private let highScoreCard = GlassmorphicCard()
    private let totalTimeCard = GlassmorphicCard()
    private let achievementsCard = GlassmorphicCard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadStats() // Refresh stats when view appears
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
        animation.duration = 15.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
        
        // Title Label
        titleLabel.text = "🏆 Game Stats"
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
        
        // Setup stat cards
        setupStatCard(gamesPlayedCard, icon: "🎮", title: "Games Played", value: "0", subtitle: "Total games completed")
        setupStatCard(highScoreCard, icon: "⭐", title: "High Score", value: "0", subtitle: "Best performance")
        setupStatCard(totalTimeCard, icon: "⏱️", title: "Total Time", value: "0m", subtitle: "Time played")
        setupStatCard(achievementsCard, icon: "🏅", title: "Achievements", value: "0/10", subtitle: "Unlocked")
        
        // Add views
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(gamesPlayedCard)
        contentView.addSubview(highScoreCard)
        contentView.addSubview(totalTimeCard)
        contentView.addSubview(achievementsCard)
    }
    
    private func setupStatCard(_ card: GlassmorphicCard, icon: String, title: String, value: String, subtitle: String) {
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon Label
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = ThemeManager.Fonts.heading(size: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Value Label
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = ThemeManager.Fonts.title(size: 32)
        valueLabel.textColor = ThemeManager.Colors.accentColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.tag = 100 // For easy access when updating
        
        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = ThemeManager.Fonts.body(size: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
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
            
            // Games Played Card
            gamesPlayedCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            gamesPlayedCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gamesPlayedCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            gamesPlayedCard.heightAnchor.constraint(equalToConstant: 100),
            
            // High Score Card
            highScoreCard.topAnchor.constraint(equalTo: gamesPlayedCard.bottomAnchor, constant: 16),
            highScoreCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            highScoreCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            highScoreCard.heightAnchor.constraint(equalToConstant: 100),
            
            // Total Time Card
            totalTimeCard.topAnchor.constraint(equalTo: highScoreCard.bottomAnchor, constant: 16),
            totalTimeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            totalTimeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            totalTimeCard.heightAnchor.constraint(equalToConstant: 100),
            
            // Achievements Card
            achievementsCard.topAnchor.constraint(equalTo: totalTimeCard.bottomAnchor, constant: 16),
            achievementsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            achievementsCard.heightAnchor.constraint(equalToConstant: 100),
            achievementsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Stats Management
    private func loadStats() {
        // Load stats from UserDefaults
        let gamesPlayed = UserDefaults.standard.integer(forKey: "gamesPlayed")
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        let totalTime = UserDefaults.standard.integer(forKey: "totalPlayTime") // in seconds
        let achievements = UserDefaults.standard.integer(forKey: "achievementsUnlocked")
        
        // Update UI with animation
        updateStatCard(gamesPlayedCard, value: "\(gamesPlayed)")
        updateStatCard(highScoreCard, value: "\(highScore)")
        updateStatCard(totalTimeCard, value: formatTime(totalTime))
        updateStatCard(achievementsCard, value: "\(achievements)/10")
    }
    
    private func updateStatCard(_ card: UIView, value: String) {
        if let valueLabel = card.subviews.first(where: { $0.tag == 100 }) as? UILabel {
            // Animate value change
            UIView.transition(with: valueLabel, duration: 0.3, options: .transitionCrossDissolve) {
                valueLabel.text = value
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func animateEntrance() {
        let cards = [gamesPlayedCard, highScoreCard, totalTimeCard, achievementsCard]
        
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
    
    // MARK: - Public Methods for updating stats
    static func incrementGamesPlayed() {
        let current = UserDefaults.standard.integer(forKey: "gamesPlayed")
        UserDefaults.standard.set(current + 1, forKey: "gamesPlayed")
    }
    
    static func updateHighScore(_ score: Int) {
        let current = UserDefaults.standard.integer(forKey: "highScore")
        if score > current {
            UserDefaults.standard.set(score, forKey: "highScore")
        }
    }
    
    static func addPlayTime(_ seconds: Int) {
        let current = UserDefaults.standard.integer(forKey: "totalPlayTime")
        UserDefaults.standard.set(current + seconds, forKey: "totalPlayTime")
    }
    
    static func unlockAchievement() {
        let current = UserDefaults.standard.integer(forKey: "achievementsUnlocked")
        if current < 10 {
            UserDefaults.standard.set(current + 1, forKey: "achievementsUnlocked")
        }
    }
} 