//
//  CharacterListVM.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import Foundation
import Combine

struct FilterItem {
    let type: Status
    var isSelected: Bool
}

final class CharacterListVM: ObservableObject {
    private var cashedCharacters: [CharacterDetails] = []
    @Published private(set) var characters: [CharacterDetails] = []
    @Published private(set) var error: RequestError?
    @Published private(set) var isLoading = false
    private var selectedFilter: Status?
    
    var currentPage = 1
    
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    func fetchCharacters() {
        isLoading = true
        Task {[unowned self] in
            let responseResult: Result<CharacterListModel, RequestError> = await requestManager.perform(CharacterListRequest.characters(currentPage, selectedFilter?.rawValue ?? ""))
            
            isLoading = false
            switch responseResult {
            case .success(let requestModel):
                if let firstID = requestModel.characters.first?.id,
                characters.contains(where: { $0.id == firstID }) {
                    return
                }
                cashedCharacters.append(contentsOf: requestModel.characters)
                characters.append(contentsOf: requestModel.characters)
            case .failure(let requestError):
                error = requestError
            }
        }
    }
    
    func filter(by newFilter: Status) {
        selectedFilter = newFilter
        characters = cashedCharacters.filter { $0.status == newFilter }
    }
    
    func removeFilter() {
        selectedFilter = nil
        characters = cashedCharacters
    }
}
