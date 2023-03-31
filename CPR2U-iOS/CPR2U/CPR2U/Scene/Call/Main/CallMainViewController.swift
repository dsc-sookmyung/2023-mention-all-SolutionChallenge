//
//  CallMainViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import Combine
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
    private let currentLocationNoticeView = CurrentLocationNoticeView()
    private let callButton = CallCircleView()
    
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
            callButton
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
            currentLocationNoticeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            callButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16),
            callButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            callButton.widthAnchor.constraint(equalToConstant: 80),
            callButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }
    
    private func setUpStyle() {
        view.backgroundColor = .lightGray
    }
    
    private func setUpDelegate() {
        mapView.delegate = self
    }
    
    private func setUpAction() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didPressCallButton))
        recognizer.minimumPressDuration = 0.0
        callButton.addGestureRecognizer(recognizer)
        
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
            
            guard let callerList = try await self.viewModel.receiveCallerList() else { return }
            
            for caller in callerList.call_list {
                let coor = CLLocationCoordinate2D(latitude: caller.latitude, longitude: caller.longitude)
                print(coor)
                let marker = GMSMarker()
                marker.title = String(caller.cpr_call_id)
                marker.position = CLLocationCoordinate2DMake(coor.latitude, coor.longitude)
                marker.map = mapView
                callerLocationMarkers.append(marker)
            }
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
        
        output.callerList?.sink { list in
            print(list)
            if list.angel_status == "ACQUIRED" && !list.is_patient {
                print(list.call_list)
            }
            
        }.store(in: &cancellables)
    }
    
    @objc func didPressCallButton(_ sender: UILongPressGestureRecognizer) {
        let state = sender.state
        if state == .began {
            callButton.progressAnimation()
            timeCounterView.timeCountAnimation()
        } else if state == .ended {
            callButton.cancelProgressAnimation()
            timeCounterView.cancelTimeCount()
        }
    }
}

extension CallMainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        guard let callId = Int(marker.title ?? "0") else { return false }
        guard let target = viewModel.callerList?.value.call_list.filter{$0.cpr_call_id == callId}.first else { return false }
        
        let callerInfo = CallerCompactInfo(callerId: target.cpr_call_id, latitude: target.latitude, longitude: target.longitude, callerAddress: target.full_address)
        let navigationController = UINavigationController(rootViewController: DispatchViewController(userLocation: viewModel.getLocation(), callerInfo: callerInfo))
            present(navigationController, animated: true, completion: nil)
        return true
    }
}
