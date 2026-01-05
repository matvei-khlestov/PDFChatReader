//
//  PromptBuilding.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol PromptBuilding {
    func systemPrompt() -> String
    func quickActionPrompt(_ action: QuickAction, context: String, scope: ChatScope) -> String
    func chatPrompt(question: String, context: String, scope: ChatScope) -> String
    func explainSimplerUserPrompt(baseUserPrompt: String) -> String
}
