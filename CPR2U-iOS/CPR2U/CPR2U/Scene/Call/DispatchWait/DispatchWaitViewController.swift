//
//  DispatchWaitViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import AVFoundation
import Combine
import UIKit

final class DispatchWaitViewController: UIViewController {

    private let mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 64)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Call"
        return label
    }()
    
    private lazy var approachNoticeView: ApproachNoticeView = {
        let view = ApproachNoticeView(viewModel: viewModel)
        return view
    }()
    
    private let emergencyDescriptionView = EmergencyDescriptionView()

    private let viewModel: CallViewModel
    private var audioPlayer: AVAudioPlayer!
    
    init(viewModel: CallViewModel) {
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
        playSound()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewModel.cancelTimer()
        audioPlayer.stop()
    }
    
    private func setUpConstraints() {
        [
            mainLabel,
            approachNoticeView,
            emergencyDescriptionView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            approachNoticeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            approachNoticeView.widthAnchor.constraint(equalToConstant: 358),
            approachNoticeView.heightAnchor.constraint(equalToConstant: 245)
        ])
        
        NSLayoutConstraint.activate([
            mainLabel.bottomAnchor.constraint(equalTo: approachNoticeView.topAnchor, constant: -36),
            mainLabel.widthAnchor.constraint(equalToConstant: 200),
            mainLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            emergencyDescriptionView.topAnchor.constraint(equalTo: approachNoticeView.bottomAnchor, constant: 68),
            emergencyDescriptionView.widthAnchor.constraint(equalToConstant: 358),
            emergencyDescriptionView.heightAnchor.constraint(equalToConstant: 198)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .mainRed
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "CPR_Sound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
        } catch (let error) {
            print(error)
        }
        audioPlayer?.play()
    }
}
