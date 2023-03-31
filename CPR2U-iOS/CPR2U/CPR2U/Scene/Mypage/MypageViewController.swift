//
//  MypageViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import Combine
import UIKit

final class MypageViewController: UIViewController {

    private lazy var mypageStatusView: MypageStatusView = {
        let view = MypageStatusView(viewModel: viewModel)
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .insetGrouped)
        view.backgroundColor = .white
        view.sectionHeaderTopPadding = 0
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private var statusViewBottomAnchor: NSLayoutConstraint?
    
    private var viewModel: EducationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    let sectionHeader = ["History", "etc", ""]
    var cellDataSource = [["Dispatch History", "Call History"], ["Developer Information", "Liscence"], ["Logout"]]
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
        setUpTableView()
        bind(viewModel: viewModel)
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        [
            mypageStatusView,
            tableView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            mypageStatusView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space18),
            mypageStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mypageStatusView.widthAnchor.constraint(equalToConstant: 358),
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mypageStatusView.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: 358),
            tableView.heightAnchor.constraint(equalToConstant: 390)
        ])
    }
    
    private func setUpStyle() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.prefersLargeTitles = true
        navBar.topItem?.title = "Profile"
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainRed]
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setUpTableView() {
        tableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bind(viewModel: EducationViewModel) {
        Task {
            let output = try await viewModel.transform()
            output.certificateStatus?.sink { [self] certificate in
                statusViewBottomAnchor = mypageStatusView.heightAnchor.constraint(equalToConstant: certificate
                    .status == .acquired ? 222 : 124)
                statusViewBottomAnchor?.isActive = true
                mypageStatusView.setUpStatusComponent(certificate: certificate)
                
            }.store(in: &cancellables)
            
            output.nickname?.sink { nickname in
                self.mypageStatusView.setUpGreetingLabel(nickname: nickname)
            }.store(in: &cancellables)
        }
    }
}

extension MypageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return sectionHeader.count
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sectionHeader[section]
        }

        // MARK: - Row Cell
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cellDataSource[section].count
        }

    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: MypageTableViewCell.identifier, for: indexPath) as! MypageTableViewCell

            cell.backgroundColor = UIColor(rgb: 0xF2F3F6)
            cell.label.text = cellDataSource[indexPath.section][indexPath.row]
            print(cellDataSource[indexPath.section][indexPath.row])
            
            if indexPath.section == 2 && indexPath.row == 0 {
                cell.label.textAlignment = .center
                cell.label.textColor = .mainRed
            } else {
                cell.icon.image = UIImage(named:"book.png")
                cell.label.textColor = .black
                cell.chevron.image = UIImage(systemName: "chevron.right")?.withTintColor(.black).withRenderingMode(.alwaysOriginal)
            }
            
            return cell
        }
}
