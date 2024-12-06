//
//  CharacterCellViewWrapper.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//


import SwiftUI

struct CharacterCellViewWrapper: UIViewRepresentable {
    let image: UIImage
    let title: String
    let subtitle: String

    func makeUIView(context: Context) -> UIView {
        let view = UIHostingController(rootView: CharacterCellView(image: image, name: title, species: subtitle))
        view.view.backgroundColor = .clear // Make background transparent
        return view.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No additional updates needed
    }
}
