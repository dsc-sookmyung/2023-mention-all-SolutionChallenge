//
//  EducationEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/22.
//

import Foundation

enum EducationEndPoint {
    case saveQuizResult(score: Int)
    case saveLectureProgress(lectureId: Int)
    case savePosturePracticeResult(score: Int)
    case getEducationProgress
    case getQuizList
    case getLecture
    case getPostureLecture
}

extension EducationEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .saveQuizResult, .saveLectureProgress, .savePosturePracticeResult:
            return .POST
        case .getEducationProgress, .getQuizList, .getLecture, .getPostureLecture:
            return .GET
        }
    }
    
    var body: Data? {
        var params: [String : Int]
        switch self {
        case .saveQuizResult(let score), .savePosturePracticeResult(let score):
            params = ["score" : score]
        case .saveLectureProgress, .getEducationProgress, .getQuizList, .getLecture, .getPostureLecture:
            params = [:]
        }
        
        return params.encode()
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .saveQuizResult:
            return "\(baseURL)/education/quizzes/progress"
        case .saveLectureProgress(let lectureId): // ????
            return "\(baseURL)/education/lectures/progress/\(lectureId)"
        case .savePosturePracticeResult:
            return "\(baseURL)/education/exercises/progress"
        case .getEducationProgress:
            return "\(baseURL)/education"
        case .getQuizList:
            return "\(baseURL)/education/quizzes"
        case .getLecture:
            return "\(baseURL)/education/lectures"
        case .getPostureLecture:
            return "\(baseURL)/education/exercises"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        var headers: [String: String] = [:]
        headers["Authorization"] = UserDefaultsManager.accessToken

        switch self {
        case .saveQuizResult:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        case .saveLectureProgress:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .savePosturePracticeResult:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        case .getEducationProgress:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .getQuizList:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .getLecture:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .getPostureLecture:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        }
    }
}
