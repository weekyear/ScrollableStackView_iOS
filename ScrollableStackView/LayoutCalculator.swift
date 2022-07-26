//
//  LayoutCalculator.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/07.
//

import Foundation
import UIKit

class LayoutCalculator {
    var drawWidth: CGFloat = 100.0
    var drawHeight: CGFloat = 100.0
    
    private var graph: ScrollableStackView!
    
    private var config: GraphConfig {
        return graph.config
    }
    
    private var sectionMinY: CGFloat {
        return CGFloat(config.paddings[0])
    }
    
    private var sectionMaxY: CGFloat {
        return graph.frame.height - CGFloat(config.paddings[1])
    }
    
    private var sectionMinValue: Float {
        return Float(Int(config.dataMinValue))
    }
    
    private var sectionMaxValue: Float {
        if config.dataMaxValue.remainder(dividingBy: 0) == 0 {
            return Float(Int(config.dataMaxValue))
        } else {
            return Float(Int(config.dataMaxValue) + 1)
        }
    }
    
    var _lineGapSize: Float = 10.0
    var lineGapSize: Float {
        get {
            return _lineGapSize
        }
        set (newVal) {
            _lineGapSize = max(config.minLineGapSize, newVal)
            _lineGapSize = min(config.maxLineGapSize, newVal)
        }
    }
    
    private var _slideWidth: CGFloat = 0.0
    var slideWidth: CGFloat {
        get {
            if (_slideWidth == 0.0) {
                _slideWidth = max(drawWidth, graph.bounds.width) / CGFloat(totalSlideNum)
            }
            return _slideWidth
        }
    }
    var totalSlideNum = 3
    
    var graphPointsList: Array<Array<GraphPoint>> = []
    
    init(graph: ScrollableStackView) {
        self.graph = graph
    }
    
    func calculate() {
        initGraphPointsList()
        calculateForDraw()
    }
    
    private func calculateForDraw() {
        initDrawWidth()
        initTotalScreenNum()
    }
    
    private func initDrawWidth() {
        drawWidth = CGFloat(config.paddings[2] + lineGapSize * Float((config.dataPointsList[0].count - 1)) + config.paddings[3])
    }
    
    private func initTotalScreenNum() {
        let isMoreThanStackSlideNum = drawWidth > graph.frame.width * 2 * CGFloat(graph.slideViewNum)
        
        if isMoreThanStackSlideNum {
            totalSlideNum = (Int(drawWidth) / (Int(graph.frame.width) * 2)) + 1
        } else {
            totalSlideNum = graph.slideViewNum
        }
    }
    
    // 핀치 줌 될때 새로 draw할 때 필요한 재계산을 수행
    func calculateForRedraw(newLineGap: CGFloat) {
        setNewLineGapSize(newLineGap: newLineGap)
        // slideWidth를 다시 계산하게 하기 위한 조치
        _slideWidth = 0.0
        
        calculateForDraw()
        updateGraphPointsList()
    }
    
    private func setNewLineGapSize(newLineGap: CGFloat) {
        lineGapSize = Float(newLineGap)
        lineGapSize = max(config.minLineGapSize, lineGapSize)
        lineGapSize = min(config.maxLineGapSize, lineGapSize)
    }
    
    // Config의 DataList를 GraphPoints로 변환
    private func initGraphPointsList() {
        graphPointsList.removeAll()
        config.dataPointsList.forEach { dataPoints in
            var graphPoints: [GraphPoint] = []
            dataPoints.enumerated().forEach { (index, data) in
                let graphPoint = GraphPoint(x: findXByIndex(index: index), y: calculateYOfData(measure: data), color: .darkGray)
                graphPoints.append(graphPoint)
            }
            graphPointsList.append(graphPoints)
        }
    }
    
    // Line Gap이 변경 됨에 따라 GraphPointsList를 새로 반환
    private func updateGraphPointsList() {
        var _graphPointsList: Array<Array<GraphPoint>> = []
        for graphPoints in graphPointsList {
            var _graphPoints: Array<GraphPoint> = []
            graphPoints.enumerated().forEach { (i, graphPoint) in
                let _graphPoint = GraphPoint(x: findXByIndex(index: i), y: graphPoint.y, color: .darkGray)
                _graphPoints.append(_graphPoint)
            }
            _graphPointsList.append(_graphPoints)
        }
        
        graphPointsList.removeAll()
        _graphPointsList.forEach { _graphPoints in
            graphPointsList.append(_graphPoints)
        }
    }
    
    private func calculateYOfData(measure: Float) -> Float {
        return Float(sectionMinY) + Float(sectionMaxY - sectionMinY) * (measure - sectionMinValue) / (sectionMaxValue - sectionMinValue)
    }
    
    // 입력된 인덱스의 x 좌표를 반환
    func findXByIndex(index: Int) -> Float {
        return config.paddings[2] + lineGapSize * Float(index)
    }
    
    // 클릭한 x 좌표에 가까운 인덱스를 반환
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
