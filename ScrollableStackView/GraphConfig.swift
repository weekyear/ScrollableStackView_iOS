//
//  GraphConfig.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/25.
//

import Foundation
import UIKit

open class GraphConfig {
    public init() { }
    
    // 그래프에 그려지는 점의 크기
    public var pointSize = 8.0

    // 그래프에 그려지는 선의 굵기
    public var lineSize = 2.5

    // paddings : [상, 하, 좌, 우] 패딩 값
    public var paddings: Array<Float> = [10.0, 20.0, 30.0, 400.0]
    
    let maxLineGapSize: Float = 20.0
    let minLineGapSize: Float = 5.0
    
    var dataMinValue: Float = 0
    var dataMaxValue: Float = 100
    
    private var _dataPointsList: [[Float]] = []
    var dataPointsList: [[Float]] {
        get { return _dataPointsList }
        set(newList) {
            dataMinValue = newList.map { array in array.min()! }.min()!
            dataMaxValue = newList.map { array in array.max()! }.max()!
            
            _dataPointsList = newList
        }
    }
}

