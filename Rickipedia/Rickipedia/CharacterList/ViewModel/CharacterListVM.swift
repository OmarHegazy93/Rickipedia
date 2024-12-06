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
    @MainActor @Published private(set) var characters: [CharacterDetails] = []
    @MainActor @Published private(set) var error: RequestError?
    @MainActor @Published private(set) var isLoading = false
    @MainActor private(set) var hasMoreData: Bool = true
    private var selectedFilter: Status?
    
    var currentPage = 1
    
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    @MainActor
    func fetchCharacters() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        error = nil
        
        Task.detached {[unowned self] in
            let responseResult: Result<CharacterListModel, RequestError> = await requestManager.perform(CharacterListRequest.characters(currentPage, selectedFilter?.rawValue ?? ""))
            
            await MainActor.run { isLoading = false }
            switch responseResult {
            case .success(let requestModel):
                if let firstID = requestModel.characters.first?.id,
                   await characters.contains(where: { $0.id == firstID }) {
                    return
                }
                cashedCharacters.append(contentsOf: requestModel.characters)
                await MainActor.run {
                    characters.append(contentsOf: requestModel.characters)
                    hasMoreData = requestModel.info.next != nil
                    currentPage += hasMoreData ? 1 : 0
                }
            case .failure(let requestError):
                if case .networkError(let networkErrType) = requestError,
                   case .unexpectedStatusCode(let errCode) = networkErrType,
                   errCode == 404 {
                    // no need to throw an error here, as per the API, 404 means that no more data to provide
                    await MainActor.run { hasMoreData = false }
                    return
                }
                await MainActor.run { error = requestError }
            }
        }
    }
    
    @MainActor func filter(by newFilter: Status) {
        selectedFilter = newFilter
        characters = cashedCharacters.filter { $0.status == newFilter }
    }
    
    @MainActor func removeFilter() {
        selectedFilter = nil
        characters = cashedCharacters
    }
}
