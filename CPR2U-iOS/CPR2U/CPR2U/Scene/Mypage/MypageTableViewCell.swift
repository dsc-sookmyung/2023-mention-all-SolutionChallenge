//
//  MypageTableViewCell.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import UIKit

final class MypageTableViewCell: UITableViewCell {
    static let identifier = "MypageTableViewCell"
    
    var icon: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 16)
        label.textAlignment = .left
        return label
    }()
    
    var chevron: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: MypageTableViewCell.identifier)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setUpConstraints() {
        [
            icon,
            label,
            chevron,
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            icon.widthAnchor.constraint(equalToConstant: 17),
            icon.heightAnchor.constraint(equalToConstant: 21),
        ])
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 17),
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            label.widthAnchor.constraint(equalToConstant: 180),
            label.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
