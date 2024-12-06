//
//  CharacterCellView.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//


import SwiftUI

struct CharacterCellView: View {
    let image: UIImage
    let name: String
    let species: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60) // Square image
                .cornerRadius(8)
                .padding(4) // Padding between the image and the border
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline) // Bold for the title
                Text(species)
                    .font(.subheadline)
                    .foregroundColor(.gray) // Subtitle styling
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Align with the top of the image
        }
        .padding(.vertical, 8) // Add vertical padding to the cell
    }
}
