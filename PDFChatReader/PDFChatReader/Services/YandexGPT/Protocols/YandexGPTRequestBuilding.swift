//
//  YandexGPTRequestBuilding.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol YandexGPTRequestBuilding {
    func makeCompletionRequest(
        baseURLString: String,
        apiKey: String,
        modelUri: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int
    ) throws -> URLRequest
}
