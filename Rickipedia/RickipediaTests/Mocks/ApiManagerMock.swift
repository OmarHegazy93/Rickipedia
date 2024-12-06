//
//  ApiManagerMock.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 05/12/2024.
//

import Foundation
@testable import Rickipedia

final class ApiManagerMock: APIManagerProtocol {
    var data: Data?
    var error: NetworkError?
    
    init(data: Data?, error: NetworkError?) {
        self.data = data
        self.error = error
    }
    
    func perform(_ request: any Rickipedia.RequestProtocol) async -> Result<Data, Rickipedia.NetworkError> {
        if let error = error {
            return .failure(error)
        }
        return .success(data ?? Data())
    }
}
