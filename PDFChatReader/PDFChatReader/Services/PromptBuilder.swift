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
        Ты — полезный помощник.
        Отвечай строго на основе предоставленного текста из PDF.
        Если информации в тексте недостаточно — задай короткий уточняющий вопрос.
        Отвечай кратко, логично и структурировано.
        """
    }
    
    func quickActionPrompt(
        _ action: QuickAction,
        context: String
    ) -> String {
        switch action {
        case .summarize:
            return """
            Контекст (текст страницы PDF):
            \(context)
            
            Задача: Сформулируй краткое резюме страницы в виде 5–7 пунктов.
            """
            
        case .explain:
            return """
            Контекст (текст страницы PDF):
            \(context)
            
            Задача: Объясни содержание простым и понятным языком,
            как если бы ты объяснял новичку. Используй короткие абзацы.
            """
            
        case .keyPoints:
            return """
            Контекст (текст страницы PDF):
            \(context)
            
            Задача:
            1) Выдели ключевые идеи (в виде списка)
            2) Выдели важные термины (термин — краткое определение)
            """
        }
    }
    
    func chatPrompt(
        question: String,
        context: String
    ) -> String {
        """
        Контекст (текст страницы PDF):
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
