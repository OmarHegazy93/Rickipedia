//
//  NetworkError.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//


import Foundation

/// Enum representing possible network errors
public enum NetworkError: LocalizedError, Equatable {
    /// Error indicating an invalid server response
    case invalidServerResponse
    /// Error indicating an invalid URL
    case invalidURL
    /// Error indicating an unexpected status code, with the associated status code
    case unexpectedStatusCode(Int)
    /// Error indicating no data was returned from the server
    case noData
    /// Error indicating no internet connection is provided
    case noInternetConnection
    
    /// Provides a localized description for each network error
    public var errorDescription: String? {
        switch self {
        case .invalidServerResponse:
            return "The server returned an invalid response."
        case .invalidURL:
            return "URL string is malformed."
        case .unexpectedStatusCode(let code):
            return "The server returned unexpected status code \(code)"
        case .noData:
            return "No data was returned from the server"
        case .noInternetConnection:
            return "No Internet connection, please try again later"
        }
    }
}
