import UIKit

// MARK: - Theme Manager
class ThemeManager {
    static let shared = ThemeManager()
    
    struct Colors {
        static let primaryGradientStart = UIColor(red: 0.29, green: 0.00, blue: 0.94, alpha: 1.0)
        static let primaryGradientEnd = UIColor(red: 0.00, green: 0.47, blue: 1.00, alpha: 1.0)
        static let secondaryGradientStart = UIColor(red: 1.00, green: 0.00, blue: 0.88, alpha: 1.0)
        static let secondaryGradientEnd = UIColor(red: 0.44, green: 0.00, blue: 1.00, alpha: 1.0)
        static let accentColor = UIColor(red: 0.00, green: 0.78, blue: 0.95, alpha: 1.0)
        static let successColor = UIColor(red: 0.20, green: 0.84, blue: 0.29, alpha: 1.0)
        static let warningColor = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.0)
    }
    
    struct Fonts {
        static func title(size: CGFloat = 48) -> UIFont {
            return UIFont(name: "SF Pro Display", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        }
        
        static func heading(size: CGFloat = 24) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        
        static func body(size: CGFloat = 17) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
}

// MARK: - Glassmorphic Card View
class GlassmorphicCard: UIView {
    
    private let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    private lazy var blurView = UIVisualEffectView(effect: blurEffect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        // Add blur effect
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Add border
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 20
    }
}

// MARK: - Animated Gradient Button
class AnimatedGradientButton: UIButton {
    
    private var gradientLayer: CAGradientLayer?
    private var animator: UIViewPropertyAnimator?
    
    var gradientColors: [UIColor] = [ThemeManager.Colors.primaryGradientStart, ThemeManager.Colors.primaryGradientEnd] {
        didSet {
            updateGradient()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        layer.cornerRadius = 25
        layer.masksToBounds = true
        
        titleLabel?.font = ThemeManager.Fonts.heading(size: 20)
        setTitleColor(.white, for: .normal)
        
        // Add gradient
        updateGradient()
        
        // Add touch animations
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func updateGradient() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = gradientColors.map { $0.cgColor }
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds
        
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    @objc private func touchDown() {
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowOpacity = 0.1
        }
        animator?.startAnimation()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func touchUp() {
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.7) {
            self.transform = .identity
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowOpacity = 0.2
        }
        animator?.startAnimation()
    }
}

// MARK: - Animated Tab Bar
class AnimatedTabBar: UITabBar {
    
    private var shapeLayer: CAShapeLayer?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addShape()
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.fillColor = UIColor.systemBackground.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowRadius = 10
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
    }
    
    private func createPath() -> CGPath {
        let path = UIBezierPath()
        let centerWidth = frame.width / 2
        let height: CGFloat = 15
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: centerWidth - 50, y: 0))
        
        // Curved section
        path.addQuadCurve(to: CGPoint(x: centerWidth - 30, y: height),
                         controlPoint: CGPoint(x: centerWidth - 40, y: 0))
        
        path.addQuadCurve(to: CGPoint(x: centerWidth + 30, y: height),
                         controlPoint: CGPoint(x: centerWidth, y: height + 10))
        
        path.addQuadCurve(to: CGPoint(x: centerWidth + 50, y: 0),
                         controlPoint: CGPoint(x: centerWidth + 40, y: 0))
        
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        path.close()
        
        return path.cgPath
    }
}

// MARK: - Particle Emitter for Celebrations
class ParticleEmitter {
    
    static func createConfettiEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterCells = createConfettiCells()
        return emitter
    }
    
    private static func createConfettiCells() -> [CAEmitterCell] {
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemYellow, .systemPurple, .systemOrange
        ]
        
        return colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 10
            cell.lifetime = 10
            cell.velocity = 250
            cell.velocityRange = 100
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 1
            cell.scaleRange = 0.5
            cell.scaleSpeed = -0.1
            cell.contents = createConfettiImage(color: color).cgImage
            return cell
        }
    }
    
    private static func createConfettiImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
}

// MARK: - Loading Skeleton View
class SkeletonLoadingView: UIView {
    
    private let shimmerLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 8
        
        // Setup shimmer effect
        shimmerLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        shimmerLayer.locations = [0, 0.5, 1]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(shimmerLayer)
        
        startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
    }
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmer")
    }
    
    func stopAnimating() {
        shimmerLayer.removeAllAnimations()
    }
}

// MARK: - Custom Alert View
class CustomAlertView: UIView {
    
    enum AlertType {
        case success, warning, error, info
        
        var color: UIColor {
            switch self {
            case .success: return ThemeManager.Colors.successColor
            case .warning: return ThemeManager.Colors.warningColor
            case .error: return .systemRed
            case .info: return ThemeManager.Colors.accentColor
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "✓"
            case .warning: return "⚠️"
            case .error: return "✕"
            case .info: return "ℹ️"
            }
        }
    }
    
    static func show(message: String, type: AlertType, in view: UIView) {
        let alertView = CustomAlertView(message: message, type: type)
        view.addSubview(alertView)
        
        alertView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            alertView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            alertView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        alertView.show()
    }
    
    private let messageLabel = UILabel()
    private let iconLabel = UILabel()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    
    init(message: String, type: AlertType) {
        super.init(frame: .zero)
        setupView(message: message, type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(message: String, type: AlertType) {
        backgroundColor = type.color.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        // Add blur background
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        
        // Setup icon
        iconLabel.text = type.icon
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup message
        messageLabel.text = message
        messageLabel.font = ThemeManager.Fonts.body()
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconLabel)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        layer.borderWidth = 1
        layer.borderColor = type.color.withAlphaComponent(0.3).cgColor
    }
    
    private func show() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 100)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
        
        // Auto dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 100)
        }) { _ in
            self.removeFromSuperview()
        }
    }
} 