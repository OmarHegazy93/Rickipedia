//
//  RickipediaTests.swift
//  RickipediaTests
//
//  Created by Omar Hegazy on 03/12/2024.
//

import Testing
import Foundation
@testable import Rickipedia

struct CharacterListVMTests {
    func makeCharacterListVM(response: Data = Data(), error: NetworkError? = nil) -> CharacterListVM {
        let requestManager = RequestManager(apiManager: ApiManagerMock(data: response, error: error))
        return CharacterListVM(requestManager: requestManager)
    }
        
    @Test("Test fetchCharacters with successful request")
    func verifySuccessfulRequest() async throws {
        let fetchedData = try JSONEncoder().encode(generateRequestModel())
        let characterViewModel = makeCharacterListVM(response: fetchedData)
        try await #require(characterViewModel.characters.isEmpty)
        
        await characterViewModel.fetchCharacters()
        await #expect(characterViewModel.error == nil)
    }
    
    @Test(
        .tags(.networkError),
        arguments: [
            NetworkError.invalidServerResponse,
            .invalidURL,
            .noData,
            .noInternetConnection,
            .unexpectedStatusCode(500)
        ]
    )
    func verifyNetworkError(_ expectedError: NetworkError) async throws {
        let characterViewModel = makeCharacterListVM(error: expectedError)
        try await #require(characterViewModel.error == nil)
        await characterViewModel.fetchCharacters()
        
        let receivedError = try #require(await characterViewModel.error)
        if case .networkError(let networkErrorType) = receivedError {
            #expect(networkErrorType == expectedError)
        } else {
            Issue.record("Expected network error, but got \(receivedError)")
        }
    }
    
    @Test("fetchCharacters with network error code 404, means no more data", .tags(.networkError))
    func verifyNetworkErrorWithCode404() async throws {
        let characterViewModel = makeCharacterListVM(error: .unexpectedStatusCode(404))
        try await #require(characterViewModel.error == nil)
        
        try #require(characterViewModel.hasMoreData == true)
        await characterViewModel.fetchCharacters()
        
        await #expect(characterViewModel.error == nil)
        #expect(characterViewModel.hasMoreData == false)
    }
    
    @Test("Test fetchCharacters with parsing error", .tags(.parsingError))
    func verifyParsingError() async throws {
        let characterViewModel = makeCharacterListVM(response: "invalid data".data(using: .utf8)!)
        try await #require(characterViewModel.error == nil)
        
        await characterViewModel.fetchCharacters()
        
        let receivedError = try #require(await characterViewModel.error)
        
        if case .parsingError = receivedError {
            #expect(true)
        } else {
            Issue.record("Expected parsing error, but found \(receivedError)")
        }
    }
    
    @Test("Given current list has 20 characters, when fetching next characters page, then character list count will be 40", .tags(.pagination))
    func verifyFetchingSecondCharacterPage() async throws {
        let firstPageData = try JSONEncoder().encode(generateRequestModel(atPage: 1))
        let apiManager = ApiManagerMock(data: firstPageData, error: nil)
        let requestManager = RequestManager(apiManager: apiManager)
        let characterViewModel = CharacterListVM(requestManager: requestManager)
        
        try await #require(characterViewModel.characters.isEmpty)
        
        await characterViewModel.fetchCharacters()
        await #expect(characterViewModel.characters.count == 20)
        
        let secondPageData = try JSONEncoder().encode(generateRequestModel(atPage: 2))
        apiManager.data = secondPageData
        
        await characterViewModel.fetchCharacters()
        await #expect(characterViewModel.characters.count == 40)
    }
    
    @Test("When no more characters to fetch, then hasMoreData property should be false", .tags(.pagination))
    func verifyFetchingLastCharacterPage() async throws {
        let lastPageData = try JSONEncoder().encode(generateRequestModel(isLastPage: true, atPage: 1))
        let apiManager = ApiManagerMock(data: lastPageData, error: nil)
        let requestManager = RequestManager(apiManager: apiManager)
        let characterViewModel = CharacterListVM(requestManager: requestManager)
        
        try await #require(characterViewModel.characters.isEmpty)
        try #require(characterViewModel.hasMoreData == true)
        
        await characterViewModel.fetchCharacters()
        await #expect(characterViewModel.characters.count == 20)
        #expect(characterViewModel.hasMoreData == false)
        
        let afterLastPageData = try JSONEncoder().encode(generateRequestModel(atPage: 100))
        apiManager.data = afterLastPageData
        
        await characterViewModel.fetchCharacters()
        await #expect(characterViewModel.characters.count == 20)
        #expect(characterViewModel.hasMoreData == false)
    }
    
    @Test(
        "When fetching characters with selected filter, then only characters with that filter should be displayed",
        .tags(.filtration),
        arguments: [Status.alive, .dead, .unknown]
    )
    func verifyFilteringCharacters(_ selectedFilter: Status) async throws {
        let model = generateRequestModel()
        let response = try JSONEncoder().encode(model)
        let characterViewModel = makeCharacterListVM(response: response)
        
        await characterViewModel.fetchCharacters()
        await characterViewModel.filter(by: selectedFilter)
        let filteredCharacters = model.characters.filter { $0.status == selectedFilter }
        await #expect(characterViewModel.characters.count == filteredCharacters.count)
        
        await characterViewModel.removeFilter()
        await #expect(characterViewModel.characters.count == model.characters.count)
    }
}
