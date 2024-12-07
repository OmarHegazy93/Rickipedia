//
//  CharacterListRequest.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

enum CharacterListRequest: RequestProtocol {
    /// Request to get character list
    case characters(Int, String)
    
    /// The path for the request
    var path: String {
        "/api/character"
    }
    
    /// The URL parameters for the request
    var urlParams: [String: String?] {
        switch self {
        case .characters(let page, let status):
            [
                "page": "\(page)",
                "status": status
            ]
        }
    }
    
    /// The HTTP method for the request
    var requestType: RequestType {
        .GET
    }
}
