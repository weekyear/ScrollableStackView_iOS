//
//  ScrollableStackView.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/06.
//

import Foundation
import UIKit

class ScrollableStackView: UIScrollView, UIScrollViewDelegate {
    var config = GraphConfig()
    var calculator: LayoutCalculator!
    
    // MARK: PinchGesture
    // 핀치 줌의 중심이 되는 인덱스
    private var targetIndex: Int = 0
    // 핀치 줌이 시작될 때 targetIndex의 x 좌표
    private var prevXOfTargetIndex: Float = 0.0
    // 핀치 줌이 진행 중인지를 판단하는 Bool 값
    private var isPinchZoom: Bool = false
    // 핀치 줌이 시작될 때 lineGapSize
    private var lineGapBegan: CGFloat = 0
    
    // stack안에 들어갈 SlideView 수
    let slideViewNum = 3
    
    private var slideViews: [SlideView] {
        return stackView.arrangedSubviews as! [SlideView]
    }
    
    // SlideView가 옮겨지고 있는지 확인하기 위한 색상들로 실제 그래프에 활용할 때는 지우면 된다.
    let slideColorsForTest: [UIColor] = [.yellow, .green, .cyan]
    
    // SlideView가 쌓일 UIStackView
    private let stackView: UIStackView = {
        let view: UIStackView = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.calculator = LayoutCalculator(graph: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        
        self.calculator = LayoutCalculator(graph: self)
    }
    
    public func setConfig(_ config: GraphConfig) {
        self.config = config
        calculator.calculate()
        initConstraintOfStackView()
        initArrangedSubView()
        addGesture()
    }
    
    private func initConstraintOfStackView() {
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    private func initArrangedSubView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for index in 0..<slideViewNum {
            let slideView = SlideView(slideNum: index, graph: self)
            stackView.addArrangedSubview(slideView)
            slideView.setConstraint()
            
            // SlideView가 옮겨지고 있는지 확인하기 위한 색상들로 실제 그래프에 활용할 때는 지우면 된다.
            slideView.backgroundColor = slideColorsForTest[index]
        }
    }
    
    private func addGesture() {
        delegate = self
        self.addGestureRecognizer(UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinchGesture(_ :))))
        self.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture(_ :))))
    }
}

// MARK: 스크롤 (feat. UIScrollViewDelegate)
extension ScrollableStackView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (isPinchZoom) { return }
        
        scroll(scrollView)
    }
    
    private func scroll(_ scrollView: UIScrollView) {
        let scrollX = scrollView.contentOffset.x
        
        let isMoveToLeft = scrollX < calculator.slideWidth - scrollView.frame.width && slideViews[0].slideNum != 0
        let isMoveToRight = scrollX > calculator.slideWidth * 2 && slideViews.last?.slideNum != calculator.totalStackNum - 1
        
        if isMoveToLeft {
            moveRightSlideToLeft(scrollView)
        } else if isMoveToRight {
            moveLeftSlideToRight(scrollView)
        }
    }
    
    private func moveRightSlideToLeft(_ scrollView: UIScrollView) {
        slideViews.last?.initSlideNum(slideNum: (slideViews.last?.slideNum ?? 0) - slideViewNum)
        changeStackPosition(from: slideViewNum - 1, to: 0)
        scrollView.contentOffset = CGPoint(x: max(scrollView.contentOffset.x + calculator.slideWidth, 0), y: 0)
    }
    
    private func moveLeftSlideToRight(_ scrollView: UIScrollView) {
        slideViews.first?.initSlideNum(slideNum: (slideViews.first?.slideNum ?? 0) + slideViewNum)
        changeStackPosition(from: 0, to: slideViewNum - 1)
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - calculator.slideWidth, y: 0)
    }
    
    private func changeStackPosition(from: Int, to: Int) {
        let curSlideView = slideViews[from]
        stackView.removeArrangedSubview(curSlideView)
        stackView.insertArrangedSubview(curSlideView, at: to)
        stackView.setNeedsLayout()
        curSlideView.setNeedsDisplay()
    }
}

// MARK: Pinch Zoom
extension ScrollableStackView {
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            targetIndex = calculator.findIndexByX(clickX: Float(slideViews[0].startX + sender.location(in: self).x))
            prevXOfTargetIndex = calculator.findXByIndex(index: targetIndex) - Float(slideViews[0].startX) - Float(contentOffset.x)
            lineGapBegan = CGFloat(calculator.lineGapSize)
            isPinchZoom = true
            break
        case .changed:
            let newLineGap = lineGapBegan * sender.scale
            let pinchSensitivity = 0.05
            
            let isZoomOut = CGFloat(calculator.lineGapSize) - newLineGap > pinchSensitivity
            let isZoomIn = newLineGap - CGFloat(calculator.lineGapSize) > pinchSensitivity
            
            let isNotMaxLineGapSize = calculator.lineGapSize <= config.maxLineGapSize
            let isNotMinLineGapSize = calculator.lineGapSize > config.minLineGapSize
            
            if ((isZoomIn && isNotMaxLineGapSize) || (isZoomOut && isNotMinLineGapSize)) {
                calculator.calculateForRedraw(newLineGap: newLineGap)
                
                slideViews.forEach { curSlideView in
                    reinitArrangedSubView(xOfTargetIndex: CGFloat(calculator.findXByIndex(index: targetIndex)))
                }
                setOffsetXWhenPinchingZoom()
            }
            break
        case .ended:
            // Pinch Zoom이 끝났을 때 SlideView의 위치를 조정하고 Offset X를 다시 잡는다.
            scroll(self)
            setOffsetXWhenPinchingZoom()
            isPinchZoom = false
            break
        default:
            break
        }
    }
    
    // Pinch Zoom할 때 x Offset 조정
    private func setOffsetXWhenPinchingZoom() {
        var offsetX = calculator.findXByIndex(index: targetIndex) - Float(slideViews[0].startX) - prevXOfTargetIndex
        offsetX = min(offsetX, Float(calculator.drawWidth - bounds.width - slideViews[0].startX))
        offsetX = max(offsetX, 0.0)
        self.contentOffset = CGPoint(x: Double(offsetX), y: 0.0)
    }
    
    private func reinitArrangedSubView(xOfTargetIndex: CGFloat) {
        let targetSlideIndex = Int(xOfTargetIndex / calculator.slideWidth)
        
        for index in 0..<slideViewNum {
            var slideNum = targetSlideIndex + index
            
            if (targetSlideIndex == calculator.totalStackNum - 1) {
                slideNum -= 2
            } else if (targetSlideIndex != 0) {
                slideNum -= 1
            }
            
            let slideView = slideViews[index]
            slideView.reinitByPinch(slideNum: slideNum)
            slideView.setNeedsDisplay()
            
            // SlideView가 옮겨지고 있는지 확인하기 위한 색상들로 실제 그래프에 활용할 때는 지우면 된다.
            slideView.backgroundColor = slideColorsForTest[index]
        }
    }
    
    @objc func handleTapGesture(_ sender: UIPinchGestureRecognizer) {
        print("tap")
    }
}
