//
//  ChatViewModel.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation
import Combine
import UIKit

@MainActor
final class ChatViewModel: ObservableObject {

    enum AssistantAction {
        case copy
        case regenerate
        case explainSimpler
    }

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

        Task { [weak self] in
            await self?.send(system: system, user: user, displayUserText: nil)
        }
    }

    func sendUserQuestion() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        inputText = ""

        let context = contextProvider()
        guard !context.isEmpty else {
            errorText = "No text found on this page."
            return
        }

        let system = promptBuilder.systemPrompt()
        let user = promptBuilder.chatPrompt(question: question, context: context)

        Task { [weak self] in
            await self?.send(system: system, user: user, displayUserText: question)
        }
    }

    func handleAssistantAction(_ action: AssistantAction, message: ChatMessage) {
        switch action {
        case .copy:
            UIPasteboard.general.string = message.text

        case .regenerate:
            Task { [weak self] in
                await self?.regenerate(messageId: message.id)
            }

        case .explainSimpler:
            Task { [weak self] in
                await self?.explainSimpler(messageId: message.id)
            }
        }
    }

    // MARK: - Private

    private func send(
        system: String,
        user: String,
        displayUserText: String?
    ) async {
        isLoading = true
        errorText = nil

        if let displayUserText {
            messages.append(ChatMessage(role: .user, text: displayUserText))
        } else {
            messages.append(ChatMessage(role: .user, text: user))
        }

        let request = ChatMessage.Request(
            systemPrompt: system,
            userPrompt: user,
            temperature: 0.3,
            maxTokens: 900
        )

        do {
            let response = try await gpt.complete(
                modelUri: modelUri,
                messages: [
                    ChatMessage(role: .system, text: system),
                    ChatMessage(role: .user, text: user)
                ],
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages.append(
                ChatMessage(role: .assistant, text: response, request: request)
            )
            isLoading = false
        } catch {
            errorText = error.localizedDescription
            isLoading = false
        }
    }

    private func regenerate(messageId: UUID) async {
        guard !isLoading else { return }
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
        guard messages[index].role == .assistant else { return }
        guard let request = messages[index].request else {
            errorText = "Cannot regenerate: no request metadata for this message."
            return
        }

        isLoading = true
        errorText = nil

        do {
            let response = try await gpt.complete(
                modelUri: modelUri,
                messages: [
                    ChatMessage(role: .system, text: request.systemPrompt),
                    ChatMessage(role: .user, text: request.userPrompt)
                ],
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages[index].text = response
            isLoading = false
        } catch {
            errorText = error.localizedDescription
            isLoading = false
        }
    }

    private func explainSimpler(messageId: UUID) async {
        guard !isLoading else { return }
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
        guard messages[index].role == .assistant else { return }
        guard let request = messages[index].request else {
            errorText = "Cannot explain simpler: no request metadata for this message."
            return
        }

        isLoading = true
        errorText = nil

        let userPrompt = promptBuilder.explainSimplerUserPrompt(baseUserPrompt: request.userPrompt)

        do {
            let response = try await gpt.complete(
                modelUri: modelUri,
                messages: [
                    ChatMessage(role: .system, text: request.systemPrompt),
                    ChatMessage(role: .user, text: userPrompt)
                ],
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages[index].text = response
            messages[index].request = ChatMessage.Request(
                systemPrompt: request.systemPrompt,
                userPrompt: userPrompt,
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )
            isLoading = false
        } catch {
            errorText = error.localizedDescription
            isLoading = false
        }
    }
}
