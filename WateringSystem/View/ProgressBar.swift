//
//  ProgressBar.swift
//  WateringSystem
//
//  Created by Yuanrong Han on 3/22/21.
//

import Foundation
import UIKit

class CircularProgressBar: UIView {
    var color: UIColor? = .systemBlue {
        didSet { setNeedsDisplay() }
    }
    var ringWidth: CGFloat = 15

    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()

    var label : UILabel = {
        let l = UILabel()
        l.text = "N/A"
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .label
        l.textAlignment = .center
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupLayers()
        setupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        setupLayers()
        setupLabel()
    }

    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = UIColor.clear.cgColor
        backgroundMask.strokeColor = UIColor.lightGray.cgColor
        layer.addSublayer(backgroundMask)

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(progressLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
    
    }

    private func setupLabel() {
        self.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.transform = CGAffineTransform(rotationAngle: CGFloat(CGFloat.pi / 2))
    }
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = color?.cgColor
    }
}
