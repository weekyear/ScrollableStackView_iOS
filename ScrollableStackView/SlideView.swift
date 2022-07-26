//
//  SlideView.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/08.
//

import Foundation
import UIKit

class SlideView: UIView {
    // 전체 슬라이드에서 몇 번째 슬라이드
    var slideNum: Int = 0
    // DrawWidth에서 Slide의 첫 x좌표
    var startX: CGFloat = 0.0
    // DrawWidth에서 Slide의 마지막 x좌표
    var endX: CGFloat = 0.0
    //
    var firstIndex: Int = 0
    var finalIndex: Int = 0
    private var bezierPath: UIBezierPath? = nil
    
    var graph: ScrollableStackView!
    
    private var calculator: LayoutCalculator {
        return graph.calculator
    }
    
    private var config: GraphConfig {
        return graph.config
    }
    
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    init(slideNum: Int, graph: ScrollableStackView) {
        super.init(frame: .zero)
        
        self.graph = graph
        calculateSlideInfo(slideNum: slideNum)
    }
    
    func calculateByPinch(slideNum: Int) {
        calculateSlideInfo(slideNum: slideNum)
        setConstraint()
    }
    
    func calculateSlideInfo(slideNum: Int) {
        self.slideNum = slideNum
        
        startX = CGFloat(slideNum) * calculator.slideWidth
        endX = CGFloat((slideNum + 1)) * calculator.slideWidth
        setFisrtAndFinalIndex()
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
    
    func setConstraint() {
        translatesAutoresizingMaskIntoConstraints = false
        if (widthConstraint != nil || heightConstraint != nil) {
            NSLayoutConstraint.deactivate([
                widthConstraint,
                heightConstraint
            ])
        }
        
        widthConstraint = widthAnchor.constraint(equalToConstant: calculator.slideWidth)
        heightConstraint = heightAnchor.constraint(equalTo: graph.heightAnchor)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint
        ])
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            drawDataPath(using: ctx)
        }
    }
    
    private func drawDataPath(using ctx: CGContext) {
        calculator.graphPointsList.enumerated().forEach { i, graphPoints in
            let currentColor: UIColor = .blue
            let blurSize = 12.0
            ctx.setShadow(offset: CGSize(width: 0.0, height: blurSize - 2.0),
                          blur: blurSize,
                          color: currentColor.cgColor)

            if (graphPoints.count > 1) {
                let filteredGraphPoints = Array(graphPoints[firstIndex...finalIndex])
                
                // Index 확인을 위한 코드, 이후에 지워야 함.
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
