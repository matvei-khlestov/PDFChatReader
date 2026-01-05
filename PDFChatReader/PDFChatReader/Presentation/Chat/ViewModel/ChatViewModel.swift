//
//  ChatViewModel.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//


import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Types

    enum AssistantAction {
        case copy
        case regenerate
        case explainSimpler
    }

    // MARK: - Published

    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorText: String?
    @Published var scope: ChatScope = .page

    // MARK: - Dependencies

    private let completionService: ChatCompletionServicing
    private let clipboard: ClipboardServicing
    private let promptBuilder: PromptBuilding
    private let contextProvider: (ChatScope) -> String

    // MARK: - Init

    init(
        completionService: ChatCompletionServicing,
        clipboard: ClipboardServicing,
        contextProvider: @escaping (ChatScope) -> String,
        promptBuilder: PromptBuilding
    ) {
        self.completionService = completionService
        self.clipboard = clipboard
        self.contextProvider = contextProvider
        self.promptBuilder = promptBuilder

        self.messages = [
            ChatMessage(
                role: .assistant,
                text: "Ask about the current PDF page, or use quick actions below."
            )
        ]
    }

    // MARK: - Public

    func updateScope(_ scope: ChatScope) {
        self.scope = scope
    }

    func runQuickAction(_ action: QuickAction) {
        let scopeSnapshot = scope

        let context = contextProvider(scopeSnapshot)
        guard !context.isEmpty else {
            errorText = scopeSnapshot == .page
            ? "No text found on this page."
            : "No text found in this document."
            return
        }

        let system = promptBuilder.systemPrompt()
        let user = promptBuilder.quickActionPrompt(
            action,
            context: context,
            scope: scopeSnapshot
        )

        Task { [weak self] in
            await self?.send(
                system: system,
                user: user,
                displayUserText: nil,
                scope: scopeSnapshot
            )
        }
    }

    func sendUserQuestion() {
        let scopeSnapshot = scope

        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        inputText = ""

        let context = contextProvider(scopeSnapshot)
        guard !context.isEmpty else {
            errorText = scopeSnapshot == .page
            ? "No text found on this page."
            : "No text found in this document."
            return
        }

        let system = promptBuilder.systemPrompt()
        let user = promptBuilder.chatPrompt(
            question: question,
            context: context,
            scope: scopeSnapshot
        )

        Task { [weak self] in
            await self?.send(
                system: system,
                user: user,
                displayUserText: question,
                scope: scopeSnapshot
            )
        }
    }

    func handleAssistantAction(_ action: AssistantAction, message: ChatMessage) {
        switch action {
        case .copy:
            clipboard.copy(message.text)

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

    // MARK: - Private: Common helpers

    private func beginLoading() {
        isLoading = true
        errorText = nil
    }

    private func endLoading() {
        isLoading = false
    }

    private func complete(
        system: String,
        user: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        try await completionService.complete(
            system: system,
            user: user,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }

    // MARK: - Private: Requests

    private func send(
        system: String,
        user: String,
        displayUserText: String?,
        scope: ChatScope
    ) async {
        beginLoading()

        if let displayUserText {
            messages.append(ChatMessage(role: .user, text: displayUserText))
        } else {
            messages.append(ChatMessage(role: .user, text: user))
        }

        let request = ChatMessage.Request(
            systemPrompt: system,
            userPrompt: user,
            temperature: 0.3,
            maxTokens: 900,
            scope: scope
        )

        do {
            let response = try await complete(
                system: system,
                user: user,
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages.append(
                ChatMessage(role: .assistant, text: response, request: request)
            )
            endLoading()
        } catch {
            errorText = error.localizedDescription
            endLoading()
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

        beginLoading()

        do {
            let response = try await complete(
                system: request.systemPrompt,
                user: request.userPrompt,
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages[index].text = response
            endLoading()
        } catch {
            errorText = error.localizedDescription
            endLoading()
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

        beginLoading()

        let userPrompt = promptBuilder.explainSimplerUserPrompt(
            baseUserPrompt: request.userPrompt
        )

        do {
            let response = try await complete(
                system: request.systemPrompt,
                user: userPrompt,
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )

            messages[index].text = response
            messages[index].request = ChatMessage.Request(
                systemPrompt: request.systemPrompt,
                userPrompt: userPrompt,
                temperature: request.temperature,
                maxTokens: request.maxTokens,
                scope: request.scope
            )
            endLoading()
        } catch {
            errorText = error.localizedDescription
            endLoading()
        }
    }
}
