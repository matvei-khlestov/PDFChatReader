//
//  PromptBuilder.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

struct PromptBuilder {
    func systemPrompt() -> String {
        """
        You are a helpful assistant. Answer strictly using the provided PDF context.
        If the context is insufficient, ask a short clarifying question.
        Keep the answer concise and well-structured.
        """
    }

    func quickActionPrompt(_ action: QuickAction, context: String) -> String {
        switch action {
        case .summarize:
            return """
            Context (PDF page text):
            \(context)

            Task: Summarize the page in 5-7 bullet points.
            """
        case .explain:
            return """
            Context (PDF page text):
            \(context)

            Task: Explain the content in simple terms (as if to a beginner), using short paragraphs.
            """
        case .keyPoints:
            return """
            Context (PDF page text):
            \(context)

            Task: Extract key points and important terms. Output:
            1) Key points (bullets)
            2) Important terms (term — short definition)
            """
        }
    }

    func chatPrompt(question: String, context: String) -> String {
        """
        Context (PDF page text):
        \(context)

        Question:
        \(question)
        """
    }
}
