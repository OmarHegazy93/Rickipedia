//
//  DataParserProtocol.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 04/12/2024.
//

import Foundation

/// Protocol defining the Data Parser
protocol DataParserProtocol {
    /// Parses the given data into a Decodable object
    /// - Parameter data: The data to be parsed
    /// - Returns: A result containing either the decoded object or a parsing error
    func parse<T: Decodable>(_ data: Data) -> Result<T, ParsingError>
}

/// Implementation of the Data Parser conforming to `DataParserProtocol`
final class DataParser: DataParserProtocol {
    /// The JSON decoder used for decoding data
    private let decoder: JSONDecoder
    
    /// Initializer with dependency injection for JSONDecoder
    /// - Parameter decoder: The JSON decoder to use, defaults to `JSONDecoder` with snake case key decoding strategy
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func parse<T: Decodable>(_ data: Data) -> Result<T, ParsingError> {
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            return .success(decodedObject)
        } catch {
            print("❌ DataParser: error occurred while decoding data: \(error.localizedDescription)")
            return .failure(.invalidData(error))
        }
    }
}
