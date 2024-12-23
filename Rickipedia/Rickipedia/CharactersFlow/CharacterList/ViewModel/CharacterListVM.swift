//
//  CharacterListVM.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import Foundation
import Combine

final class CharacterListVM: ObservableObject {
    private var cashedCharacters: [CharacterDetails] = []
    private var selectedFilter: Status?
    private var currentPage = 1
    private let requestManager: RequestManagerProtocol
    private let coordinator: CharactersListCoordinatorProtocol
    @MainActor @Published private(set) var characters: [CharacterDetails] = []
    @MainActor @Published private(set) var error: RequestError?
    @MainActor @Published private(set) var isLoading = false
    private(set) var hasMoreData: Bool = true
    
    init(requestManager: RequestManagerProtocol = RequestManager(), coordinator: CharactersListCoordinatorProtocol) {
        self.requestManager = requestManager
        self.coordinator = coordinator
    }
    
    func fetchCharacters() async {
        guard await !isLoading && hasMoreData else { return }
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        let responseResult: Result<CharacterListModel, RequestError> = await requestManager.perform(CharacterListRequest.characters(currentPage, selectedFilter?.rawValue ?? ""))
        
        await MainActor.run { self.isLoading = false }
        switch responseResult {
        case .success(let requestModel):
            if let firstID = requestModel.characters.first?.id,
               await characters.contains(where: { $0.id == firstID }) {
                return
            }
            await MainActor.run {
                cashedCharacters.append(contentsOf: requestModel.characters)
                characters.append(contentsOf: requestModel.characters)
                hasMoreData = requestModel.info.next != nil
                currentPage += self.hasMoreData ? 1 : 0
            }
        case .failure(let requestError):
            if case .networkError(let networkErrType) = requestError,
               case .unexpectedStatusCode(let errCode) = networkErrType,
               errCode == 404 {
                // no need to throw an error here, as per the API, 404 means that no more data to provide
                await MainActor.run { self.hasMoreData = false }
                return
            }
            await MainActor.run { self.error = requestError }
        }
    }
    
    @MainActor
    func filter(by newFilter: Status) {
        selectedFilter = newFilter
        characters = cashedCharacters.filter { $0.status == newFilter }
    }
    
    @MainActor
    func removeFilter() {
        selectedFilter = nil
        characters = cashedCharacters
    }
    
    @MainActor
    func showCharacter(at index: Int) {
        let selectedCharacter = characters[index]
        coordinator.showCharacterDetails(for: selectedCharacter)
    }
}
