//
//  CharacterDetailsVM.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 07/12/2024.
//

import Combine
import Foundation

final class CharacterDetailsVM: ObservableObject {
    let character: CharacterDetails
    private let coordinator: CharacterDetailsCoordinatorProtocol
    
    init(character: CharacterDetails, coordinator: CharacterDetailsCoordinatorProtocol) {
        self.character = character
        self.coordinator = coordinator
    }
    
    func dismiss() {
        coordinator.dismissDetails()
    }
}
        
