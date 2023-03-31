//
//  TabBarViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/22.
//

import UIKit

final class TabBarViewController: UITabBarController {

    init(_ selectedIndex: Int = 1) {
        super.init(nibName: nil, bundle: nil)
        self.selectedIndex = selectedIndex
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTabBar()
    }

    private func setUpTabBar() {
        self.tabBar.backgroundColor = .white
        
        let educationVC = EducationMainViewController(viewModel: EducationViewModel())
        let callVC = CallMainViewController(viewModel: CallViewModel())
        let mypageVC = MypageViewController(viewModel: EducationViewModel())
        
        educationVC.title = "Education"
        callVC.title = "Call"
        mypageVC.title = "Profile"
        
        educationVC.tabBarItem.image = UIImage.init(systemName: "book")
        callVC.tabBarItem.image = UIImage.init(systemName: "bell")
        mypageVC.tabBarItem.image = UIImage.init(systemName: "person")
        
        educationVC.navigationItem.largeTitleDisplayMode = .always
        mypageVC.navigationItem.largeTitleDisplayMode = .always
        
        let navigationEdu = UINavigationController(rootViewController: educationVC)
        let navigationCall = UINavigationController(rootViewController: callVC)
        let navigationMypage = UINavigationController(rootViewController: mypageVC)
        
        
        navigationEdu.navigationBar.prefersLargeTitles = true
        navigationCall.navigationBar.isHidden = true
        navigationMypage.navigationBar.prefersLargeTitles = true
        
        setViewControllers([navigationEdu, navigationCall, navigationMypage], animated: false)
    }
}
