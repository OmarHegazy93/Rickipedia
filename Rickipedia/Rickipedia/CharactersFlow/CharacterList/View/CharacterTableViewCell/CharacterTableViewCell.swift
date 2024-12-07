//
//  CharacterTableViewCell.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import UIKit
import SwiftUI

final class CharacterTableViewCell: UITableViewCell {
    private var hostingController: UIHostingController<CharacterCellView>?

    func configure(imageURL: URL?, name: String, species: String) {
        let swiftUIView = CharacterCellView(imageURL: imageURL, name: name, species: species)
        
        if hostingController == nil {
            let hostingController = UIHostingController(rootView: swiftUIView)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            contentView.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            self.hostingController = hostingController
        } else {
            hostingController?.rootView = swiftUIView
        }
    }
}
