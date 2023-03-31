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

    private var maxHeight: CGFloat = 0
    private var minHeight: CGFloat = 0
    private var beforeWrist: CGFloat = 0
    private var increased: Bool = true
    private var wristList: [CGFloat] = []

    var correct = 0
    var nonCorrect = 0
    
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
      
    measureCprScore(person: person)
      
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
    
    private func measureCprScore(person: Person) {
        var xShoulder: CGFloat = 0
        var yShoulder: CGFloat = 0
        var xElbow: CGFloat = 0
        var yElbow: CGFloat = 0
        var xWrist: CGFloat = 0
        var yWrist: CGFloat = 0
        
        // person이 갖고 있는 관절 데이터들에서 어깨, 팔꿈치, 손목 데이터 추출 (현재 임시로 왼쪽 관절만 추출한 상태)
        person.keyPoints.forEach( { point in
            if point.bodyPart == .leftShoulder {
                xShoulder = point.coordinate.x
                yShoulder = point.coordinate.y
            } else if point.bodyPart == .leftElbow {
                xElbow = point.coordinate.x
                yElbow = point.coordinate.y
            } else if point.bodyPart == .leftWrist {
                xWrist = point.coordinate.x
                yWrist = point.coordinate.y
            }
        })
        
        // 일직선 판별
        var isCorrect = xShoulder - xElbow < 10 && xElbow - xWrist < 10
        if (isCorrect) {
            correct += 1
        } else {
            nonCorrect += 1
        }
        
        // 손목의 높이가 상승 곡선에서 꼭짓점을 찍고 하강하는 경우
        if (increased && beforeWrist > yWrist + 1) {
            increased = false
            maxHeight = yWrist
        }
        // 손목의 높이가 하강 곡선에서 꼭짓점을 찍고 상승하는 경우
        else if (!increased && beforeWrist < yWrist - 1) {
            increased = true
            minHeight = yWrist
            
            // wristList에 ${손목의 최대 높이 - 손목의 최소 높이}를 저장
            
            let num = maxHeight > minHeight ? maxHeight - minHeight : minHeight - maxHeight
            wristList.append(num)
            print(wristList.last)
            
            // wristList에 저장된 깊이 값으로 CPR 깊이가 적절한지 확인한다.
            // wristList에 저장된 값의 개수로 CPR 속도(2분 동안 CPR한 횟수)가 적절한지 확인한다.
            //  가슴압박 속도는 분당 100~120회, 깊이는 5~6㎝로 빠르고 깊게 30회 압박
            // 2분 -> 200~240회 : 추후 1분당 평균 내는것도 나쁘지 않을듯
        }

        beforeWrist = yWrist
    }
    
    func getCompressionTotalCount() -> Int {
        return wristList.count
    }
    
    func getArmAngleRate() -> (correct: Int, nonCorrect: Int) {
        return (correct, nonCorrect)
    }
    
    func getAveragePressDepth() -> CGFloat {
        let total = wristList.reduce(0){$0 + $1}
        let len = CGFloat(wristList.count)
        return total/len
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
