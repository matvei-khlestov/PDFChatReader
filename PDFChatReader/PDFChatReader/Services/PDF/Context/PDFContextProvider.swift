//
//  PDFContextProvider.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation
import PDFKit

struct PDFContextProvider: PDFContextProviding {
    
    func pageText(document: PDFDocument, pageIndex: Int) -> String {
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
    
    func documentText(document: PDFDocument) -> String {
        guard document.pageCount > 0 else { return "" }
        
        var parts: [String] = []
        parts.reserveCapacity(document.pageCount)
        
        for index in 0..<document.pageCount {
            let page = pageText(document: document, pageIndex: index)
            if !page.isEmpty {
                parts.append(page)
            }
        }
        
        return parts.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
