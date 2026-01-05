//
//  AppContainer.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 04.01.2026.
//

import Foundation
import SwiftUI
import Combine

final class AppContainer: ObservableObject {

    // MARK: - Dependencies

    let gptService: YandexGPTServicing
    let modelUri: String
    let pdfContextProvider: PDFContextProviding
    let pdfImporter: PDFImporting

    // MARK: - Init

    init(
        gptService: YandexGPTServicing = YandexGPTService(apiKey: AppSecrets.apiKey),
        modelUri: String = AppSecrets.modelUri,
        pdfContextProvider: PDFContextProviding = PDFContextProvider(),
        pdfImporter: PDFImporting = PDFFileImporter()
    ) {
        self.gptService = gptService
        self.modelUri = modelUri
        self.pdfContextProvider = pdfContextProvider
        self.pdfImporter = pdfImporter
    }

    // MARK: - Factory: PDF Reader

    func makePDFReaderViewModel() -> PDFReaderViewModel {
        PDFReaderViewModel(
            contextProvider: pdfContextProvider,
            pdfImporter: pdfImporter
        )
    }

    // MARK: - Factory: Chat

    func makeChatView(
        contextProvider: @escaping (ChatScope) -> String
    ) -> AnyView {
        AnyView(
            ChatView(
                viewModel: makeChatViewModel(contextProvider: contextProvider)
            )
        )
    }

    // MARK: - Private

    private func makeChatViewModel(
        contextProvider: @escaping (ChatScope) -> String
    ) -> ChatViewModel {
        ChatViewModel(
            completionService: makeChatCompletionService(),
            clipboard: makeClipboardService(),
            contextProvider: contextProvider,
            promptBuilder: PromptBuilder()
        )
    }

    private func makeChatCompletionService() -> ChatCompletionServicing {
        YandexChatCompletionService(
            gpt: gptService,
            modelUri: modelUri
        )
    }

    private func makeClipboardService() -> ClipboardServicing {
        SystemClipboardService()
    }
}
