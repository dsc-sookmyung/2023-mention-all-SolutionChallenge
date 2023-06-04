//
//  LectureViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/24.
//

import Combine
import UIKit
import WebKit

final class LectureNoticeView: CustomNoticeView {
    @objc internal override func didConfirmButtonTapped() { }
}

final class LectureViewController: UIViewController {
    
    private let webView = WKWebView()
    
    private let noticeView: LectureNoticeView = {
        let view = LectureNoticeView(noticeAs: .lecturePass)
        return view
    }()
    
    private var viewModel: EducationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: EducationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.updateTimerType(vc: self)
        setUpConstraints()
        setUpStyle()
        loadWebPage()
        setTimer()
        bind(viewModel: viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel.timer.connect().cancel()
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        [
            webView,
            noticeView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            noticeView.topAnchor.constraint(equalTo: view.topAnchor),
            noticeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func loadWebPage() {
        Task {
            guard let url = try await viewModel.getLecture() else { return }
            guard let stringToURL = URL(string: url) else { return }
            let URLToRequest = URLRequest(url: stringToURL)
            webView.load(URLToRequest)
        }
    }
    
    private func setTimer() {
        let count = viewModel.timeLimit()
        viewModel.timer
            .autoconnect()
            .scan(0) { counter, _ in counter + 1 }
            .sink { [self] counter in
                if counter == count + 1 {
                    noticeView.noticeAppear()
                    viewModel.timer.connect().cancel()
                }
            }.store(in: &cancellables)
    }
    
    private func bind(viewModel: EducationViewModel) {
        noticeView.confirmButton.tapPublisher.sink { [weak self] in
            Task {
                _ = try await viewModel.saveLectureProgress()
                self?.noticeView.noticeDisappear()
                if let vc = self?.navigationController?.viewControllers[0] as? EducationMainViewController {
                    vc.educationCollectionView.reloadData()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }.store(in: &cancellables)
    }
}
