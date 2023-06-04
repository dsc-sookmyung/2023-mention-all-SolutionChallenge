//
//  EducationMainViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/09.
//

import Combine
import UIKit

protocol EducationMainViewControllerDelegate: AnyObject {
    func updateUserEducationStatus(isPassed: Bool?)
}

final class EducationMainViewController: UIViewController {

    private var certificateStatusView = CertificateStatusView()
    
    private let annotationLabel: UILabel = {
        let label = UILabel()
        let color = UIColor(rgb: 0x767676)
        label.font = UIFont(weight: .regular, size: 12)
        label.textColor = color
        label.text = "angel_progress_ann_txt".localized()
        return label
    }()
    
    private let progressView = EducationProgressView()
    
    let educationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let viewModel: EducationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private weak var delegate: EducationMainViewControllerDelegate?
    
    private lazy var noticeView = CustomNoticeView(noticeAs: .certificate)
    
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
        bind(to: viewModel)
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        [
            annotationLabel,
            certificateStatusView,
            progressView,
            educationCollectionView,
            noticeView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            certificateStatusView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space8),
            certificateStatusView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            certificateStatusView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            certificateStatusView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        NSLayoutConstraint.activate([
            annotationLabel.topAnchor.constraint(equalTo: certificateStatusView.bottomAnchor, constant: make.space16),
            annotationLabel.leadingAnchor.constraint(equalTo: certificateStatusView.leadingAnchor),
            annotationLabel.widthAnchor.constraint(equalToConstant: 200),
            annotationLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: annotationLabel.bottomAnchor, constant: 28),
            progressView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            progressView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            educationCollectionView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 32),
            educationCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            educationCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            educationCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            noticeView.topAnchor.constraint(equalTo: view.topAnchor),
            noticeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpStyle() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.prefersLargeTitles = true
        navBar.topItem?.title = "edu_tab_t".localized()
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainRed]
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setUpCollectionView() {
        educationCollectionView.dataSource = self
        educationCollectionView.delegate = self
        educationCollectionView.register(EducationCollectionViewCell.self, forCellWithReuseIdentifier: EducationCollectionViewCell.identifier)
    }
    
    private func bind(to viewModel: EducationViewModel) {
        Task {
            let output = try await viewModel.transform()
            
            output.certificateStatus?.sink { status in
                self.certificateStatusView.setUpStatus(as: status.status, leftDay: status.leftDay)
                if status.status == .acquired {
                    if UserDefaultsManager.isCertificateNotice == false {
                        self.noticeView.noticeAppear()
                        UserDefaultsManager.isCertificateNotice = true
                    }
                }
            }.store(in: &cancellables)
            
            output.nickname?.sink { nickname in
                self.certificateStatusView.setUpGreetingLabel(nickname: nickname)
            }.store(in: &cancellables)
            
            viewModel.$educationCourse
                .receive(on: DispatchQueue.main)
                .sink { educationCourse in
                    let courseStatus = educationCourse.map({ $0.courseStatus.value})
                    self.progressView.setUpComponent(status: courseStatus)
                }.store(in: &cancellables)
            
            DispatchQueue.main.async {
                self.setUpCollectionView()
                self.educationCollectionView.reloadData()
            }
        }
    }
}

extension EducationMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.educationCourse.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EducationCollectionViewCell", for: indexPath) as! EducationCollectionViewCell
        
        let course = viewModel.educationCourse[indexPath.row]
        cell.setUpLabelText(name: course.info.name, description: course.info.description)
        
        viewModel.$educationCourse
            .receive(on: DispatchQueue.main)
            .sink { educationCourse in
                cell.setUpComponent(timeValue: educationCourse[indexPath.row].info.timeValue, status: educationCourse[indexPath.row].courseStatus.value)
            }.store(in: &cancellables)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let isCompleted = index != 0 ? viewModel.educationCourse[index - 1].courseStatus.value : .completed
        if isCompleted == .completed {
            navigateTo(index: index)
        } else {
            view.showToastMessage(type: .education)
        }
    }
}

extension EducationMainViewController: UICollectionViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 358
    }
}

extension EducationMainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constraints.shared.space16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 358, height: 108)
    }
    
    func navigateTo(index: Int) {
        var vc: UIViewController
        if index == 0 {
            vc = LectureViewController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let temp = EducationQuizViewController(eduViewModel: viewModel)
            temp.delegate = self
            vc = UINavigationController(rootViewController: temp)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        } else {
            vc = PracticeExplainViewController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EducationMainViewController: EducationMainViewControllerDelegate {
    
    func updateUserEducationStatus(isPassed: Bool?) {
        Task {
            if let isPassed = isPassed {
                if isPassed {
                    _ = try await viewModel.saveQuizResult()
                }
                DispatchQueue.main.async { [weak self] in
                    self?.progressView.layoutIfNeeded()
                    self?.educationCollectionView.reloadData()
                    self?.dismiss(animated: true)
                }
            }
        }
    }
}
