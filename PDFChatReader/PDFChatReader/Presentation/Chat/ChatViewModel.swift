//
//  ChatViewModel.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorText: String?
    
    private let gpt: YandexGPTServicing
    private let promptBuilder: PromptBuilder
    private let modelUri: String
    private let contextProvider: () -> String
    
    init(
        gpt: YandexGPTServicing,
        modelUri: String,
        contextProvider: @escaping () -> String,
        promptBuilder: PromptBuilder = PromptBuilder()
    ) {
        self.gpt = gpt
        self.modelUri = modelUri
        self.contextProvider = contextProvider
        self.promptBuilder = promptBuilder
        
        self.messages = [
            ChatMessage(
                role: .assistant,
                text: "Ask about the current PDF page, or use quick actions below."
            )
        ]
    }
    
    func runQuickAction(_ action: QuickAction) {
        let context = contextProvider()
        guard !context.isEmpty else {
            errorText = "No text found on this page."
            return
        }
        
        let system = promptBuilder.systemPrompt()
        let user = promptBuilder.quickActionPrompt(action, context: context)
        
        Task {
            await send(system: system, user: user)
        }
    }
    
    func sendUserQuestion() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        
        inputText = ""
        
        let context = contextProvider()
        if context.isEmpty {
            errorText = "No text found on this page."
            return
        }
        
        let system = promptBuilder.systemPrompt()
        let user = promptBuilder.chatPrompt(question: question, context: context)
        
        Task {
            await send(system: system, user: user, displayUserText: question)
        }
    }
    
    private func send(
        system: String,
        user: String,
        displayUserText: String? = nil
    ) async {
        await MainActor.run {
            self.isLoading = true
            self.errorText = nil
            
            if let displayUserText {
                self.messages.append(
                    ChatMessage(role: .user, text: displayUserText)
                )
            } else {
                self.messages.append(
                    ChatMessage(role: .user, text: user)
                )
            }
        }
        
        do {
            let response = try await gpt.complete(
                modelUri: modelUri,
                messages: [
                    ChatMessage(role: .system, text: system),
                    ChatMessage(role: .user, text: user)
                ],
                temperature: 0.3,
                maxTokens: 900
            )
            
            await MainActor.run {
                self.messages.append(
                    ChatMessage(role: .assistant, text: response)
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorText = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
