//
//  DispatchTimerView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import Combine
import UIKit

class DispatchTimerView: UIView {

    private let calledTime: Date?
    
    private let timeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "time.png")
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 48)
        label.textColor = .mainRed
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    private var timer: Timer.TimerPublisher?
    private var cancellables = Set<AnyCancellable>()

    init(calledTime: Date) {
        self.calledTime = calledTime
        super.init(frame: CGRect.zero)
        setUpConstraints()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {

        let timeStackView   = UIStackView()
        timeStackView.axis  = NSLayoutConstraint.Axis.horizontal
        timeStackView.distribution  = UIStackView.Distribution.equalSpacing
        timeStackView.alignment = UIStackView.Alignment.center
        timeStackView.spacing   = 8

        self.addSubview(timeStackView)
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeStackView.widthAnchor.constraint(equalToConstant: 182),
            timeStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        [
            timeImageView,
            timeLabel
        ].forEach({
            timeStackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: timeStackView.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            timeImageView.leadingAnchor.constraint(equalTo: timeStackView.leadingAnchor),
            timeImageView.widthAnchor.constraint(equalToConstant: 50),
            timeImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: timeStackView.trailingAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 182),
            timeLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setUpStyle() {
        backgroundColor = .white
    }
    
    func setTimer() {
        timer = Timer.publish(every: 1,tolerance: 0.9, on: .main, in: .default)
        timer?
            .autoconnect()
            .scan(0) { counter, _ in counter + 1 }
            .sink { [self] counter in
                if counter == 301 {
                    timer?.connect().cancel()
                } else {
                    timeLabel.text = counter.numberAsTime()
                }
            }.store(in: &cancellables)
    }
    
    func cancelTimer() {
        timer?.connect().cancel()
        timer = nil
    }
}
