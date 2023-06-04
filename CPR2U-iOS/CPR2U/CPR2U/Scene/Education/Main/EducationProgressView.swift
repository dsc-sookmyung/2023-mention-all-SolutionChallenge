//
//  EducationProgressView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/09.
//

import UIKit

final class EducationProgressView: UIView {

    private lazy var lectureStatusView: StatusCircleView = {
        let view = StatusCircleView()
        return view
    }()
    
    private lazy var quizStatusView: StatusCircleView = {
        let view = StatusCircleView()
        return view
    }()
    
    private lazy var posePracticeStatusView: StatusCircleView = {
        let view = StatusCircleView()
        return view
    }()
    
    private lazy var lecToQuizLine: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var quizToPoseLine: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        
        [
            lectureStatusView,
            lecToQuizLine,
            quizStatusView,
            posePracticeStatusView,
            quizToPoseLine
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        })
        
        [
            lectureStatusView,
            quizStatusView,
            posePracticeStatusView
        ].forEach({
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        })
        
        
        NSLayoutConstraint.activate([
            lectureStatusView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            quizStatusView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            posePracticeStatusView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            lecToQuizLine.heightAnchor.constraint(equalToConstant: 2),
            lecToQuizLine.leadingAnchor.constraint(equalTo: lectureStatusView.trailingAnchor),
            lecToQuizLine.trailingAnchor.constraint(equalTo: quizStatusView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            quizToPoseLine.heightAnchor.constraint(equalToConstant: 2),
            quizToPoseLine.leadingAnchor.constraint(equalTo: quizStatusView.trailingAnchor),
            quizToPoseLine.trailingAnchor.constraint(equalTo: posePracticeStatusView.leadingAnchor)
        ])
    }
    
    func setUpComponent(status: [CourseStatus]) {
        let statusViewArr = [
            lectureStatusView,
            quizStatusView,
            posePracticeStatusView
        ]
        
        for i in 0..<statusViewArr.count {
            statusViewArr[i].setUpComponent(courseNumber: i+1, status: status[i])
        }
        
        lecToQuizLine.backgroundColor = status[1].courseViewColor
        quizToPoseLine.backgroundColor = status[2].courseViewColor
        
        self.layoutIfNeeded()
    }
}
