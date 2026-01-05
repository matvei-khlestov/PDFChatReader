//
//  DefaultHTTPResponseValidator.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

struct DefaultHTTPResponseValidator: HTTPResponseValidating {
    
    // MARK: - Constants
    
    private let maxErrorBodyLength: Int
    
    // MARK: - Init
    
    init(maxErrorBodyLength: Int = 600) {
        self.maxErrorBodyLength = maxErrorBodyLength
    }
    
    // MARK: - Public
    
    func validate(data: Data, response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw ServiceError.httpError(
                statusCode: -1,
                body: "No HTTP response."
            )
        }
        
        guard (200...299).contains(http.statusCode) else {
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            let trimmed = bodyString.trimmingCharacters(in: .whitespacesAndNewlines)
            let shortBody = String(trimmed.prefix(maxErrorBodyLength))
            
            throw ServiceError.httpError(
                statusCode: http.statusCode,
                body: shortBody
            )
        }
    }
}
