//
//  CharacterCellView.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//


import SwiftUI

struct CharacterCellView: View {
    let imageURL: URL?
    let name: String
    let species: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: imageURL) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo.fill")
                    .resizable()
            }
            .scaledToFit()
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            .padding(4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(species)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}
