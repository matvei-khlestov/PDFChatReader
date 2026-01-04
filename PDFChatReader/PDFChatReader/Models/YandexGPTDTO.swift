//
//  YandexGPTDTO.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

// MARK: - Request

struct YandexGPTCompletionRequest: Encodable {
    
    let modelUri: String
    let completionOptions: CompletionOptions
    let messages: [Message]
    
    struct CompletionOptions: Encodable {
        let stream: Bool
        let temperature: Double
        let maxTokens: Int
    }
    
    struct Message: Encodable {
        let role: String
        let text: String
    }
}

// MARK: - Response

struct YandexGPTCompletionResponse: Decodable {
    
    let result: Result?
    
    struct Result: Decodable {
        let alternatives: [Alternative]?
    }
    
    struct Alternative: Decodable {
        let message: Message?
    }
    
    struct Message: Decodable {
        let role: String?
        let text: String?
    }
}
