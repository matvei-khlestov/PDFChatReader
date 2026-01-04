//
//  PDFContextProvider.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation
import PDFKit

struct PDFContextProvider: PDFContextProviding {

    func pageText(
        document: PDFDocument,
        pageIndex: Int
    ) -> String {
        guard
            pageIndex >= 0,
            pageIndex < document.pageCount,
            let page = document.page(at: pageIndex),
            let text = page.string
        else {
            return ""
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
