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
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .mainLightGray
        pageControl.currentPageIndicatorTintColor = .black
        return pageControl
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        let landscapeWidth = UIScreen.main.bounds.height
        let landscapeHeight = UIScreen.main.bounds.width
        scrollView.frame = CGRect(x: 0, y: 0, width: landscapeWidth, height: landscapeHeight)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 28)
        label.textAlignment = .left
        label.textColor = .mainWhite
        label.text = "your_result_txt".localized()
        return label
    }()
    
    private lazy var scoreStackView: UIStackView = {
       let view = UIStackView()
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.distribution = UIStackView.Distribution.equalSpacing
        view.alignment = UIStackView.Alignment.center
        view.spacing = 100
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 72)
        label.textAlignment = .center
        label.textColor = .mainWhite
        return label
    }()
    
    private lazy var scoreDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .mainWhite
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var resultStackView: UIStackView = {
        let view = UIStackView()
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.distribution = UIStackView.Distribution.fillEqually
        view.spacing = 110
        return view
    }()
    
    private let compressRateResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setResultImageView(isSuccess: false)
        view.setTitle(title: "Compression Rate")
        return view
    }()
    
    private let pressDepthResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setResultImageView(isSuccess: true)
        view.setTitle(title: "Press Depth")
        return view
    }()
    
    private let armAngleResultView: EvaluationResultView = {
        let view = EvaluationResultView()
        view.setImage(imgName: "ruler")
        view.setResultImageView(isSuccess: true)
        view.setTitle(title: "Arm Angle")
        return view
    }()
    
    private let finalResultView = ScoreResultView()
    
    private let quitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainWhite
        button.layer.cornerRadius = 24
        button.titleLabel?.font = UIFont(weight: .bold, size: 20)
        button.setTitleColor(.mainBlack, for: .normal)
        button.setTitle("quit".localized(), for: .normal)
        return button
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        setUpDelegate()
        bind(viewModel: viewModel)
        setUpText()
        
        setUpOrientation(as: .landscape) // TEST CODE
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        
        [
            resultLabel,
            pageControl,
            scrollView,
            quitButton
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        [
            scoreStackView,
            resultStackView,
        ].forEach({
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: make.space24),
            resultLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultLabel.widthAnchor.constraint(equalToConstant: 200),
            resultLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        scrollView.contentSize.height = scrollView.frame.height

        
        NSLayoutConstraint.activate([
            scoreStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 95),
            scoreStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor, constant: -95),
            scoreStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -make.space8),
            scoreStackView.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            resultStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor, constant: 38),
            resultStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -38),
            resultStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -make.space24),
            resultStackView.heightAnchor.constraint(equalToConstant: 128)
        ])
        
        [
            scoreLabel,
            scoreDescriptionLabel
        ].forEach({
            scoreStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            scoreLabel.widthAnchor.constraint(equalToConstant: 158),
            scoreLabel.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            scoreDescriptionLabel.widthAnchor.constraint(equalToConstant: 396),
            scoreDescriptionLabel.heightAnchor.constraint(equalToConstant: 72)
        ])
        
        let evaluationResultViewArr = [
            armAngleResultView,
            compressRateResultView,
            pressDepthResultView
        ]
        
        evaluationResultViewArr.forEach({
            resultStackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 196).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 128).isActive = true
        })
        
        NSLayoutConstraint.activate([
            armAngleResultView.leadingAnchor.constraint(equalTo: resultStackView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            compressRateResultView.centerXAnchor.constraint(equalTo: resultStackView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pressDepthResultView.trailingAnchor.constraint(equalTo: resultStackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: quitButton.topAnchor, constant: -make.space12),
            pageControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            pageControl.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            quitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16),
            quitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quitButton.widthAnchor.constraint(equalToConstant: 206),
            quitButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .mainRed
    }
    
    private func setUpDelegate() {
        scrollView.delegate = self
    }

    private func bind(viewModel: EducationViewModel) {
        quitButton.tapPublisher.sink { [weak self] _ in
            self?.setUpOrientation(as: .portrait)
            Task {
//                _ = try await viewModel.savePosturePracticeResult(score: self?.score ?? 0)
                _ = try await viewModel.savePosturePracticeResult(score: 95)
                let rootVC = TabBarViewController(0)
                await self?.view.window?.setRootViewController(rootVC)
            }
        }.store(in: &cancellables)
    }

    private func setUpText() {
        let result = viewModel.judgePostureResult()
        compressRateResultView.setResultLabelText(as: result.compResult.rawValue)
        compressRateResultView.setDescriptionLabelText(as: result.compResult.description)
        armAngleResultView.setResultImageView(isSuccess: result.compResult.isSucceed)
        
        armAngleResultView.setResultLabelText(as: result.angleResult.rawValue)
        armAngleResultView.setDescriptionLabelText(as: result.angleResult.description)
        armAngleResultView.setResultImageView(isSuccess: result.angleResult.isSucceed)
        
        pressDepthResultView.setResultLabelText(as: result.pressDepth.rawValue)
        pressDepthResultView.setDescriptionLabelText(as: result.pressDepth.description)
        pressDepthResultView.setResultImageView(isSuccess: result.pressDepth.isSucceed)
        
        score = result.compResult.score + result.angleResult.score + result.pressDepth.score + 1
        setUpScore(score: score)
        view.layoutIfNeeded()
    }
    
    func setUpScore(score: Int) {
        let scoreStr = "\(score)/100"
        scoreLabel.text = scoreStr
        scoreLabel.attributedText = arrangeScoreText(text: scoreLabel.text ?? "")
        
        if score >= 80 {
            scoreDescriptionLabel.text = "pe_pass_txt".localized()
        } else {
            scoreDescriptionLabel.text = "pe_fail_txt".localized()
        }
    }
    
    private func arrangeScoreText(text: String) -> NSAttributedString {
        var range: Int = 0
        let attributedString = NSMutableAttributedString(string: text)
        if let rangeS = text.range(of: "/") {
            range = text.distance(from: text.startIndex, to: rangeS.lowerBound)
        }
        
        let realScoreAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont(weight: .bold, size: 72) ?? UIFont(),
            .foregroundColor : UIColor.mainWhite
        ]
        
        let defaultScoreAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont(weight: .bold, size: 32) ?? UIFont(),
            .foregroundColor : UIColor.mainLightRed
        ]
        
        attributedString.addAttributes(realScoreAttributes, range: NSRange(location: 0, length: range))
        attributedString.addAttributes(defaultScoreAttributes, range: NSRange(location: range, length: attributedString.length - range))
        
        return attributedString
    }
    
    private func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
}

extension PosePracticeResultViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
}
