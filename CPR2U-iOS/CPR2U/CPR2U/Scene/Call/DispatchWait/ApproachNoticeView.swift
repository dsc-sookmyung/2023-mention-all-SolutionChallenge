//
//  ApproachNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import Combine
import UIKit

final class ApproachNoticeView: UIView {

    private let approachLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "angel_approach_notice_default_txt".localized()
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
        button.setTitle("siuation_end_des_txt".localized(), for: .normal)
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
            approachLabel,
            timeStackView,
            situationEndButton
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            timeStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeStackView.widthAnchor.constraint(equalToConstant: 182),
            timeStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            approachLabel.bottomAnchor.constraint(equalTo: timeStackView.topAnchor, constant: -make.space12),
            approachLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            approachLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            approachLabel.heightAnchor.constraint(equalToConstant: 50)
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
        self.layer.cornerRadius = 32
    }
    
    
    private func bind(viewModel: CallViewModel) {
        situationEndButton.tapPublisher.sink {
            Task {
                try await viewModel.situationEnd()
                self.parentViewController().dismiss(animated: true)
            }
        }.store(in: &cancellables)
        
        viewModel.$dispatcherCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                guard let count = count else { return }
                self?.updateApproachLabelText(count: count)
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
                        viewModel.countDispatcher()
                    }
                }
                if counter == 301 {
                    viewModel.timer?.connect().cancel()
                } else {
                    timeLabel.text = counter.numberAsTime()
                }
            }.store(in: &cancellables)
    }
    
    private func updateApproachLabelText(count: Int) {
        if count > 0 {
            let localizedStr = String(format: "angel_approach_notice_%dmatched_txt".localized(), count)
            approachLabel.text = localizedStr
            print(count)
        } else {
            approachLabel.text = "angel_approach_notice_default_txt".localized()
        }
    }

}
