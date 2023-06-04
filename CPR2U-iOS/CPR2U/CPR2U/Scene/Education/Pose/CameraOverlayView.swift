// Copyright 2021 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================
//
//  CameraOverlayView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/19.
//

import UIKit
import os

/// Custom view to visualize the pose estimation result on top of the input image.
class CameraOverlayView: UIImageView {
    
    var correctAngle: Int = 0
    var incorrectAngle: Int = 0
    var compressionRate: Int = 0
    var pressDepth: Int = 0
    var pressCount: Int = 0
    private var maxHeight: CGFloat = 0
    private var avgMaxHeight: CGFloat = 0
    private var minHeight: CGFloat = 0
    private var avgMinHeight: CGFloat = 0
    private var avgDepth: CGFloat = 0
    private var beforeWrist: CGFloat = 0
    private var increased: Bool = true
    private var wristList: [CGFloat] = []
    
    var flag: Bool = false
    required init() {
        super.init(frame: CGRect.zero)
        
        self.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Visualization configs
    private enum Config {
        static let dot = (radius: CGFloat(5), color: UIColor.orange)
    }
    
    /// List of lines connecting each part to be visualized.
    private static let lines = [
        (from: BodyPart.leftWrist, to: BodyPart.leftElbow),
        (from: BodyPart.leftElbow, to: BodyPart.leftShoulder),
        (from: BodyPart.leftShoulder, to: BodyPart.rightShoulder),
        (from: BodyPart.rightShoulder, to: BodyPart.rightElbow),
        (from: BodyPart.rightElbow, to: BodyPart.rightWrist),
        (from: BodyPart.leftShoulder, to: BodyPart.leftHip),
        (from: BodyPart.leftHip, to: BodyPart.rightHip),
        (from: BodyPart.rightHip, to: BodyPart.rightShoulder),
        (from: BodyPart.leftHip, to: BodyPart.leftKnee),
        (from: BodyPart.leftKnee, to: BodyPart.leftAnkle),
        (from: BodyPart.rightHip, to: BodyPart.rightKnee),
        (from: BodyPart.rightKnee, to: BodyPart.rightAnkle),
    ]
    
    /// CGContext to draw the detection result.
    var context: CGContext!
    
    /// Draw the detected keypoints on top of the input image.
    ///
    /// - Parameters:
    ///     - image: The input image.
    ///     - person: Keypoints of the person detected (i.e. output of a pose estimation model)
    func draw(at image: UIImage, person: Person) {
        if context == nil {
            UIGraphicsBeginImageContext(image.size)
            guard let context = UIGraphicsGetCurrentContext() else {
                fatalError("set current context faild")
            }
            self.context = context
        }
        guard let strokes = strokes(from: person) else { return }
        
        if flag == true {
            measureCprRate(person: person)
            measureElbowDegree(person: person)
        }   
        
        image.draw(at: .zero)
        context.setLineWidth(Config.dot.radius)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.strokePath()
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
        self.image = newImage
    }
    
    /// Draw the dots (i.e. keypoints).
    ///
    /// - Parameters:
    ///     - context: The context to be drawn on.
    ///     - dots: The list of dots to be drawn.
    private func drawDots(at context: CGContext, dots: [CGPoint]) {
        for dot in dots {
            let dotRect = CGRect(
                x: dot.x - Config.dot.radius / 2, y: dot.y - Config.dot.radius / 2,
                width: Config.dot.radius, height: Config.dot.radius)
            let path = CGPath(
                roundedRect: dotRect, cornerWidth: Config.dot.radius, cornerHeight: Config.dot.radius,
                transform: nil)
            context.addPath(path)
        }
    }
    
    /// Generate a list of strokes to draw in order to visualize the pose estimation result.
    ///
    /// - Parameters:
    ///     - person: The detected person (i.e. output of a pose estimation model).
    private func strokes(from person: Person) -> Strokes? {
        var strokes = Strokes(dots: [], lines: [])
        // MARK: Visualization of detection result
        var bodyPartToDotMap: [BodyPart: CGPoint] = [:]
        for (index, part) in BodyPart.allCases.enumerated() {
            if part == .rightAnkle {
                
            }
            let position = CGPoint(
                x: person.keyPoints[index].coordinate.x,
                y: person.keyPoints[index].coordinate.y)
            bodyPartToDotMap[part] = position
            strokes.dots.append(position)
        }
        
        do {
            try strokes.lines = CameraOverlayView.lines.map { map throws -> Line in
                guard let from = bodyPartToDotMap[map.from] else {
                    throw VisualizationError.missingBodyPart(of: map.from)
                }
                guard let to = bodyPartToDotMap[map.to] else {
                    throw VisualizationError.missingBodyPart(of: map.to)
                }
                return Line(from: from, to: to)
            }
        } catch VisualizationError.missingBodyPart(let missingPart) {
            os_log("Visualization error: %s is missing.", type: .error, missingPart.rawValue)
            return nil
        } catch {
            os_log("Visualization error: %s", type: .error, error.localizedDescription)
            return nil
        }
        return strokes
    }
    
    private func measureCprRate(person: Person) {
        var wrist: CGPoint!
        
        // Calculate for person with accuracy greater than 0.4
        if person.score > 0.4 {
            for point in person.keyPoints {
                switch point.bodyPart {
                case .leftWrist:
                    wrist = point.coordinate
                default:
                    break
                }
            }
            print(wrist.y)
            
            pressCount = wristList.count
            
            print("최소 평균 \(avgMinHeight)")
            print("최대 평균 \(avgMaxHeight)")
            
            // If the wrist height is decreasing after an increasing curve
            if increased && beforeWrist > wrist.y + 1 {
                // Verify if it is an above-average value
                avgMaxHeight = (avgMaxHeight * CGFloat(pressCount) + wrist.y) / CGFloat(pressCount + 1)
                print("고점 이상값 \(avgMaxHeight - wrist.y)")
                if abs(avgMaxHeight - wrist.y) < 50 {
                    // If it is not considered an outlier, register the peak
                    increased = false
                    maxHeight = beforeWrist
                    print("평균 \(avgMaxHeight) 고점 \(maxHeight)")
                }
            }
            
            // If the wrist height is increasing after a decreasing curve
            else if !increased && beforeWrist < wrist.y - 1 {
                // Verify if it is an above-average value
                avgMinHeight = (avgMinHeight * CGFloat(pressCount) + wrist.y) / CGFloat(pressCount + 1)
                print("저점 이상값 \(avgMinHeight - wrist.y)")
                if abs(avgMinHeight - wrist.y) < 50 {
                    // If it is not considered an outlier, register the valley
                    increased = true
                    minHeight = beforeWrist
                    print("평균 \(avgMinHeight) 저점 \(minHeight)")
                    
                    // Register depth
                    let depth = maxHeight - minHeight
                    if depth > 0 {
                        print("깊이: \(depth)")
                        wristList.append(depth)
                    }
                    
                    print("개수 \(wristList.count)")
                    print("\(wristList.last)")
                }
            }
            
            beforeWrist = wrist.y
        }
    }
    
    private func measureElbowDegree(person: Person) {
        // Extract shoulder, elbow, and wrist data from the person's joint data (currently only extracting left joint as an example)
        var shoulder: CGPoint!
        var elbow: CGPoint!
        var wrist: CGPoint!
        
        for point in person.keyPoints {
            switch point.bodyPart {
            case .leftShoulder:
                shoulder = point.coordinate
            case .leftElbow:
                elbow = point.coordinate
            case .leftWrist:
                wrist = point.coordinate
            default:
                break
            }
        }
        
        let isCorrect = shoulder.x - elbow.x < 20 && elbow.x - wrist.x < 20
        if isCorrect {
            correctAngle += 1
        } else {
            incorrectAngle += 1
        }
    }
    
    
    func getCprRateResult() -> Int {
        return pressCount / 2
    }
    
    func getArmAngleResult() -> (correct: Int, nonCorrect: Int) {
        return (correctAngle, incorrectAngle)
    }
    
    func measureIsPreparing(person: Person) -> Bool {
        var shoulderLeft: CGPoint!
        var shoulderRight: CGPoint!
        
        var elbowLeft: CGPoint!
        var elbowRight: CGPoint!
        
        var wristLeft: CGPoint!
        var wristRight: CGPoint!
        
        var hipLeft: CGPoint!
        var hipRight: CGPoint!
        
        var kneeLeft: CGPoint!
        var kneeRight: CGPoint!
        
        var ankleLeft: CGPoint!
        var ankleRight: CGPoint!
        
        for point in person.keyPoints {
            switch point.bodyPart {
            case .leftShoulder:
                shoulderLeft = point.coordinate
            case .rightShoulder:
                shoulderRight = point.coordinate
            case .leftElbow:
                elbowLeft = point.coordinate
            case .rightElbow:
                elbowRight = point.coordinate
            case .leftWrist:
                wristLeft = point.coordinate
            case .rightWrist:
                wristRight = point.coordinate
            case .leftHip:
                hipLeft = point.coordinate
            case .rightHip:
                hipRight = point.coordinate
            case .leftKnee:
                kneeLeft = point.coordinate
            case .rightKnee:
                kneeRight = point.coordinate
            case .leftAnkle:
                ankleLeft = point.coordinate
            case .rightAnkle:
                ankleRight = point.coordinate
            default:
                break
            }
        }
        
        let value: CGFloat = 25
        
        let isElbowLeftVertical = abs(shoulderLeft.x - elbowLeft.x) < value && abs(elbowLeft.x - wristLeft.x) < value
        && wristLeft.y > elbowLeft.y && elbowLeft.y > shoulderLeft.y
        let isElbowRightVertical = abs(shoulderRight.x - elbowRight.x) < value && abs(elbowRight.x - wristRight.x) < value
        && wristRight.y > elbowRight.y && elbowRight.y > shoulderRight.y
        
        let isBodyLeftVertical = shoulderLeft.x < hipLeft.x && shoulderLeft.y < hipLeft.y
        let isBodyRightVertical = shoulderRight.x < hipRight.x && shoulderRight.y < hipRight.y
        
        let isBodyLeftSeated = hipLeft.x > kneeLeft.x && kneeLeft.x < ankleLeft.x && hipLeft.x < ankleLeft.x
        && hipLeft.y < kneeLeft.y && hipLeft.y < ankleLeft.y && abs(ankleLeft.y - kneeLeft.y) < value
        let isBodyRightSeated = hipRight.x > kneeRight.x && kneeRight.x < ankleRight.x && hipRight.x < ankleRight.x
        && hipRight.y < kneeRight.y && hipRight.y < ankleRight.y && abs(ankleRight.y - kneeRight.y) < value
        
        let isElbowVertical = isElbowLeftVertical && isElbowRightVertical
        let isBodyVertical = isBodyLeftVertical && isBodyRightVertical
        let isBodySeated = isBodyLeftSeated && isBodyRightSeated
        
        if !isElbowVertical || !isBodyVertical || !isBodySeated {
            return false
        }
        
        return true
    }

    func getCprDepthResult() -> CGFloat {
        pressCount = wristList.count
        var min: CGFloat = CGFloat.greatestFiniteMagnitude
        var max: CGFloat = 0
        var depth: CGFloat = 0
        for w in wristList {
            if w < min {
                min = w
            } else if w > max {
                max = w
            }
            depth += w
        }
        return (depth - min - max) / CGFloat(pressCount - 2)
    }
}

/// The strokes to be drawn in order to visualize a pose estimation result.
fileprivate struct Strokes {
    var dots: [CGPoint]
    var lines: [Line]
}

/// A straight line.
fileprivate struct Line {
    let from: CGPoint
    let to: CGPoint
}

fileprivate enum VisualizationError: Error {
    case missingBodyPart(of: BodyPart)
}
