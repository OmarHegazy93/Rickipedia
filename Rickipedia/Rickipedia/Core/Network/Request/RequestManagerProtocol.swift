//
//  RequestManagerProtocol.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

/// Protocol defining the Request Manager
public protocol RequestManagerProtocol {
    /// Performs a network request and parses the response
    /// - Parameters:
    ///   - request: The request to be performed, conforming to `RequestProtocol`
    /// - Returns: result containing either a decoded object or a request error
    func perform<T: Decodable>(_ request: RequestProtocol) async -> Result<T, RequestError>
}

/// Implementation of the Request Manager conforming to `RequestManagerProtocol`
final class RequestManager: RequestManagerProtocol {
    /// The API manager used to perform network requests
    private let apiManager: APIManagerProtocol
    /// The data parser used to parse the response data
    private let parser: DataParserProtocol
    
    public static let shared = RequestManager()
    
    /// Initializer with dependency injection for APIManager and DataParser
    /// - Parameters:
    ///   - apiManager: The API manager to use, defaults to `APIManager`
    ///   - parser: The data parser to use, defaults to `DataParser`
    init(
        apiManager: APIManagerProtocol = APIManager(),
        parser: DataParserProtocol = DataParser()
    ) {
        self.apiManager = apiManager
        self.parser = parser
    }
    
    func perform<T: Decodable>(_ request: RequestProtocol) async -> Result<T, RequestError> {
        // Perform the network request using the API manager
        let result = await apiManager.perform(request)
        
        switch result {
        case .success(let data):
            let parseResult: Result<T, ParsingError> = self.parser.parse(data)
            switch parseResult {
            case .success(let model):
                // Return the parsed model on success
                return .success(model)
            case .failure(let error):
                // Return a parsing error on failure
                return .failure(.parsingError(error))
            }
        case .failure(let networkError):
            return .failure(.networkError(networkError))
        }
    }
}
