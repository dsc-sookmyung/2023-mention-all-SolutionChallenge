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
        NotificationCenter.default.addObserver(self, selector: #selector(showCallerPage), name: NSNotification.Name("ShowCallerPage"), object: nil)
        setUpTabBar()
    }

    private func setUpTabBar() {
        self.tabBar.backgroundColor = .white
        
        let educationVC = EducationMainViewController(viewModel: EducationViewModel())
        let callVC = CallMainViewController(viewModel: CallViewModel())
        let mypageVC = MypageViewController(authViewModel: AuthViewModel(), eduViewModel: EducationViewModel())
        
        educationVC.title = "edu_tab_t".localized()
        callVC.title = "call_tab_t".localized()
        mypageVC.title = "mypage_tab_t".localized()
        
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
    
    @objc func showCallerPage(_ notification:Notification) {
        if let userInfo = notification.userInfo {
            guard let type = userInfo["type"] as? String else { return }
            if type == "1" {
                if self.selectedIndex != 1 {
                    self.selectedIndex = 1
                }
            }
        }
    }

}
