//
//  APIManagerProtocol.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import Foundation

/// Protocol defining the API Manager
protocol APIManagerProtocol {
    /// Performs a network request asynchronously
    /// - Parameter request: The request to be performed, conforming to `RequestProtocol`
    /// - Returns: A result containing either data or a network error
    func perform(_ request: RequestProtocol) async -> Result<Data, NetworkError>
}

/// Implementation of the API Manager conforming to `APIManagerProtocol`
final class APIManager: APIManagerProtocol {
    /// URLSession instance used for making network requests
    private let urlSession: URLSession
    
    /// Initializer with dependency injection for URLSession
    /// - Parameter urlSession: The URLSession instance to use, defaults to `URLSession.shared`
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func perform(_ request: RequestProtocol) async -> Result<Data, NetworkError> {
        
        // Attempt to create a URL request from the provided request protocol
        guard let url = try? request.createURLRequest() else {
            return .failure(NetworkError.invalidURL)
        }
        
        // Perform the network request asynchronously
        do {
            let (data, response) = try await urlSession.data(for: url)
            
            // Validate the HTTP response status code
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("❌ NetworkLibrary: unexpected status code: \(statusCode)")
                return .failure(NetworkError.unexpectedStatusCode(statusCode))
            }
            
            // Ensure data is not empty
            guard !data.isEmpty else {
                print("❌ NetworkLibrary: no data returned from server")
                return .failure(NetworkError.noData)
            }
            
            return .success(data)
        } catch {
            print("❌ NetworkLibrary: error while fetching data: \(error)")
            return .failure(NetworkError.invalidServerResponse)
        }
    }
}

