//
//  AutoLoginViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/21.
//

import UIKit

final class AutoLoginViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo.png")
        return view
    }()
    
    private let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpConstraints()
        setUpStyle()
        checkAutoLogin()
    }
    
    private func setUpConstraints() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 216),
            logoImageView.heightAnchor.constraint(equalToConstant: 47)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .mainRed
    }
    
    private func checkAutoLogin() {
        Task {
            do {
                let result = try await viewModel.autoLogin()
                usleep(1200000)
                if result == true {
                    let vc = TabBarViewController()
                    guard let window = self.view.window else { return }
                    await window.setRootViewController(vc, animated: true)
                } else {
                    let vc = PhoneNumberVerificationViewController(viewModel: viewModel)
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
                    self.present(navVC, animated: true)
                }
            } catch (let error) {
                print(error)
            }
        }
    }
}
