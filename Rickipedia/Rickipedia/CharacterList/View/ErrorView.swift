//
//  ErrorView.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 06/12/2024.
//


import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Something went wrong!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("Retry")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
