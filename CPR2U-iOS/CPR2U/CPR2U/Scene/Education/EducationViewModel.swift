//
//  EducationViewModel.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/20.
//

import Combine
import UIKit

struct CertificateStatus {
    let status: AngelStatus
    let leftDay: Int?
}

enum AngleStatus: String {
    case adequate = "Adequate"
    case almost = "Almost Adequate"
    case notGood = "Not Good"
    case bad = "Bad"
    
    // 팔 각도
    // CORRECT : NON-CORRECT
    // 7:3     : 40점
    // 6:4     : 25점
    // 5:5     : 10점
    // 나머지    : 0점
    var score: Int {
        switch self {
        case .adequate:
            return 40
        case .almost:
            return 25
        case .notGood:
            return 10
        case .bad:
            return 0
        }
    }
    
    var description: String {
        switch self {
        case .adequate:
            return "Good job! Very Nice angle!"
        case .almost:
            return "Almost there. Try again"
        case .notGood:
            return "Pay more attention to the angle of your arms"
        case .bad:
            return "You need some more practice"
        }
    }
    
    var isSucceed: Bool {
        switch self {
        case .adequate:
            return true
        case .almost, .notGood, .bad:
            return false
        }
    }
}

// Tensorflow 관련 수치 Notation은  추후 Refactoring 시 재검토 예정
enum CompressionRateStatus: String {
    case tooSlow = "Too Slow"
    case slow = "Slow"
    case adequate = "Adequate"
    case fast = "Fast"
    case tooFast = "Too Fast"
    case wrong = "Wrong"
    
    // 압박 속도: 40%
    // 100 - 130 : 40점
    // 80 - 150 : 25점
    // 80 아래 | 150 위 : 10점
    var score: Int {
        switch self {
        case .adequate:
            return 40
        case .slow, .fast:
            return 25
        case .tooSlow, .tooFast:
            return 10
        case .wrong:
            return 0
        }
    }
    
    var description: String {
        switch self {
        case .tooSlow:
            return "It's too slow. Press faster"
        case .slow:
            return "It's slow. Press more faster"
        case .adequate:
            return "Good job! Very Adequate"
        case .fast:
            return "It's fast. Press more slower"
        case .tooFast:
            return "It's too fast. Press slower"
        case .wrong:
            return "Something went wrong. Try Again"
        }
    }
    
    var isSucceed: Bool {
        switch self {
        case .adequate:
            return true
        case .tooSlow, .slow, .fast, .tooFast, .wrong:
            return false
        }
    }
    
}

enum PressDepthStatus: String {
    case deep = "Deep"
    case adequate = "Adequate"
    case shallow = "Slightly Shallow"
    case wrong = "Wrong"
    
    // 압박 깊이 : 20%
    // 30 이상    : 10
    // 18 - 30   : 20
    // 5 - 18   : 10
    // 0  - 5.  : 0
    var score: Int {
        switch self {
        case .deep:
            return 10
        case .adequate:
            return 20
        case .shallow:
            return 10
        case .wrong:
            return 0
        }
    }
    
    var description: String {
        switch self {
        case .deep:
            return "Press slight"
        case .adequate:
            return "Good job! Very adequate!"
        case .shallow:
            return "Press little deeper"
        case .wrong:
            return "Something went wrong. Try Again"
            
        }
    }
    
    var isSucceed: Bool {
        switch self {
        case .adequate:
            return true
        case .deep, .shallow, .wrong:
            return false
        }
    }
}

//func getArmAngleResult() -> (correct: Int, nonCorrect: Int) {
//    return (correctAngle, incorrectAngle)
//}
enum AngelStatus: Int {
    case acquired
    case expired
    case unacquired
    
    func certificationImageName(_ isBig: Bool = false) -> String {
        switch self {
        case .acquired:
            return isBig == true ? "heart_person_big" : "heart_person"
        case .expired, .unacquired:
            return isBig == true ? "person_big" : "person"
        }
    }
    
    func getStatus() -> String {
        switch self {
        case .acquired:
            return "acq_status".localized()
        case .expired:
            return "exp_status".localized()
        case .unacquired:
            return "unacq_status".localized()
        }
    }
}

enum TimerType: Int {
    case lecture = 3000
    case posture =  126
    case other = 0
}

enum EducationCourseInfo: String {
    case lecture = "course_lec"
    case quiz = "course_quiz"
    case pose = "course_pose"
    
    var name: String {
        return self.rawValue.localized()
    }
    
