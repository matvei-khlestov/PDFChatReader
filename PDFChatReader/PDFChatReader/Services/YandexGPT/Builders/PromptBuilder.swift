//
//  PromptBuilder.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

struct PromptBuilder: PromptBuilding {

    func systemPrompt() -> String {
        """
        Ты — полезный помощник.
        Отвечай строго на основе предоставленного текста из PDF.
        Если информации в тексте недостаточно — задай короткий уточняющий вопрос.
        Отвечай кратко, логично и структурировано.
        """
    }

    func quickActionPrompt(
        _ action: QuickAction,
        context: String,
        scope: ChatScope
    ) -> String {
        switch action {
        case .summarize:
            return """
            Контекст (\(scope.rawValue)):
            \(context)

            Задача: Сформулируй краткое резюме в виде 5–7 пунктов.
            """

        case .explain:
            return """
            Контекст (\(scope.rawValue)):
            \(context)

            Задача: Объясни содержание простым и понятным языком,
            как если бы ты объяснял новичку. Используй короткие абзацы.
            """

        case .keyPoints:
            return """
            Контекст (\(scope.rawValue)):
            \(context)

            Задача:
            1) Выдели ключевые идеи (в виде списка)
            2) Выдели важные термины (термин — краткое определение)
            """
        }
    }

    func chatPrompt(
        question: String,
        context: String,
        scope: ChatScope
    ) -> String {
        """
        Контекст (\(scope.rawValue)):
        \(context)

        Вопрос пользователя:
        \(question)
        """
    }

    func explainSimplerUserPrompt(baseUserPrompt: String) -> String {
        """
        \(baseUserPrompt)

        Дополнительная задача:
        Объясни проще, максимально понятно новичку. 3–6 коротких предложений.
        Если нужно — приведи простой пример.
        """
    }
}
