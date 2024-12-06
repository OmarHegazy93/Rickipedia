//
//  RequestProtocol.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import Foundation

/// Protocol defining a network request
public protocol RequestProtocol {
    /// The path of the request
    var path: String { get }
    /// The type of the request (GET, POST, etc.)
    var requestType: RequestType { get }
    /// The headers to be included in the request
    var headers: [String: String] { get }
    /// The parameters to be included in the request body
    var params: [String: Any] { get }
    /// The URL parameters to be included in the request URL
    var urlParams: [String: String?] { get }
    /// A flag indicating whether an authorization token should be added
    var addAuthorizationToken: Bool { get }
}

// MARK: - Default RequestProtocol Implementation
public extension RequestProtocol {
    /// The host for the request, defaulting to the value from `APIConstants`
    var host: String {
        APIConstants.host
    }
    
    /// A flag indicating whether an authorization token should be added, defaulting to `true`
    var addAuthorizationToken: Bool {
        true
    }
    
    /// The parameters to be included in the request body, defaulting to an empty dictionary
    var params: [String: Any] {
        [:]
    }
    
    /// The URL parameters to be included in the request URL, defaulting to an empty dictionary
    var urlParams: [String: String?] {
        [:]
    }
    
    /// The headers to be included in the request, defaulting to an empty dictionary
    var headers: [String: String] {
        [:]
    }
    
    /// Creates a `URLRequest` from the current properties
    /// - Throws: `NetworkError.invalidURL` if the URL could not be created
    /// - Returns: A configured `URLRequest`
    func createURLRequest() throws -> URLRequest {
        // Configure URL components
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        
        // Add URL parameters
        if !urlParams.isEmpty {
            components.queryItems = urlParams.map { URLQueryItem(name: $0, value: $1) }
        }
        
        // Ensure URL is valid
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        // Create URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue
        
        // Add headers
        if !headers.isEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }
        
        // Set Content-Type to application/json
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add request body parameters
        if !params.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params)
        }
        
        return urlRequest
    }
}