    var description: String {
        switch self {
        case .lecture:
            return "course_lec_des".localized()
        case .quiz:
            return "course_quiz_des".localized()
        case .pose:
            return "course_pose_des".localized()
        }
    }
    
    var timeValue: Int {
        switch self {
        case .lecture:
            return 50
        case .quiz:
            return 5
        case .pose:
            return 3
        }
    }
}
struct EducationCourse {
    var info: EducationCourseInfo
    var courseStatus = CurrentValueSubject<CourseStatus,Never>(.locked)
    
    init(course: EducationCourseInfo) {
        self.info = course
    }
}

final class EducationViewModel: AsyncOutputOnlyViewModelType {
    private let eduManager: EducationManager

    @Published private(set) var educationCourse: [EducationCourse] = [
        EducationCourse(course: .lecture),
        EducationCourse(course: .quiz),
        EducationCourse(course: .pose)
    ]
    
    private var input: Input?
    
    private var currentTimerType = TimerType.other
    var timer = Timer.publish(every: 1, on: .current, in: .common)
    
    private var compressionRate: Int?
    private var angleRate: (correct: Int?, nonCorrect: Int?)
    private var pressDepthRate: CGFloat?
    
    init() {
        eduManager = EducationManager(service: APIManager())
        Task {
            self.input = try await initialize() ?? nil
        }
    }
    
    struct Input {
        let nickname: CurrentValueSubject<String, Never>
        let angelStatus: CurrentValueSubject<Int, Never>
        let progressPercent: CurrentValueSubject<Float, Never>
        let leftDay: CurrentValueSubject<Int?, Never>
    }
    
    struct Output {
        let nickname: CurrentValueSubject<String, Never>?
        let certificateStatus: CurrentValueSubject<CertificateStatus, Never>?
        let progressPercent: CurrentValueSubject<Float, Never>?
    }
    
    func timeLimit() -> Int {
        currentTimerType.rawValue
    }
    
    func transform() async throws -> Output {
        
        let output = Task { () -> Output in
            let userInfo = try await receiveEducationStatus()
            updateInput(data: userInfo)
            
            let certificateStatus: CurrentValueSubject<CertificateStatus, Never> = {
                guard let status = AngelStatus(rawValue: input?.angelStatus.value ?? 2) else {
                    return CurrentValueSubject(CertificateStatus(status: AngelStatus.unacquired, leftDay: nil))
                }
                
                guard let leftDayNum = input?.leftDay.value else {
                    return CurrentValueSubject(CertificateStatus(status: status, leftDay: nil))
                }
                
                return CurrentValueSubject(CertificateStatus(status: status, leftDay: leftDayNum))
                
            }()
            
            return Output(nickname: input?.nickname, certificateStatus: certificateStatus, progressPercent: input?.progressPercent)
        }
        
        return try await output.value
        
        
    }
    
    func updateTimerType(vc: UIViewController) {
        if (vc as? LectureViewController) != nil {
            currentTimerType = .lecture
        } else if (vc as? PosePracticeViewController) != nil {
            currentTimerType = .posture
        }
    }
    
    func receiveEducationStatus() async throws -> UserInfo? {
        let result = Task { () -> UserInfo? in
            let eduResult = try await eduManager.getEducationProgress()
            return eduResult.data
        }
        
        let data = try await result.value
        
        return data
    }
    
    func initialize() async throws -> Input? {
        let result = Task { () -> Input? in
            let eduResult = try await self.eduManager.getEducationProgress()
            guard let data = eduResult.data else { return nil }
            
            let progressPercent = Float(data.progress_percent)
            
            let completedStatusArr = [
                data.is_lecture_completed,
                data.is_quiz_completed,
                data.is_posture_completed
            ]
            
            for idx in 0..<completedStatusArr.count {
                if completedStatusArr[idx] == 2 {
                    educationCourse[idx].courseStatus.send(.completed)
                } else {
                    educationCourse[idx].courseStatus.send(.now)
                    if idx+1 <= completedStatusArr.count - 1 {
                        for i in idx+1..<completedStatusArr.count {
                            educationCourse[i].courseStatus.send(.locked)
                        }
                        break
                    }
                }
            }
            
            for i in 0..<completedStatusArr.count {
                print("idx: \(i) \(educationCourse[i].courseStatus.value)")
            }
            return Input(nickname: CurrentValueSubject(data.nickname), angelStatus: CurrentValueSubject(data.angel_status), progressPercent: CurrentValueSubject(progressPercent), leftDay: CurrentValueSubject(data.days_left_until_expiration))
        }
        return try await result.value
    }
    
