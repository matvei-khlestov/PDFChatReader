//
//  ChatCompletionServicing.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol ChatCompletionServicing {
    func complete(
        system: String,
        user: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String
}
