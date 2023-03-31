//
//  PosePracticeResultViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import Combine
import CombineCocoa
import UIKit

final class PosePracticeResultViewController: UIViewController {
    private let compressRateResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setTitle(title: "Compression Rate")
        view.setResultLabelText(as: "0.5 per 1 time")
        view.setDescriptionLabelText(as: "It’s too fast. Little bit Slower")
        return view
    }()
    
    private let pressDepthResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setTitle(title: "Press Depth")
        view.setResultLabelText(as: "Slightly shallow")
        view.setDescriptionLabelText(as: "Press little deeper")
        return view
    }()
    
    private let handLocationResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setTitle(title: "Hand Location")
        view.setResultLabelText(as: "Adequate")
        view.setDescriptionLabelText(as: "Nice Location!")
        return view
    }()
    
    private let armAngleResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setTitle(title: "Arm Angle")
        view.setResultLabelText(as: "Adequate")
        view.setDescriptionLabelText(as: "Nice Angle!")
        return view
    }()
    
    private let finalResultView = ScoreResultView()
    
    private let quitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 19
        button.titleLabel?.font = UIFont(weight: .bold, size: 17)
        button.setTitleColor(.mainWhite, for: .normal)
        button.setTitle("QUIT", for: .normal)
        return button
    }()
    
    private let viewModel: EducationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var score: Int = 0
    
    init(viewModel: EducationViewModel) {
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
        bind(viewModel: viewModel)
        setUpText()
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        
        [
            compressRateResultView,
            pressDepthResultView,
            handLocationResultView,
            armAngleResultView,
            finalResultView,
            quitButton
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        let evaluationResultViewArr = [compressRateResultView, pressDepthResultView, handLocationResultView, armAngleResultView,]
        
        evaluationResultViewArr.forEach({
            $0.widthAnchor.constraint(equalToConstant: 255).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 150).isActive = true
        })
        
        NSLayoutConstraint.activate([
            compressRateResultView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space24),
            compressRateResultView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16)
        ])
        
        NSLayoutConstraint.activate([
            pressDepthResultView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space24),
            pressDepthResultView.leadingAnchor.constraint(equalTo: compressRateResultView.leadingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            handLocationResultView.topAnchor.constraint(equalTo: compressRateResultView.topAnchor),
            handLocationResultView.leadingAnchor.constraint(equalTo: compressRateResultView.trailingAnchor, constant: make.space16)
        ])
        
        NSLayoutConstraint.activate([
            armAngleResultView.bottomAnchor.constraint(equalTo: pressDepthResultView.bottomAnchor),
            armAngleResultView.leadingAnchor.constraint(equalTo: compressRateResultView.trailingAnchor, constant: make.space16)
        ])
        
        NSLayoutConstraint.activate([
            quitButton.bottomAnchor.constraint(equalTo: armAngleResultView.bottomAnchor),
            quitButton.leadingAnchor.constraint(equalTo: armAngleResultView.trailingAnchor, constant: make.space16),
            quitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -make.space16),
            quitButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        NSLayoutConstraint.activate([
            finalResultView.topAnchor.constraint(equalTo: handLocationResultView.topAnchor),
            finalResultView.bottomAnchor.constraint(equalTo: quitButton.topAnchor, constant: -make.space12),
            finalResultView.leadingAnchor.constraint(equalTo: quitButton.leadingAnchor),
            finalResultView.trailingAnchor.constraint(equalTo: quitButton.trailingAnchor)
            
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func bind(viewModel: EducationViewModel) {
        quitButton.tapPublisher.sink { [weak self] _ in
            self?.setUpOrientation(as: .portrait)
            Task {
                try await viewModel.savePosturePracticeResult(score: self?.score ?? 0)
                let rootVC = TabBarViewController(0)
                await self?.view.window?.setRootViewController(rootVC)
            }
        }.store(in: &cancellables)
    }

    private func setUpText() {
        let result = viewModel.judgePostureResult()
        compressRateResultView.setResultLabelText(as: result.compResult.rawValue)
        compressRateResultView.setDescriptionLabelText(as: result.compResult.description)
        armAngleResultView.setResultLabelText(as: result.angleResult.rawValue)
        armAngleResultView.setDescriptionLabelText(as: result.angleResult.description)
        pressDepthResultView.setResultLabelText(as: result.pressDepth.rawValue)
        pressDepthResultView.setDescriptionLabelText(as: result.pressDepth.description)
        score = result.compResult.score + result.angleResult.score + result.pressDepth.score + 1
        finalResultView.setUpScore(score: score)
    }
}
