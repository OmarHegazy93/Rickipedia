//
//  CharacterDetails.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

// MARK: CharacterDetails
struct CharacterDetails: Codable {
    let created: String
    let episode: [String]
    let gender: Gender
    let id: Int
    let image: String
    let location: Location
    let name: String
    let origin: Origin
    let species: String
    let status: Status
    let type: String
    let url: String
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case unknown = "unknown"
}

// MARK: - Location
struct Location: Codable {
    let name: String
    let url: String
}

// MARK: - Origin
struct Origin: Codable {
    let name: String
    let url: String
}

enum Status: String, Codable, CaseIterable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}
