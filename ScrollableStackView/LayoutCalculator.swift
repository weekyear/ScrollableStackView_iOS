//
//  LayoutCalculator.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/07.
//

import Foundation
import UIKit

class LayoutCalculator {
    let dataNum = 3000
    var drawWidth: CGFloat = 100.0
    let xOfFirstLine: Float = 20.0
    let paddingRight: Float = 20.0
    let maxLineGapSize: Float = 20.0
    let minLineGapSize: Float = 2.0
    
    var _lineGapSize: Float = 20.0
    var lineGapSize: Float {
        get {
            return _lineGapSize
        }
        set (newVal) {
            _lineGapSize = max(2.0, newVal)
            _lineGapSize = min(20.0, newVal)
        }
    }
    
    private var _slideWidth: CGFloat = 0.0
    var slideWidth: CGFloat {
        get {
            if (_slideWidth == 0.0) {
                _slideWidth = max(drawWidth, UIScreen.main.bounds.width) / CGFloat(totalStackNum)
            }
            return _slideWidth
        }
    }
    var totalStackNum = 3
    private let defalutSlideNum = 3
    
    var graphPointsList: Array<Array<GraphPoint>> = []
    
    init() {
        initDrawWidth()
        initTotalScreenNum()
        initGraphPointsList()
    }
    
    private func initDrawWidth() {
        drawWidth = CGFloat(xOfFirstLine + lineGapSize * Float((dataNum - 1)) + paddingRight)
    }
    
    private func initTotalScreenNum() {
        let isMoreThanStackSlideNum = drawWidth > UIScreen.main.bounds.width * 2 * CGFloat(defalutSlideNum)
        
        if isMoreThanStackSlideNum {
            totalStackNum = (Int(drawWidth) / (Int(UIScreen.main.bounds.width) * 2)) + 1
        } else {
            totalStackNum = defalutSlideNum
        }
    }
    
    func calculateForRedraw() {
        initDrawWidth()
        initTotalScreenNum()
        updateGraphPointsList()
    }
    
    private func initGraphPointsList() {
        graphPointsList.removeAll()
        for _ in 0...0 {
            var graphPoints: Array<GraphPoint> = []
            for i in 0...(dataNum - 1) {
                let posX = findXByIndex(index: i)
                let posY = Double.random(in: 5.0...250.0)
                let graphPoint = GraphPoint(x: Float(posX), y: Float(posY), color: .darkGray)
                graphPoints.append(graphPoint)
            }
            graphPointsList.append(graphPoints)
        }
    }
    
    private func updateGraphPointsList() {
        var _graphPointsList: Array<Array<GraphPoint>> = []
        for graphPoints in graphPointsList {
            var _graphPoints: Array<GraphPoint> = []
            graphPoints.enumerated().forEach { (i, graphPoint) in
                let posX = findXByIndex(index: i)
                let posY = graphPoint.y
                let _graphPoint = GraphPoint(x: Float(posX), y: Float(posY), color: .darkGray)
                _graphPoints.append(_graphPoint)
            }
            _graphPointsList.append(_graphPoints)
        }
        
        graphPointsList.removeAll()
        _graphPointsList.forEach { _graphPoints in
            graphPointsList.append(_graphPoints)
        }
    }
    
    func findXByIndex(index: Int) -> Float {
        return xOfFirstLine + lineGapSize * Float(index)
    }
    
    func findIndexByX(clickX: Float) -> Int {
        if (graphPointsList.isEmpty) {
            return 0
        }
        
        // 현재 클릭된 좌표 x와 가까운 인덱스 탐색
        var left = 0
        var right = graphPointsList[0].count - 1
        var mid = (left + right) / 2

        while (left < right) {
            if (graphPointsList[0][mid].x < clickX) {
                left = mid + 1
            } else {
                right = mid - 1
            }
            mid = (left + right) / 2
        }

        // mid 인덱스의 x값과 mid 앞 인덱스의 x값, mid 뒤 인덱스의 x값들과 클릭된 x값의 차이를 각각 계산
        let prevMidXGap: Float = mid > 0 ? abs(graphPointsList[0][mid - 1].x - clickX) : 0xffffff
        let midXGap: Float = abs(graphPointsList[0][mid].x - clickX)
        let nextMidXGap: Float = mid < graphPointsList[0].count - 1 ? abs(graphPointsList[0][mid + 1].x - clickX) : 0xffffff

        // 가장 차이가 적은 인덱스 값을 반환

        // 가장 차이가 적은 인덱스 값을 반환
        if (prevMidXGap < midXGap) {
            return mid - 1
        } else if (nextMidXGap < midXGap) {
            return mid + 1
        } else {
            return mid
        }
    }
}
