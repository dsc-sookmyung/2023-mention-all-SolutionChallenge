//
//  CallMainViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import Combine
import CombineCocoa
import GoogleMaps
import UIKit

final class CallMainViewController: UIViewController {

    private lazy var mapView: GMSMapView = {
        let view = GMSMapView(frame: self.view.frame)
        return view
    }()
    
    private lazy var userLocationMarker: GMSMarker = {
        let marker = GMSMarker()
        return marker
    }()
    private var callerLocationMarkers: [GMSMarker] = []
    
    private lazy var timeCounterView = {
        let view = TimeCounterView(viewModel: viewModel)
        return view
    }()
    private let currentLocationNoticeView = CurrentLocationNoticeView(locationInfo: .originLocation)
    private let callButton = CallCircleView()
    
    private lazy var dispatchEndNoticeView: CustomNoticeView = {
        let view = CustomNoticeView(noticeAs: .dispatchComplete)
        view.setUpAction(callVC: self, viewModel: viewModel)
        return view
    }()
    
    private let viewModel: CallViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CallViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(viewModel: viewModel)
        setUpConstraints()
        setUpUserLocation()
        setUpCallerLocation()
        setUpStyle()
        setUpDelegate()
        setUpAction()
        NotificationCenter.default.addObserver(self, selector: #selector(showCallerPage), name: NSNotification.Name("ShowCallerPage"), object: nil)
        
        viewModel.$callerListInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] callerListInfo in
                guard let callerListInfo = callerListInfo else { return }
                if callerListInfo.call_list.count > 0 {
                    let callId = callerListInfo.call_list[0].cpr_call_id
                    guard let self = self else { return }
                    guard let target = callerListInfo.call_list.filter({$0.cpr_call_id == callId}).first else { return }
                    let callerInfo = CallerInfo(latitude: target.latitude, longitude: target.longitude, cpr_call_id: target.cpr_call_id, full_address: target.full_address, called_at: target.called_at)
                    let navigationController = UINavigationController(rootViewController: DispatchViewController(userLocation: self.viewModel.getLocation(), callerInfo: callerInfo, viewModel: viewModel))
                    present(navigationController, animated: true)
                }
            }.store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUserLocation()
        setUpCallerLocation()
    }

    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        
        [
            mapView,
            timeCounterView,
            currentLocationNoticeView,
            callButton,
            dispatchEndNoticeView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            timeCounterView.topAnchor.constraint(equalTo: view.topAnchor),
            timeCounterView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            timeCounterView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            timeCounterView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            currentLocationNoticeView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space16),
            currentLocationNoticeView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            currentLocationNoticeView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            currentLocationNoticeView.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        NSLayoutConstraint.activate([
            callButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16),
            callButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            callButton.widthAnchor.constraint(equalToConstant: 80),
            callButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        NSLayoutConstraint.activate([
            dispatchEndNoticeView.topAnchor.constraint(equalTo: view.topAnchor),
            dispatchEndNoticeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dispatchEndNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dispatchEndNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    private func setUpStyle() {
        view.backgroundColor = .lightGray
    }
    
    private func setUpDelegate() {
        mapView.delegate = self
    }
    
    private func setUpAction() {
        let longPress = UILongPressGestureRecognizer()
        longPress.minimumPressDuration = 0.0
        callButton.addGestureRecognizer(longPress)
        longPress.longPressPublisher.sink { [weak self] recognizer in
            self?.didPressCallButton(recognizer)
        }.store(in: &cancellables)
        
    }
    
    private func setUpUserLocation() {
        // MARK: Location
        let location = viewModel.getLocation()
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        mapView.camera = camera
     
        // MARK: Location Text
        Task {
            let temp = try await GMSGeocoder().reverseGeocodeCoordinate(location)
            guard let refinedAddress = temp.results()?[0].lines?.joined() else { return }
            let idx = refinedAddress.firstIndex(of: " ")!
            let index = refinedAddress.distance(from: refinedAddress.startIndex, to: idx)
            let startIndex = refinedAddress.index(refinedAddress.startIndex, offsetBy: index)
            var address = "\(refinedAddress[startIndex...])"
            address.remove(at: address.startIndex)
            
            viewModel.setLocationAddress(str: address)
        }

        // MARK: User Location Marker
        mapView.isMyLocationEnabled = true
    }
    
    private func setUpCallerLocation() {
        Task {
            if !callerLocationMarkers.isEmpty {
                callerLocationMarkers.forEach({ $0.map = nil })
                callerLocationMarkers = []
            }
            
            viewModel.$callerListInfo
                .receive(on: DispatchQueue.main)
                .sink { [weak self] callerList in
                    guard let callerList = callerList else { return }
                    for caller in callerList.call_list {
                        let coor = CLLocationCoordinate2D(latitude: caller.latitude, longitude: caller.longitude)
                        let marker = GMSMarker()
                        marker.title = String(caller.cpr_call_id)
                        marker.position = CLLocationCoordinate2DMake(coor.latitude, coor.longitude)
                        marker.map = self?.mapView
                        self?.callerLocationMarkers.append(marker)
                    }
                }.store(in: &cancellables)
            
        }
    }
    
    private func bind(viewModel: CallViewModel) {
        let output = viewModel.transform()
        
        output.isCalled.sink { isCalled in
            if isCalled {
                Task {
                    try await viewModel.callDispatcher()
                    let vc = DispatchWaitViewController(viewModel: viewModel)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    self.callButton.cancelProgressAnimation()
                    self.timeCounterView.cancelTimeCount()
                }
            }
        }.store(in: &cancellables)
        
        output.currentLocationAddress?.sink { address in
            self.currentLocationNoticeView.setUpLocationLabelText(as: address)
        }.store(in: &cancellables)
    }
    
    private func didPressCallButton(_ sender: UILongPressGestureRecognizer) {
        let state = sender.state
        if state == .began {
            callButton.progressAnimation()
            timeCounterView.timeCountAnimation()
        } else if state == .ended {
            callButton.cancelProgressAnimation()
            timeCounterView.cancelTimeCount()
        }
    }
    
    @objc func showCallerPage(_ notification:Notification) {
        self.dismiss(animated: true)
        if let userInfo = notification.userInfo {
            let type = userInfo["type"] as! String
            if type == "1" {
                viewModel.receiveCallerList()
                viewModel.$callerListInfo
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] callerListInfo in
                        guard let self = self else { return }
                        let callId = Int(userInfo["call"] as! String)
                        guard let target = callerListInfo?.call_list.filter({$0.cpr_call_id == callId}).first else { return }
                        let callerInfo = CallerInfo(latitude: target.latitude, longitude: target.longitude, cpr_call_id: target.cpr_call_id, full_address: target.full_address, called_at: target.called_at)
                        let navigationController = UINavigationController(rootViewController: DispatchViewController(userLocation: self.viewModel.getLocation(), callerInfo: callerInfo, viewModel: viewModel))
                        self.present(navigationController, animated: true)
                    }.store(in: &cancellables)
            }
        }
    }
}

extension CallMainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        guard let callId = Int(marker.title ?? "0") else { return false }
        guard let target = viewModel.callerListInfo?.call_list.filter({$0.cpr_call_id == callId}).first else { return false }
        
        let callerInfo = CallerInfo(latitude: target.latitude, longitude: target.longitude, cpr_call_id: target.cpr_call_id, full_address: target.full_address, called_at: target.called_at)
        let navigationController = UINavigationController(rootViewController: DispatchViewController(userLocation: viewModel.getLocation(), callerInfo: callerInfo, viewModel: viewModel))
        let vc = navigationController.topViewController as? DispatchViewController
        vc?.dispatchTimerView.delegate = self
        present(navigationController, animated: true, completion: nil)
        return true
    }
}

extension CallMainViewController: DispatchTimerViewDelegate {
    func noticeAppear(dispatchId: Int) {
        dispatchEndNoticeView.setUpDispatchComponent(dispatchId: dispatchId)
        dispatchEndNoticeView.noticeAppear()
    }
}

extension CallMainViewController: ReportViewControllerDelegate {
    func noticeDisappear() {
        dispatchEndNoticeView.noticeHide()
    }
}
