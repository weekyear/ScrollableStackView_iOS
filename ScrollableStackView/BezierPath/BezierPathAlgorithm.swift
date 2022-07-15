//
//  BezierPathAlgorithm.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/06.
//

import Foundation
import UIKit

internal extension UIBezierPath {
    
    //MARK: - 3차 베지에 곡선
    convenience init?(cubicCurve points: [CGPoint]) {
        guard points.count >= 2 else { return nil }
        
        self.init()
        
        let p1 = points[0]
        move(to: p1)
        
        let curveSegments: [CurvedSegment] = UIBezierPath.controlPointsFrom(points: points)
        
        for i in 1..<points.count {
            let p2 = points[i]
            addCurve(
                to: p2,
                controlPoint1: curveSegments[i-1].controlPoint1,
                controlPoint2: curveSegments[i-1].controlPoint2
            )
        }
    }
    
    static func controlPointsFrom(points: [CGPoint]) -> [CurvedSegment] {
        var result: [CurvedSegment] = []
        
        let delta: CGFloat = 0.3 // The value that help to choose temporary control points.
        
        // Calculate temporary control points, these control points make Bez#imageLiteral(resourceName: "simulator_screenshot_85E1BD36-B3F4-4068-85B3-216C62905E3C.png")ier segments look straight and not curving at all
        
        for i in 1..<points.count {
            let A = CGPoint(x: points[i-1].x, y: points[i-1].y)
            let B = CGPoint(x: points[i].x, y: points[i].y)
            let controlPoint1 = CGPoint(x: A.x + delta*(B.x-A.x), y: A.y + delta*(B.y - A.y))
            let controlPoint2 = CGPoint(x: B.x - delta*(B.x-A.x), y: B.y - delta*(B.y - A.y))
            let curvedSegment = CurvedSegment(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            result.append(curvedSegment)
        }
        
        // 점이 하나라면 곡선이 그려지지 못하므로 result를 바로 리턴시킨다.
        if (points.count) == 1 {
            return result
        }
        
        // Calculate good control points
        for i in 1..<points.count - 1{
            /// A temporary control point
            let M = result[i-1].controlPoint2
            
            /// A temporary control point
            let N = result[i].controlPoint1
            
            /// central point
            let A = CGPoint(x: points[i].x, y: points[i].y)
            
            /// Reflection of M over the point A
            let MM = CGPoint(x: 2 * A.x - M.x, y: 2 * A.y - M.y)
            
            /// Reflection of N over the point A
            let NN = CGPoint(x: 2 * A.x - N.x, y: 2 * A.y - N.y)
            
            result[i].controlPoint1 = CGPoint(x: (MM.x + N.x)/2, y: (MM.y + N.y)/2)
            result[i-1].controlPoint2 = CGPoint(x: (NN.x + M.x)/2, y: (NN.y + M.y)/2)
        }
        
        return result
    }
    
}

public extension UIBezierPath {
    
    convenience init?(plain points:[CGPoint]) {
        guard points.count >= 2 else {return nil}
        
        self.init()
        
        let p1 = points[0]
        move(to: p1)
        
        for i in 1..<points.count {
            addLine(to: points[i])
        }
    }
}

public struct CurvedSegment {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

