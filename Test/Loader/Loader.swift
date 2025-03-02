import UIKit

final class LoaderView: UIView {
    
    private let logoLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoader()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoader()
    }
    
    private func setupLoader() {
        guard let vkImage = UIImage(named: "vkIcon")?.cgImage else {
            return
        }
        
        logoLayer.contents = vkImage
        logoLayer.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        logoLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        logoLayer.cornerRadius = 10
        logoLayer.masksToBounds = true
        
        layer.addSublayer(logoLayer)
    }
    
    func startAnimation() {
        guard logoLayer.animation(forKey: "pulseAnimation") == nil else { return }
        
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.4
        pulse.duration = 0.4
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        logoLayer.add(pulse, forKey: "pulseAnimation")
    }
    
    func stopAnimation() {
        logoLayer.removeAnimation(forKey: "pulseAnimation")
    }
}
