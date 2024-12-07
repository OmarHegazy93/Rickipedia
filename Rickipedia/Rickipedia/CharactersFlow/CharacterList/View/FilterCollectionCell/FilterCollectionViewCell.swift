//
//  FilterCollectionViewCell.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import UIKit

final class FilterCollectionViewCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = contentView.frame.height / 2
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        label.text = text
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .gray : .white
            label.textColor = isSelected ? .white : .black
        }
    }
}
