//
//  DispatchTimerView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import Combine
import GoogleMaps
import UIKit

protocol DispatchTimerViewDelegate: AnyObject {
    func noticeAppear(dispatchId: Int)
}

class DispatchTimerView: UIView {
    
    weak var delegate: DispatchTimerViewDelegate?
    
    private var dispatchId: Int?
    
    private var calledTime: Date?
    private var callerInfo: CallerInfo?
    
    private let timeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "time.png")
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textAlignment = .left
        label.textColor = .mainRed
        label.text = "elapsed_time_txt".localized()
        return label
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 48)
        label.textColor = .mainRed
        label.textAlignment = .center
        label.text = "00:00"
        return label
    }()
    
    private var timer: Timer.TimerPublisher?
    
    private var manager = MapManager()
    private var viewModel: CallViewModel?
    private var cancellables = Set<AnyCancellable>()

    init(callerInfo: CallerInfo, calledTime: Date, viewModel: CallViewModel) {
        super.init(frame: CGRect.zero)
        self.calledTime = calledTime
        self.callerInfo = callerInfo
        self.viewModel = viewModel
        setUpConstraints()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {

        let timeLabelStackView = UIStackView(arrangedSubviews: [
            timeImageView,
            descriptionLabel
        ])
        
        timeLabelStackView.axis  = NSLayoutConstraint.Axis.horizontal
        timeLabelStackView.alignment = UIStackView.Alignment.center
        
        timeLabelStackView.spacing   = 4
        
        NSLayoutConstraint.activate([
            timeImageView.widthAnchor.constraint(equalToConstant: 16),
            timeImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        descriptionLabel.sizeToFit()
        
        let timeStackView = UIStackView()
        timeStackView.axis  = NSLayoutConstraint.Axis.vertical
        timeStackView.alignment = UIStackView.Alignment.center
        timeStackView.spacing   = 8
        self.addSubview(timeStackView)
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            timeLabelStackView,
            timeLabel
        ].forEach({
            timeStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            timeLabel.widthAnchor.constraint(equalToConstant: 182),
            timeLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            timeStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            timeLabelStackView.centerXAnchor.constraint(equalTo: timeStackView.centerXAnchor),
            timeLabelStackView.heightAnchor.constraint(equalToConstant: 24)
        ])
        timeLabelStackView.sizeToFit()
        
    }
    
    private func setUpStyle() {
        backgroundColor = UIColor(rgb: 0xF5F5F5)
    }
    
    func setTimer(startTime: Int) {
        timer = Timer.publish(every: 1,tolerance: 0.9, on: .main, in: .default)
        timer?
            .autoconnect()
            .scan(startTime) { counter, _ in counter + 1 }
            .sink { [self] counter in
                if counter > 900 {
                    timer?.connect().cancel()
                    parentViewController().dismiss(animated: true)
                } else {
                    let userLocation = manager.setLocation()
                    guard let callerInfo = callerInfo else { return }
                    let distance = calculateDistanceFromCurrentLocation(callerInfo: callerInfo, userLocation: userLocation)
                    if distance < 20 {
                        guard let dispatchId = dispatchId else { return }
                        Task {
                            guard let viewModel = viewModel else { return }
                            let isSucceed = try await viewModel.dispatchEnd(dispatchId: dispatchId)
                            if isSucceed  {
                            } else {
                                print("CAN'T DISMISS")
                            }
                        }
                        delegate?.noticeAppear(dispatchId: dispatchId)
                        cancelTimer()
                        parentViewController().dismiss(animated: true)
                    }
                    timeLabel.text = counter.numberAsTime()
                }
            }.store(in: &cancellables)
    }
    
    func cancelTimer() {
        timer?.connect().cancel()
        timer = nil
    }
    
    func setUpTimerText(startTime: Int) {
        timeLabel.text = startTime.numberAsTime()
    }
    
    func setDispatchComponent(dispatchId: Int) {
        self.dispatchId = dispatchId
    }
    
    func calculateDistanceFromCurrentLocation(callerInfo: CallerInfo, userLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let callerLocation = CLLocationCoordinate2D(latitude: callerInfo.latitude, longitude: callerInfo.longitude)
        let rawDistance = GMSGeometryDistance(userLocation, callerLocation)
        return floor(rawDistance)
    }
}
