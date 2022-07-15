//
//  SlideView.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/08.
//

import Foundation
import UIKit

class SlideView: UIView {
    var slideNum: Int = 0
    var startX: CGFloat = 0.0
    var endX: CGFloat = 0.0
    var firstIndex: Int = 0
    var finalIndex: Int = 0
    private var bezierPath: UIBezierPath? = nil
    
    private var pathLayer: PathLayer?
    
    var calculator: LayoutCalculator!
    
    private let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.textAlignment = .center
        label.font = label.font.withSize(48)
        return label
    }()
    
    init(slideNum: Int, color: UIColor, calculator: LayoutCalculator) {
        super.init(frame: .zero)
        
        self.backgroundColor = color
        self.calculator = calculator
    
        initSlideValue(slideNum: slideNum)
        
        let pathLayer = PathLayer(slideView: self)
        pathLayer.contentsScale = UIScreen.main.scale
        pathLayer.drawsAsynchronously = true
        pathLayer.setNeedsDisplay()
        
        self.layer.addSublayer(pathLayer)
        self.pathLayer = pathLayer
    }
    
    override func layoutSublayers(of layer: CALayer) {
        self.pathLayer?.frame = self.bounds
    }
    
    func initSlideValue(slideNum: Int) {
        self.slideNum = slideNum
        startX = CGFloat(slideNum) * calculator.slideWidth
        endX = CGFloat((slideNum + 1)) * calculator.slideWidth
        
        if calculator != nil {
            setFisrtAndFinalIndex()
        }
        label.text = String(slideNum)
    }
    
    private func setNumLabel() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        label.text = String(slideNum)
    }
    
    private func setFisrtAndFinalIndex() {
        firstIndex = calculator.findIndexByX(clickX: Float(startX))
        firstIndex = max(firstIndex - 5, 0)
        finalIndex = calculator.findIndexByX(clickX: Float(endX))
        finalIndex = min(finalIndex + 5, calculator.graphPointsList[0].endIndex - 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraint(_ parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: calculator.slideWidth),
            heightAnchor.constraint(equalTo: parentView.heightAnchor)
        ])
    }
    
    func render() {
//        self.pathLayer?.removeFromSuperlayer()
//
//        let pathLayer = PathLayer(slideView: self)
//        pathLayer.contentsScale = UIScreen.main.scale
//        pathLayer.drawsAsynchronously = true
//        pathLayer.setNeedsDisplay()
//
//        self.layer.addSublayer(pathLayer)
//        self.pathLayer = pathLayer
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            drawDataPath(using: ctx)
        }
    }
    
    private func drawDataPath(using ctx: CGContext) {
        calculator?.graphPointsList.enumerated().forEach { i, graphPoints in
            let currentColor: UIColor = .blue
            let blurSize = 12.0
            ctx.setShadow(offset: CGSize(width: 0.0, height: blurSize - 2.0),
                          blur: blurSize,
                          color: currentColor.cgColor)

            if (graphPoints.count > 1) {
                let filteredGraphPoints = Array(graphPoints[firstIndex...finalIndex])
                
                filteredGraphPoints.enumerated().forEach { (index, graphpoint) in
                    if (firstIndex + index) % 10 == 0 {
                        drawText(text: "\(firstIndex + index)", graphPoint: graphpoint)
                    }
                }

                let cgPoints = filteredGraphPoints.map { graphPoint in
                    CGPoint(x: CGFloat(graphPoint.x) - startX, y: CGFloat(graphPoint.y))
                }
                bezierPath = UIBezierPath(cubicCurve: cgPoints)
                guard bezierPath != nil else { return }
                
                ctx.setStrokeColor(currentColor.cgColor)
                ctx.setLineWidth(1.0)
                ctx.addPath(bezierPath!.cgPath)
                ctx.strokePath()
            }
        }
    }
    
    private func drawText(text: String, graphPoint: GraphPoint) {
        let font = UIFont.systemFont(ofSize: 10)
        let string = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        string.draw(at: CGPoint(x: Int(graphPoint.x - Float(startX) - Float(string.length) / 2.0), y: Int(graphPoint.y)))
    }
}

