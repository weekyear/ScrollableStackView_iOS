//
//  ScrollableStackView.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/06.
//

import Foundation
import UIKit

class ScrollableStackView: UIScrollView, UIScrollViewDelegate {
    private let calculator = LayoutCalculator()
    
    // MARK: PinchGesture
    private var targetIndex: Int = 0
    private var lineGapBegan: CGFloat = 0
    private var prevXOfTargetIndex: Float = 0.0
    private var isPinchZoom: Bool = false
    
    // stack안에 들어갈 Slide 수
    private let stackSlideNum = 3
    
    private var curScale = 1.0
    
    private var slideViews: [SlideView] {
        get {
            return stackView.arrangedSubviews as! [SlideView]
        }
    }
    
    private let stackView: UIStackView = {
        let view: UIStackView = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        view.backgroundColor = .green
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator = true
        self.bounces = false
        
        initStackView()
        initArrangedSubView()
        addGesture()
    }
    
    private func initStackView() {
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
        let colors: [UIColor] = [.yellow, .green, .cyan]
        
        colors.enumerated().forEach { (index, color) in
            let subView = SlideView(slideNum: index, color: color, calculator: calculator)
            stackView.addArrangedSubview(subView)
            subView.setConstraint(self)
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

    // MARK: UIScrollViewDelegate 구현
extension ScrollableStackView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isPinchZoom) {
            scroll(scrollView)
        }
    }
    
    private func scroll(_ scrollView: UIScrollView) {
        let scrollX = scrollView.contentOffset.x
        let slideWidth = calculator.slideWidth
        
        let isMoveToLeft = scrollX < slideWidth - scrollView.frame.width && slideViews[0].slideNum != 0
        let isMoveToRight = scrollX > slideWidth * 2 && slideViews.last?.slideNum != calculator.totalStackNum - 1
        
        if isMoveToLeft {
            moveLeftSlideToRight(scrollView)
        } else if isMoveToRight {
            moveRightSlideToLeft(scrollView)
        }
    }
    
    private func moveLeftSlideToRight(_ scrollView: UIScrollView) {
        slideViews.last?.initSlideValue(slideNum: (slideViews.last?.slideNum ?? 0) - stackSlideNum)
        changeStackPosition(from: slideViews.endIndex - 1, to: 0)
        scrollView.contentOffset = CGPoint(x: max(scrollView.contentOffset.x + slideViews[0].frame.width, 0), y: 0)
    }
    
    private func moveRightSlideToLeft(_ scrollView: UIScrollView) {
        slideViews.first?.initSlideValue(slideNum: (slideViews.first?.slideNum ?? 0) + stackSlideNum)
        changeStackPosition(from: 0, to: slideViews.endIndex - 1)
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - slideViews[0].frame.width, y: 0)
    }
    
    private func changeStackPosition(from: Int, to: Int) {
        let curSlideView = slideViews[from]
        stackView.removeArrangedSubview(curSlideView)
        stackView.insertArrangedSubview(curSlideView, at: to)
        stackView.setNeedsLayout()
//        curSlideView.setNeedsDisplay()
        curSlideView.render()
    }
}

extension ScrollableStackView {
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            let pinchPoint: CGPoint = sender.location(in: self)
            let startX = slideViews[0].startX
            targetIndex = calculator.findIndexByX(clickX: Float(startX + pinchPoint.x))
            prevXOfTargetIndex = calculator.findXByIndex(index: targetIndex) - Float(startX) - Float(contentOffset.x)
            isPinchZoom = true
            break
        case .changed:
            let isZoomOut = curScale - sender.scale > 0.05
            let isZoomIn = curScale - sender.scale < -0.05
            let maxLineGapSize: Float = 20.0
            let minLineGapSize: Float = 2.0
            
            if ((isZoomIn && calculator.lineGapSize <= maxLineGapSize) || (isZoomOut && calculator.lineGapSize > minLineGapSize)) {
                let scaleWeight = 1.0
                let signZoom = isZoomIn ? 1.0 : -1.0
                curScale += scaleWeight * signZoom
                calculator.lineGapSize -= Float(curScale)
                calculator.lineGapSize = max(minLineGapSize, calculator.lineGapSize)
                calculator.lineGapSize = min(maxLineGapSize, calculator.lineGapSize)
                calculator.calculateForRedraw()
                
                reinitArrangedSubView(xOfTargetIndex: CGFloat(calculator.findXByIndex(index: targetIndex)))
                setOffsetXOfScroll()
            }
            
            break
        case .ended:
            scroll(self)
            setOffsetXOfScroll()
            isPinchZoom = false
            break
        default:
            break
        }
    }
    
    private func setOffsetXOfScroll() {
        var offsetXOfScroll = calculator.findXByIndex(index: targetIndex) - Float(slideViews[0].startX) - prevXOfTargetIndex
        offsetXOfScroll = max(offsetXOfScroll, 0.0)
        offsetXOfScroll = min(offsetXOfScroll, Float(calculator.drawWidth - bounds.width - slideViews[0].startX))
        self.contentOffset = CGPoint(x: Double(offsetXOfScroll), y: 0.0)
    }
    
    private func reinitArrangedSubView(xOfTargetIndex: CGFloat) {
        let colors: [UIColor] = [.yellow, .green, .cyan]
        let targetSlideIndex = Int(xOfTargetIndex / calculator.slideWidth)
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        colors.enumerated().forEach { (index, color) in
            var slideNum = targetSlideIndex + index
            
            if (targetSlideIndex == calculator.totalStackNum - 1) {
                slideNum -= 2
            } else if (targetSlideIndex != 0) {
                slideNum -= 1
            }
            
            let subView = SlideView(slideNum: slideNum, color: color, calculator: calculator)
            stackView.addArrangedSubview(subView)
            subView.setConstraint(self)
        }
    }
    
    @objc func handleTapGesture(_ sender: UIPinchGestureRecognizer) {
        print("tap")
    }
}
