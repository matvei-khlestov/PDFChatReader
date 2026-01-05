//
//  PDFContextProviding.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 04.01.2026.
//

import Foundation
import PDFKit

protocol PDFContextProviding {
    func pageText(document: PDFDocument, pageIndex: Int) -> String
    func documentText(document: PDFDocument) -> String
}
