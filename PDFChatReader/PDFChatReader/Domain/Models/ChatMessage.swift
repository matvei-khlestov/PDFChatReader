//
//  ChatMessage.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {

    enum Role: String {
        case user
        case assistant
        case system
    }

    struct Request: Equatable {
        let systemPrompt: String
        let userPrompt: String
        let temperature: Double
        let maxTokens: Int
    }

    let id: UUID
    let role: Role
    var text: String
    let createdAt: Date
    var request: Request?

    init(
        id: UUID = UUID(),
        role: Role,
        text: String,
        createdAt: Date = Date(),
        request: Request? = nil
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.request = request
    }
}
