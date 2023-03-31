//
//  TimeCounterView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import UIKit
import Combine

final class TimeCounterView: UIView {
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 98)
        label.textColor = .mainRed
        label.shadowColor = UIColor(rgb: 0xB50000)
        label.textAlignment = .center
        label.text = "3"
        label.isHidden = true
        return label
    }()
    
    private let viewModel: CallViewModel
    private var timer: Timer.TimerPublisher?
    private var cancellables = Set<AnyCancellable>()

    
    required init(viewModel: CallViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setUpConstriants()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstriants() {
        self.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant:100),
            timeLabel.heightAnchor.constraint(equalToConstant:100)
        ])
    }
    
    private func setUpStyle() {
        isUserInteractionEnabled = false
        backgroundColor = .mainRed.withAlphaComponent(0.0)
    }
    
    func timeCountAnimation() {
        timeLabel.isHidden = false
        backgroundAlphaAnimation()
        timer = Timer.publish(every: 1,tolerance: 0.9, on: .main, in: .default)
        timer?
            .autoconnect()
            .scan(0) { counter, _ in counter + 1 }
            .sink { [self] counter in
                if counter == 3 {
                    viewModel.isCallSucceed()
                    timer?.connect().cancel()
                } else {
                    timeLabel.text = "\(3 - counter)"
                }
            }.store(in: &cancellables)
    }
    
    func cancelTimeCount() {
        timer?.connect().cancel()
        backgroundColor = .mainRed.withAlphaComponent(0)
        timeLabel.isHidden = true
        timeLabel.text = "3"
    }
    
    private func backgroundAlphaAnimation() {
        UIView.animate(withDuration: 3.0, delay: 0.0, animations: {
            self.backgroundColor = .mainRed.withAlphaComponent(0.5)
        })
        
    }
}
