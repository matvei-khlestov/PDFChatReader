//
//  ServiceError.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 04.01.2026.
//

import Foundation

enum ServiceError: LocalizedError {

    case badURL
    case httpError(statusCode: Int, body: String)
    case decodingFailed
    case emptyResult

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL."
        case let .httpError(statusCode, body):
            return "Request failed with status \(statusCode). \(body)"
        case .decodingFailed:
            return "Failed to decode server response."
        case .emptyResult:
            return "Empty response from model."
        }
    }
}
