//
//  DispatchViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import Combine
import CombineCocoa
import GoogleMaps
import UIKit

final class DispatchViewController: UIViewController {
    
    private let callerLocationNoticeView = CurrentLocationNoticeView(locationInfo: .targetLocation)
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 12
        stackView.backgroundColor = UIColor(rgb: 0xF5F5F5)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private let stackViewDecoLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xBCBCBC)
        return view
    }()
    
    private let startTimeView: DispatchDescriptionView = {
        let view = DispatchDescriptionView()
        view.setUpComponent(imageName: "time_black.png", type: .startTime)
        return view
    }()
    
    private let distanceView: DispatchDescriptionView = {
        let view = DispatchDescriptionView()
        view.setUpComponent(imageName: "map_black.png", type: .distance)
        return view
    }()
    
    lazy var dispatchTimerView: DispatchTimerView = {
        let view = DispatchTimerView(callerInfo: callerInfo, calledTime: Date(), viewModel: viewModel)
        view.layer.borderColor = UIColor(rgb: 0x938C8C).cgColor
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.isHidden = true
        return view
    }()
    
    private lazy var dispatchDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(rgb: 0x454545)
        label.text = "dispatch_des_txt".localized()
        return label
    }()
    private let dispatchButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 27.5
        button.setTitle("dispatch_tab_t".localized(), for: .normal)
        return button
    }()
    
    private let viewModel: CallViewModel
    private let callerInfo: CallerInfo
    private let userLocation: CLLocationCoordinate2D
    private var dispatchId: Int?
    private var isDispatched: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var noticeView: CustomNoticeView?
    
    init (userLocation: CLLocationCoordinate2D, callerInfo: CallerInfo, viewModel: CallViewModel) {
        self.userLocation = userLocation
        self.callerInfo = callerInfo
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConstraints()
        setUpStyle()
        setUpComponent()
        bind()
        setupSheet()
        calculateDistance()
        calculateTime(dateStr: callerInfo.called_at)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dispatchTimerView.cancelTimer()
    }
    private func setUpConstraints() {
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        
        [
            callerLocationNoticeView,
            stackView,
            dispatchTimerView,
            dispatchDescriptionLabel,
            dispatchButton,
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            callerLocationNoticeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            callerLocationNoticeView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            callerLocationNoticeView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            callerLocationNoticeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: callerLocationNoticeView.bottomAnchor, constant: make.space16),
            stackView.leadingAnchor.constraint(equalTo: callerLocationNoticeView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: callerLocationNoticeView.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            dispatchTimerView.topAnchor.constraint(equalTo: callerLocationNoticeView.bottomAnchor, constant: make.space16),
            dispatchTimerView.leadingAnchor.constraint(equalTo: callerLocationNoticeView.leadingAnchor),
            dispatchTimerView.trailingAnchor.constraint(equalTo: callerLocationNoticeView.trailingAnchor),
            dispatchTimerView.heightAnchor.constraint(equalToConstant: 108)
        ])
        dispatchTimerView.sizeToFit()
        
        [
            startTimeView,
            stackViewDecoLine,
            distanceView,
        ].forEach({
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            stackViewDecoLine.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            stackViewDecoLine.widthAnchor.constraint(equalToConstant: 1),
            stackViewDecoLine.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            startTimeView.widthAnchor.constraint(equalToConstant: 75),
            startTimeView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        NSLayoutConstraint.activate([
            distanceView.widthAnchor.constraint(equalToConstant: 75),
            distanceView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        NSLayoutConstraint.activate([
            dispatchDescriptionLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: make.space16),
            dispatchDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dispatchDescriptionLabel.widthAnchor.constraint(equalToConstant: 320),
            dispatchDescriptionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            dispatchButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: make.space16),
            dispatchButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            dispatchButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space8),
            dispatchButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpComponent() {
        callerLocationNoticeView.setUpLocationLabelText(as: callerInfo.full_address)
    }
    
    private func bind() {
        dispatchButton.tapPublisher.sink { [self] in
            if isDispatched {
                guard let dispatchId = dispatchId else { return }
                Task {
                    let isSucceed = try await viewModel.dispatchEnd(dispatchId: dispatchId)
                    if isSucceed  {
                        print("DISMISS!!!")
                        dismiss(animated: true)
                    } else {
                        print("CAN'T DISMISS")
                    }
                }
            } else {
                showAlert()
                
            }
        }.store(in: &cancellables)
    }
    
    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in return 300 }]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 18
        }
    }
    
    private func timerAppear() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dispatchTimerView.isHidden = false
        })
    }
}

extension DispatchViewController {
    func calculateDistance() {
        let callerLocation = CLLocationCoordinate2D(latitude: callerInfo.latitude, longitude: callerInfo.longitude)
        let rawDistance = GMSGeometryDistance(userLocation, callerLocation)
        let floorDistance = calculateDistanceFromCurrentLocation()
        var distanceStr = ""
        if floorDistance < 1000 {
        distanceStr = "\(floorDistance)m"
        } else {
            let distance: Double = rawDistance/1000
            distanceStr = String(format: "%.2f", distance) + "km"
        }
        distanceView.setUpDescription(text: distanceStr)
    }
    
    func calculateDistanceFromCurrentLocation() -> CLLocationDistance {
        let callerLocation = CLLocationCoordinate2D(latitude: callerInfo.latitude, longitude: callerInfo.longitude)
        let rawDistance = GMSGeometryDistance(userLocation, callerLocation)
        return floor(rawDistance)
    }
    
    func calculateTime(dateStr: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        guard let tempDate = dateFormatter.date(from: dateStr) else { return }
        dateFormatter.dateFormat = "a HH':'mm"
        let date = dateFormatter.string(from: tempDate)
        startTimeView.setUpDescription(text: date)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "dispatch_ins_txt".localized(), message: "dispatch_alert_txt".localized(), preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "dispatch_tab_t".localized(), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.acceptDispatch()
        })
        
        let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        [confirm, cancel].forEach {
            alert.addAction($0)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func acceptDispatch() {
        Task {
            let result = try await viewModel.dispatchAccept(cprCallId: callerInfo.cpr_call_id)
            if result.0 {
                guard let data = result.1 else { return }
                let dispatchId = data.dispatch_id
                print("########", dispatchId)
                isModalInPresentation = true
                dispatchButton.isHidden = true
                dispatchDescriptionLabel.isHidden = false
                stackView.isHidden = true
                timerAppear()
                dispatchTimerView.setUpTimerText(startTime: data.called_at.elapsedTime())
                dispatchTimerView.setTimer(startTime: data.called_at.elapsedTime())
                isDispatched = true
                dispatchTimerView.setDispatchComponent(dispatchId: dispatchId)
            }
        }
    }
}
