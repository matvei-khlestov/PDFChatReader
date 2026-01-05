//
//  YandexChatCompletionService.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

struct YandexChatCompletionService: ChatCompletionServicing {
    
    private let gpt: YandexGPTServicing
    private let modelUri: String
    
    init(gpt: YandexGPTServicing, modelUri: String) {
        self.gpt = gpt
        self.modelUri = modelUri
    }
    
    func complete(
        system: String,
        user: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        try await gpt.complete(
            modelUri: modelUri,
            messages: [
                ChatMessage(role: .system, text: system),
                ChatMessage(role: .user, text: user)
            ],
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
}
