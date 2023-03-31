//
//  ApproachNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import Combine
import UIKit

final class ApproachNoticeView: UIView {

    private let peopleImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "people.png")
        return view
    }()
    
    private lazy var peopleCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 48)
        label.textColor = .mainRed
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    private let approachLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Approaching"
        return label
    }()
    
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
    
    private let situationEndButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 27.5
        button.setTitle("SITUATION ENDED", for: .normal)
        return button
    }()
    
    private var viewModel: CallViewModel
    private var cancellables = Set<AnyCancellable>()
    
    required init(viewModel: CallViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        
        setUpConstraints()
        setUpStyle()
        bind(viewModel: viewModel)
        setTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        
        let approachStackView = UIStackView()
        approachStackView.axis  = NSLayoutConstraint.Axis.horizontal
        approachStackView.distribution  = UIStackView.Distribution.equalSpacing
        approachStackView.alignment = UIStackView.Alignment.center
        approachStackView.spacing   = 8
        
        [
            peopleImageView,
            peopleCountLabel,
            approachLabel
        ].forEach({
            approachStackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: approachStackView.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            peopleImageView.leadingAnchor.constraint(equalTo: approachStackView.leadingAnchor),
            peopleImageView.widthAnchor.constraint(equalToConstant: 50),
            peopleImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            peopleCountLabel.leadingAnchor.constraint(equalTo: peopleImageView.trailingAnchor),
            peopleCountLabel.trailingAnchor.constraint(equalTo: approachLabel.leadingAnchor),
            peopleCountLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            approachLabel.trailingAnchor.constraint(equalTo: approachStackView.trailingAnchor),
            approachLabel.widthAnchor.constraint(equalToConstant: 128),
            approachLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let timeStackView   = UIStackView()
        timeStackView.axis  = NSLayoutConstraint.Axis.horizontal
        timeStackView.distribution  = UIStackView.Distribution.equalSpacing
        timeStackView.alignment = UIStackView.Alignment.center
        timeStackView.spacing   = 8
        
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
        
        [
            approachStackView,
            timeStackView,
            situationEndButton
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            approachStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 36),
            approachStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            approachStackView.widthAnchor.constraint(equalToConstant: 222),
            approachStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            timeStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeStackView.widthAnchor.constraint(equalToConstant: 182),
            timeStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            situationEndButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -make.space8),
            situationEndButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            situationEndButton.widthAnchor.constraint(equalToConstant: 340),
            situationEndButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        backgroundColor = .white
        self.layer.cornerRadius = 24
    }
    
    
    private func bind(viewModel: CallViewModel) {
        situationEndButton.tapPublisher.sink {
            Task {
                try await viewModel.situationEnd()
                self.parentViewController().dismiss(animated: true)
            }
        }.store(in: &cancellables)
    }
    
    private func setTimer() {
        viewModel.timer = Timer.publish(every: 1,tolerance: 0.9, on: .main, in: .default)
        viewModel.timer?
            .autoconnect()
            .scan(0) { counter, _ in counter + 1 }
            .sink { [self] counter in
                
                if counter % 15 == 0 {
                    Task {
                        let dispatcherNumber = try await viewModel.countDispatcher()
                        peopleCountLabel.text = "\(dispatcherNumber ?? 0)"
                    }
                    
                }
                if counter == 301 {
                    viewModel.timer?.connect().cancel()
                } else {
                    timeLabel.text = counter.numberAsTime()
                }
            }.store(in: &cancellables)
    }

}
