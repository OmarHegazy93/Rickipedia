//
//  CharaterListMock.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 05/12/2024.
//

@testable import Rickipedia

func generateRequestModel(isLastPage: Bool = false, atPage number: Int = 1) -> CharacterListModel {
    let charactersList = stride(from: number * 20, through: number, by: -1)
        .prefix(20)
        .map { 
        CharacterDetails(
            created: "03/12/2024",
            episode: [],
            gender: .male,
            id: $0,
            image: "imageURL",
            location: .init(name: "Earth", url: "locationURL"),
            name: "Rick",
            origin: .init(name: "Earth", url: "originURL"),
            species: "Human",
            status: .random,
            type: "Scientist",
            url: "characterURL"
        )
    }
    
    return CharacterListModel(
        info: .init(
            count: 826,
            next: isLastPage ? nil : "https://rickandmortyapi.com/api/character?page=3",
            pages: 42,
            prev: "https://rickandmortyapi.com/api/character?page=1"
        ),
        characters: charactersList
    )
}

extension Status {
    static var random: Status {
        allCases.randomElement()!
    }
}

