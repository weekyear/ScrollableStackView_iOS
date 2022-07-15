//
//  PathLayer.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/14.
//

import Foundation
import QuartzCore
import UIKit

class PathLayer: CALayer {
    private var slideView: SlideView? = nil
    private var calculator: LayoutCalculator? = nil
    private var startX: CGFloat = 0.0
    private var endX: CGFloat = 0.0
    private var firstIndex: Int = 0
    private var finalIndex: Int = 0
    private var bezierPath: UIBezierPath? = nil
    
    init(slideView: SlideView) {
        self.slideView = slideView
        self.calculator = slideView.calculator
        self.startX = slideView.startX
        self.endX = slideView.endX
        self.firstIndex = slideView.firstIndex
        self.finalIndex = slideView.finalIndex
        
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    func render(slideView: SlideView) {
        self.slideView = slideView
        self.calculator = slideView.calculator
        self.startX = slideView.startX
        self.endX = slideView.endX
        self.firstIndex = slideView.firstIndex
        self.finalIndex = slideView.finalIndex
        self.setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        drawDataPath(using: ctx)
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
