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
    @Published var document: PDFDocument?
    @Published var currentPageIndex: Int = 0
    @Published var currentPageText: String = ""
    @Published var isChatPresented: Bool = false

    private let contextProvider: PDFContextProviding

    init(contextProvider: PDFContextProviding = PDFContextProvider()) {
        self.contextProvider = contextProvider
    }

    func setDocument(from url: URL) {
        guard let doc = PDFDocument(url: url) else { return }
        document = doc
        currentPageIndex = 0
        currentPageText = contextProvider.pageText(document: doc, pageIndex: 0)
    }

    func updatePageContext() {
        guard let doc = document else { return }
        currentPageText = contextProvider.pageText(document: doc, pageIndex: currentPageIndex)
    }
}
