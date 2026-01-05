//
//  PDFKitViewRepresentable.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import SwiftUI
import PDFKit

struct PDFKitViewRepresentable: UIViewRepresentable {
    
    let document: PDFDocument
    @Binding var currentPageIndex: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false, withViewOptions: nil)
        
        context.coordinator.pdfView = pdfView
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(PDFViewPageObserver.pageChanged),
            name: Notification.Name.PDFViewPageChanged,
            object: pdfView
        )
        
        pdfView.document = document
        goToFirstPageIfPossible(pdfView)
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        guard uiView.document !== document else { return }
        
        uiView.document = nil
        uiView.document = document
        goToFirstPageIfPossible(uiView)
        
        DispatchQueue.main.async {
            if self.currentPageIndex != 0 {
                self.currentPageIndex = 0
            }
        }
    }
    
    static func dismantleUIView(_ uiView: PDFView, coordinator: PDFViewPageObserver) {
        let observedObject = coordinator.pdfView ?? uiView
        
        NotificationCenter.default.removeObserver(
            coordinator,
            name: Notification.Name.PDFViewPageChanged,
            object: observedObject
        )
        
        coordinator.pdfView = nil
        uiView.document = nil
    }
    
    func makeCoordinator() -> PDFViewPageObserver {
        PDFViewPageObserver(currentPageIndex: $currentPageIndex)
    }
    
    private func goToFirstPageIfPossible(_ pdfView: PDFView) {
        guard let firstPage = pdfView.document?.page(at: 0) else { return }
        pdfView.go(to: firstPage)
    }
}
