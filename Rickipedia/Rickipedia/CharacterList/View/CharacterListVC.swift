//
//  CharacterListVC.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 03/12/2024.
//

import UIKit

final class CharacterListVC: UIViewController {
    private let viewModel = CharacterListVM()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Characters"
        viewModel.fetchCharacters()
    }
}
