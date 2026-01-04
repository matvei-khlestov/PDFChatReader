//
//  PDFViewPageObserver.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation
import PDFKit
import SwiftUI

final class PDFViewPageObserver: NSObject {
    
    weak var pdfView: PDFView?
    private let currentPageIndex: Binding<Int>
    
    init(currentPageIndex: Binding<Int>) {
        self.currentPageIndex = currentPageIndex
    }
    
    @objc func pageChanged() {
        guard
            let pdfView,
            let page = pdfView.currentPage,
            let document = pdfView.document
        else { return }
        
        let index = max(0, document.index(for: page))
        
        DispatchQueue.main.async {
            if self.currentPageIndex.wrappedValue != index {
                self.currentPageIndex.wrappedValue = index
            }
        }
    }
}

