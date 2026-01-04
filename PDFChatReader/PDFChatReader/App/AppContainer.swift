//
//  AppContainer.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 04.01.2026.
//

import Foundation
import Combine

final class AppContainer: ObservableObject {
    
    let gptService: YandexGPTServicing
    let modelUri: String
    let pdfContextProvider: PDFContextProviding

    init(
        gptService: YandexGPTServicing = YandexGPTService(apiKey: AppSecrets.apiKey),
        modelUri: String = AppSecrets.modelUri,
        pdfContextProvider: PDFContextProviding = PDFContextProvider()
    ) {
        self.gptService = gptService
        self.modelUri = modelUri
        self.pdfContextProvider = pdfContextProvider
    }

    func makePDFReaderViewModel() -> PDFReaderViewModel {
        PDFReaderViewModel(contextProvider: pdfContextProvider)
    }
}
