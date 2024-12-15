import UIKit


protocol ProfileGradientHelperProtocol {
    func configureGradientLayer(_ layer: CAGradientLayer, for view: UIView)
    func startGradientAnimation(for imageView: UIImageView)
    func stopGradientAnimation(for imageView: UIImageView)
    func addAvatarGradientAnimation(for imageView: UIImageView)
    func removeAvatarGradientAnimation(from imageView: UIImageView)
}


class ProfileGradientHelper: ProfileGradientHelperProtocol {
    
    // Настройка слоя градиента для ImageView
     func configureGradientLayer(_ layer: CAGradientLayer, for view: UIView) {
        layer.colors = [
            UIColor(named: "GradientGreyColor1")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor2")?.cgColor ?? UIColor.systemGray.cgColor,
            UIColor(named: "GradientGreyColor3")?.cgColor ?? UIColor.systemGray.cgColor
        ]
        let gradientPadding: CGFloat = 8
        
        let adjustedFrame = view.bounds.insetBy(dx: -gradientPadding, dy: -gradientPadding)
        layer.frame = adjustedFrame
        layer.cornerRadius = view.layer.cornerRadius + gradientPadding
            view.layer.addSublayer(layer)
        
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        view.layer.addSublayer(layer)
    }
    
    // Запуск анимации градиента
    func startGradientAnimation(for imageView: UIImageView) {
        guard let gradientLayer = imageView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer else {
            return
        }
        
        // Анимация движения градиента
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0]
        animation.toValue = [1.0, 1.0]
        animation.duration = 2.0
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    // Остановка анимации градиента
    func stopGradientAnimation(for imageView: UIImageView) {
        guard let gradientLayer = imageView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer else {
            return
        }
        
        // Останавливаем анимацию
        gradientLayer.removeAnimation(forKey: "gradientAnimation")
    }
    
    // Добавление анимации градиента для аватара
    func addAvatarGradientAnimation(for imageView: UIImageView) {
        // Настройка и запуск анимации градиента
        let gradientLayer = CAGradientLayer()
        configureGradientLayer(gradientLayer, for: imageView)
        startGradientAnimation(for: imageView)
    }
    
    // Удаление анимации градиента с аватара
    func removeAvatarGradientAnimation(from imageView: UIImageView) {
        // Остановка анимации и удаление слоя
        stopGradientAnimation(for: imageView)
        if let gradientLayer = imageView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.removeFromSuperlayer()
        }
    }
}
