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

struct CallerCompactInfo {
    let callerId: Int
    let latitude: Double
    let longitude: Double
    let callerAddress: String
}

final class DispatchViewController: UIViewController {
    private let callerLocationNoticeView = CurrentLocationNoticeView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 12
        stackView.layer.borderColor = UIColor(rgb: 0x938C8C).cgColor
        stackView.layer.cornerRadius = 16
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private let stackViewDecoLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainLightGray
        return view
    }()
    
    private let durationView: DispatchDescriptionView = {
        let view = DispatchDescriptionView()
        view.setUpComponent(imageName: "time_check.png", type: .duration)
        return view
    }()
    
    private let distanceView: DispatchDescriptionView = {
        let view = DispatchDescriptionView()
        view.setUpComponent(imageName: "map.png", type: .distance)
        return view
    }()
    
    private lazy var dispatchTimerView: DispatchTimerView = {
        let view = DispatchTimerView(calledTime: Date())
        view.layer.borderColor = UIColor(rgb: 0x938C8C).cgColor
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.isHidden = true
        return view
    }()
    
    private let dispatchButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 27.5
        button.setTitle("DISPATCH", for: .normal)
        return button
    }()
    
    private let reportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.textAlignment = .right
        label.text = "Wrong Report? Report"
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let manager = DispatchManager(service: APIManager())
    private let callerInfo: CallerCompactInfo
    private let userLocation: CLLocationCoordinate2D
    private var dispatchId: Int?
    private var isDispatched: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init (userLocation: CLLocationCoordinate2D, callerInfo: CallerCompactInfo) {
        self.userLocation = userLocation
        self.callerInfo = callerInfo
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
        setUpAction()
        setupSheet()
        calculateDurationNDistance()
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
            dispatchButton,
            reportLabel
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
            stackView.topAnchor.constraint(equalTo: callerLocationNoticeView.bottomAnchor, constant: make.space8),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space8),
            stackView.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            dispatchTimerView.topAnchor.constraint(equalTo: callerLocationNoticeView.bottomAnchor, constant: make.space8),
            dispatchTimerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            dispatchTimerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space8),
            dispatchTimerView.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        [
            durationView,
            stackViewDecoLine,
            distanceView,
        ].forEach({
            stackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            stackViewDecoLine.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            stackViewDecoLine.widthAnchor.constraint(equalToConstant: 1),
            stackViewDecoLine.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            durationView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 56),
            durationView.widthAnchor.constraint(equalToConstant: 75),
            durationView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            distanceView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -56),
            distanceView.widthAnchor.constraint(equalToConstant: 75),
            distanceView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            dispatchButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: make.space16),
            dispatchButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            dispatchButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space8),
            dispatchButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            reportLabel.topAnchor.constraint(equalTo: dispatchButton.bottomAnchor, constant: make.space12),
            reportLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            reportLabel.trailingAnchor.constraint(equalTo: dispatchButton.trailingAnchor),
            reportLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpComponent() {
        callerLocationNoticeView.setUpLocationLabelText(as: callerInfo.callerAddress)
    }
    
    private func bind() {
        dispatchButton.tapPublisher.sink { [self] in
            if isDispatched {
                Task {
                    guard let dispatchId = dispatchId else { return }
                    let result = try await manager.dispatchEnd(dispatchId: dispatchId)
                    if result.success {
                        dismiss(animated: true)
                    }
                }
            } else {
                Task {
                    let result = try await manager.dispatchAccept(cprCallId: callerInfo.callerId)
                    if result.success {
                        dispatchId = result.data?.dispatch_id
                        isModalInPresentation = true
                        dispatchButton.setTitle("ARRIVED", for: .normal)
                        stackView.isHidden = true
                        reportLabel.isHidden = false
                        timerAppear()
                        dispatchTimerView.setTimer()
                        isDispatched = true
                    }
                }
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
    
    private func setUpAction() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapReportButton))
        reportLabel.addGestureRecognizer(gesture)
    }
    
    @objc func didTapReportButton() {
        guard let dispatchId = dispatchId else { return }
        let vc = ReportViewController(dispatchId: dispatchId, manager: manager)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension DispatchViewController {
    func calculateDurationNDistance() {
        let callerLocation = CLLocationCoordinate2D(latitude: callerInfo.latitude, longitude: callerInfo.longitude)
        let rawDistance = GMSGeometryDistance(userLocation, callerLocation)
        
        let floorDistance = floor(rawDistance)
        var duration: Int = 0
        var distanceStr = ""
        if floorDistance < 100 {
            duration = 1
        } else {
            duration = Int(ceil(Float(rawDistance/100)))
            if floorDistance < 1000 {
            distanceStr = "\(floorDistance)m"
            } else {
                let distance: Double = rawDistance/1000
                distanceStr = String(format: "%.2f", distance) + "km"
            }
        }
        
        print("RAW: \(rawDistance)")
        print("FLOOR: \(floorDistance)")
        print(distanceStr)
        durationView.setUpDescription(text:  "\(duration)m")
        distanceView.setUpDescription(text: distanceStr)
    }
}
