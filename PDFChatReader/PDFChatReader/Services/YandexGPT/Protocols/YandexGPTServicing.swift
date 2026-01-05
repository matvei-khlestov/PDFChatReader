//
//  YandexGPTServicing.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 04.01.2026.
//

import Foundation

protocol YandexGPTServicing {

    func complete(
        modelUri: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int
    ) async throws -> String
}
