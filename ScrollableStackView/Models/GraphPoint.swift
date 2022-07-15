//
//  GraphPoint.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/07.
//

import Foundation
import UIKit

class GraphPoint {
    let x: Float
    let y: Float
    var color: UIColor
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    init(x: Float, y: Float, color: UIColor) {
        self.x = x
        self.y = y
        self.color = color
    }
}
