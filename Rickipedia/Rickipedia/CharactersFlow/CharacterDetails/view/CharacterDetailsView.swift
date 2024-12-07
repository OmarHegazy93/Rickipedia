//
//  CharacterDetailsView.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 06/12/2024.
//

import SwiftUI

struct CharacterDetailsView: View {
    let viewModel: CharacterDetailsVM
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    CharacterImage(url: URL(string: viewModel.character.image))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            personalInfoView(
                                name: viewModel.character.name,
                                species: viewModel.character.species,
                                gender: viewModel.character.gender.rawValue.capitalized
                            )
                            
                            Spacer()
                            
                            Text(viewModel.character.status.rawValue.capitalized)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cyan)
                                .clipShape(Capsule())
                                .padding(.top, 8)
                        }
                        
                        HStack {
                            Text("Location: ")
                                .font(.title2)
                                .bold()
                            
                            Text(viewModel.character.location.name)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            VStack {
                Button(action: {
                    viewModel.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(.circle)
                }
                .ignoresSafeArea(edges: .top)
                .padding(.top, 20)
                .padding(.leading, 8)
            }
        }
        .navigationBarHidden(true)
    }
    
    struct personalInfoView: View {
        let name: String
        let species: String
        let gender: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.title)
                    .bold()
                
                HStack {
                    Text(species)
                    Text("•")
                    Text(gender)
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
                .bold()
            }
        }
    }
    
    struct CharacterImage: View {
        let url: URL?
        
        var body: some View {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo.fill")
                    .resizable()
            }
            .scaledToFit()
            .clipShape(
                .rect(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 40,
                    bottomTrailingRadius: 40,
                    topTrailingRadius: 20
                )
            )
        }
    }
}
