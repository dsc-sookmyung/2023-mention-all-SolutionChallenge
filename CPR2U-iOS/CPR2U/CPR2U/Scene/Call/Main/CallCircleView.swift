//
//  CallCircleView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//  https://cemkazim.medium.com/how-to-create-animated-circular-progress-bar-in-swift-f86c4d22f74b

import UIKit

final class CallCircleView: UIView {
    
    private let bellImageView: UIImageView = {
        let view = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light, scale: .medium)
        guard let img = UIImage(systemName: "bell", withConfiguration: config)?.withTintColor(.white).withRenderingMode(.alwaysOriginal) else { return UIImageView() }
        view.image = img
        return view
    }()
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpConstraints() {
        self.addSubview(bellImageView)
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bellImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bellImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            bellImageView.widthAnchor.constraint(equalToConstant: 40),
            bellImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createCircularPath() {
        [
            circleLayer,
            progressLayer
        ].forEach({
            layer.addSublayer($0)
        })
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40), radius: 40, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.mainRed.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 12.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.white.cgColor
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.mainRed.cgColor
        
    }
    
    func progressAnimation() {
        let duration = TimeInterval(3.0)
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
    
    func cancelProgressAnimation() {
        progressLayer.removeAnimation(forKey: "progressAnim")
    }
}