    func saveLectureProgress() async throws -> Bool {
        let result = Task {
            let eduResult = try await eduManager.saveLectureProgress(lectureId: 1)
            let userInfo = try await receiveEducationStatus()
            updateInput(data: userInfo)
            return eduResult.success
        }
        return try await result.value
    }
    
    func savePosturePracticeResult(score: Int) async throws -> Bool {
        let result = Task {
            let eduResult = try await eduManager.savePosturePracticeResult(score: score)
            let userInfo = try await receiveEducationStatus()
            updateInput(data: userInfo)
            return eduResult.success
        }
        return try await result.value
    }
    
    func saveQuizResult() async throws -> Bool {
        let result = Task {
            let eduResult = try await eduManager.saveQuizResult(score: 100)
            let userInfo = try await receiveEducationStatus()
            updateInput(data: userInfo)
            return eduResult.success
        }
        return try await result.value
    }
    
    func getLecture() async throws -> String? {
        let result = Task { () -> String? in
            let eduResult = try await eduManager.getLecture()
            return eduResult.data?.lecture_list[0].video_url
        }
        return try await result.value
    }
    
    func getPostureLecture() async throws -> String? {
        let result = Task { () -> String? in
            let eduResult = try await eduManager.getPostureLecture()
            return eduResult.data?.video_url
        }
        return try await result.value
    }
    
    func updateInput(data: UserInfo?) {
        let progressPercent = Float(data?.progress_percent ?? 0)
        
        DispatchQueue.main.async { [weak self] in
            self?.input?.nickname.send(data?.nickname ?? "")
            self?.input?.angelStatus.send(data?.angel_status ?? 0)
            self?.input?.progressPercent.send(progressPercent)
            self?.input?.leftDay.send(data?.days_left_until_expiration ?? nil)
            
            let completedStatusArr = [
                data?.is_lecture_completed,
                data?.is_quiz_completed,
                data?.is_posture_completed
            ]
            
            for idx in 0..<completedStatusArr.count {
                if completedStatusArr[idx] == 2 {
                    self?.educationCourse[idx].courseStatus.send(.completed)
                } else {
                    self?.educationCourse[idx].courseStatus.send(.now)
                    if idx+1 <= completedStatusArr.count - 1 {
                        for i in idx+1..<completedStatusArr.count {
                            self?.educationCourse[i].courseStatus.send(.locked)
                        }
                        break
                    }
                }
            }
        }
    }
    
    func judgePostureResult() -> (compResult: CompressionRateStatus, angleResult: AngleStatus, pressDepth: PressDepthStatus) {
        guard let compRate = compressionRate, let correct = angleRate.correct, let nonCorrect = angleRate.nonCorrect, let pressRate = pressDepthRate else { return (CompressionRateStatus.wrong, AngleStatus.bad, PressDepthStatus.shallow) }
        
        var compResult: CompressionRateStatus = .adequate
        switch compRate {
        case ...80:
            compResult = .tooSlow
        case 80...100:
            compResult = .slow
        case 100...130:
            compResult = .adequate
        case 130...150:
            compResult = .fast
        case 150...:
            compResult = .tooFast
        default:
            compResult = .wrong
        }
        var angleResult: AngleStatus = .adequate
        let totalAngleCount = Double(correct + nonCorrect)
        
        switch Double(correct) {
        case Double(totalAngleCount) * 0.7...totalAngleCount:
            angleResult = .adequate
        case Double(totalAngleCount) * 0.6...Double(totalAngleCount) * 0.7:
            angleResult = .almost
        case Double(totalAngleCount) * 0.5...Double(totalAngleCount) * 0.6:
            angleResult = .notGood
        default:
            angleResult = .bad
        }
        
        print(totalAngleCount)
        if totalAngleCount < 1000 {
            angleResult = .bad
        }
        
        var pressDepthResult: PressDepthStatus = .wrong
        
        let defaultValue = UIScreen.main.bounds.width * 3
        
        if defaultValue / 20 < pressRate {
            pressDepthResult = .wrong
        } else if defaultValue / 30 < pressRate {
            pressDepthResult = .deep
        } else if defaultValue / 50 < pressRate {
            pressDepthResult = .adequate
        } else {
            pressDepthResult = .shallow
        }
        
        return (compResult, angleResult, pressDepthResult)
    }
    
    func setPostureResult(compCount: Int, armAngleCount: (correct: Int, nonCorrect: Int), pressDepth: CGFloat) {
        compressionRate = compCount
        angleRate.correct = armAngleCount.correct
        angleRate.nonCorrect = armAngleCount.nonCorrect
        pressDepthRate = pressDepth
    }
}
