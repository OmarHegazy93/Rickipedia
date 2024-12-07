//
//  CharactersFlowCoordinator.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 07/12/2024.
//

import UIKit
import SwiftUI

protocol CharacterDetailsCoordinatorProtocol {
    func dismissDetails()
}
    
protocol CharactersListCoordinatorProtocol {
    func showCharacterDetails(for character: CharacterDetails)
}

final class CharactersFlowCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let charactersListVM = CharacterListVM(coordinator: self)
        let charactersListViewController = CharacterListVC(viewModel: charactersListVM)
        navigationController.pushViewController(charactersListViewController, animated: false)
    }
}

extension CharactersFlowCoordinator: CharactersListCoordinatorProtocol {
    func showCharacterDetails(for character: CharacterDetails) {
        let detailsVM = CharacterDetailsVM(character: character, coordinator: self)
        let DetailsView = CharacterDetailsView(viewModel: detailsVM)
        
        let detailsHostingVC = UIHostingController(rootView: DetailsView)
        navigationController.pushViewController(detailsHostingVC, animated: true)
    }
}

extension CharactersFlowCoordinator: CharacterDetailsCoordinatorProtocol {
    func dismissDetails() {
        navigationController.popViewController(animated: true)
    }
}
