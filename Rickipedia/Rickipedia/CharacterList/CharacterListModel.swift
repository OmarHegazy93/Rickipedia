//
//  CharacterListModel.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

// MARK: CharacterListModel
struct CharacterListModel: Codable {
    let info: Info
    let characters: [CharacterDetails]
    
    enum CodingKeys: String, CodingKey {
        case info
        case characters = "results"
    }
}

// MARK: - Info
struct Info: Codable {
    let count: Int
    let next: String?
    let pages: Int
    let prev: String?
}
