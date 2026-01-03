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
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged),
            name: Notification.Name.PDFViewPageChanged,
            object: pdfView
        )

        context.coordinator.pdfView = pdfView
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Если нужно будет программно прыгать на страницу — добавим позже.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPageIndex: $currentPageIndex)
    }

    final class Coordinator: NSObject {
        weak var pdfView: PDFView?
        private var currentPageIndex: Binding<Int>

        init(currentPageIndex: Binding<Int>) {
            self.currentPageIndex = currentPageIndex
        }

        @objc func pageChanged() {
            guard let pdfView, let page = pdfView.currentPage, let doc = pdfView.document else { return }
            let index = doc.index(for: page)
            currentPageIndex.wrappedValue = max(0, index)
        }
    }
}
