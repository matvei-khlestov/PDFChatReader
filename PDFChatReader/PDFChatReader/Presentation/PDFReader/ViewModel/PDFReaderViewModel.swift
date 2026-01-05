//
//  PDFReaderViewModel.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation
import PDFKit
import Combine

@MainActor
final class PDFReaderViewModel: ObservableObject {

    // MARK: - Published

    @Published var document: PDFDocument?
    @Published var currentPageIndex: Int = 0
    @Published var currentPageText: String = ""
    @Published var documentText: String = ""
    @Published var isChatPresented: Bool = false

    // MARK: - Dependencies

    private let contextProvider: PDFContextProviding
    private let pdfImporter: PDFImporting

    // MARK: - Init

    init(
        contextProvider: PDFContextProviding,
        pdfImporter: PDFImporting
    ) {
        self.contextProvider = contextProvider
        self.pdfImporter = pdfImporter
    }

    // MARK: - Public

    func setDocument(from url: URL) {
        do {
            let localURL = try pdfImporter.importPDF(from: url)
            guard let doc = PDFDocument(url: localURL) else { return }
            applyLoadedDocument(doc)
        } catch {
            return
        }
    }

    func updatePageContext() {
        guard let doc = document else { return }
        currentPageText = contextProvider.pageText(
            document: doc,
            pageIndex: currentPageIndex
        )
    }

    func context(for scope: ChatScope) -> String {
        let rawContext: String
        
        switch scope {
        case .page:
            rawContext = currentPageText
        case .document:
            rawContext = documentText
        }
        
        return String(rawContext.prefix(AIContextLimit.maxCharacters))
    }

    // MARK: - Private

    private func applyLoadedDocument(_ doc: PDFDocument) {
        document = doc
        currentPageIndex = 0
        currentPageText = contextProvider.pageText(document: doc, pageIndex: 0)
        documentText = contextProvider.documentText(document: doc)
    }
}
