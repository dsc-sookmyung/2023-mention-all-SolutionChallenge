//
//  PracticeExplainViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import Combine
import CombineCocoa
import UIKit

struct PracticeInfo {
    let imageName: String
    let title: String
    let description: String
}

final class PracticeExplainViewController: UIViewController {
    
    private let practiceInfoList: [PracticeInfo] = {
        var infoList: [PracticeInfo] = []
        
        let imgList: [String] = ["onboarding1.png", "onboarding2.png", "onboarding3.png", "onboarding4.png"]
        let titleList: [String] = ["pe_title_txt_1".localized(), "pe_title_txt_2".localized(), "pe_title_txt_3".localized(), "pe_title_txt_4".localized()]
        let descriptionList: [String] = ["pe_des_txt_1".localized(), "pe_des_txt_2".localized(), "pe_des_txt_3".localized(), "pe_des_txt_4".localized()]
        
        for i in 0..<imgList.count {
            infoList.append(PracticeInfo(imageName: imgList[i], title: titleList[i], description: descriptionList[i]))
        }
        return infoList
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = practiceInfoList.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .mainLightGray
        pageControl.currentPageIndicatorTintColor = .black
        return pageControl
    }()
    
    private lazy var onboardingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 18)
        label.textColor = .mainBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let moveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainLightRed
        button.setTitleColor(.mainBlack, for: .normal)
        button.titleLabel?.font = UIFont(weight: .bold, size: 16)
        button.setTitle("Moving on to Posture Practice", for: .normal)
        return button
    }()
    
    private let viewModel: EducationViewModel
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
        
        setUpConstraints()
        setUpStyle()
        setUpAction()
        updateOnboardingComponent(index: 0)
        setUpDelegate()
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
            onboardingScrollView,
            titleLabel,
            descriptionLabel,
            pageControl,
            moveButton
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            moveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            moveButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            moveButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            moveButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: moveButton.topAnchor, constant: -62),
            pageControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            pageControl.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -40),
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -18),
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            onboardingScrollView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -30),
            onboardingScrollView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            onboardingScrollView.widthAnchor.constraint(equalToConstant: 390),
            onboardingScrollView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        for i in 0..<practiceInfoList.count {
            let imageView = UIImageView()
            let xPos = onboardingScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: 390, height: 300)
            imageView.image = UIImage(named: practiceInfoList[i].imageName) ?? UIImage()
            imageView.contentMode = .scaleAspectFit
            onboardingScrollView.addSubview(imageView)
            onboardingScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpDelegate() {
        onboardingScrollView.delegate = self
    }
    
    private func setUpAction() {
        moveButton.tapPublisher.sink { [self] in
            setUpOrientation(as: .landscapeRight)
            let vc = PosePracticeViewController(viewModel: viewModel)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }.store(in: &cancellables)
    }
    
    func updateOnboardingComponent(index: Int) {
        titleLabel.text = practiceInfoList[index].title
        descriptionLabel.text = practiceInfoList[index].description
        pageControl.currentPage = index
    }
}

extension PracticeExplainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        updateOnboardingComponent(index: Int(round(value)))
    }
}
