//
//  PDFReaderView.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFReaderView: View {

    // MARK: - Dependencies

    @EnvironmentObject private var container: AppContainer

    // MARK: - State

    @StateObject private var viewModel: PDFReaderViewModel
    @State private var isImporterPresented = false
    @State private var importError: String?

    // MARK: - Init

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: container.makePDFReaderViewModel()
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("PDF Reader")
                .toolbar { toolbarContent }
                .fileImporter(
                    isPresented: $isImporterPresented,
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: false,
                    onCompletion: handleImportResult(_:)
                )
                .alert(
                    "Import failed",
                    isPresented: Binding(
                        get: { importError != nil },
                        set: { _ in importError = nil }
                    )
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(importError ?? "")
                }
                .sheet(isPresented: $viewModel.isChatPresented) {
                    chatSheet
                }
        }
    }

    // MARK: - Content

    private var content: some View {
        Group {
            if let document = viewModel.document {
                PDFKitViewRepresentable(
                    document: document,
                    currentPageIndex: $viewModel.currentPageIndex
                )
                .onChange(of: viewModel.currentPageIndex) { _, _ in
                    viewModel.updatePageContext()
                }
                .overlay(alignment: .bottom) {
                    pageIndicator
                }
            } else {
                emptyState
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Open") {
                isImporterPresented = true
            }
            .font(Metrics.toolbarFont)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Chat") {
                viewModel.isChatPresented = true
            }
            .font(Metrics.toolbarFont)
            .disabled(viewModel.document == nil)
        }
    }

    // MARK: - Import

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            viewModel.setDocument(from: url)

        case .failure(let error):
            importError = error.localizedDescription
        }
    }

    // MARK: - Sheet

    @ViewBuilder
    private var chatSheet: some View {
        if viewModel.document != nil {
            ChatView(
                gpt: container.gptService,
                modelUri: container.modelUri,
                contextProvider: { viewModel.currentPageText }
            )
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: Metrics.emptyStateSpacing) {
            Image(systemName: "doc.richtext")
                .font(
                    .system(
                        size: Metrics.emptyStateIconSize,
                        weight: .semibold
                    )
                )
                .symbolRenderingMode(.hierarchical)

            Text("Open a PDF to start")
                .font(Metrics.emptyStateTitleFont)
                .multilineTextAlignment(.center)

            Button("Open PDF") {
                isImporterPresented = true
            }
            .font(Metrics.primaryButtonFont)
            .buttonStyle(.borderedProminent)
            .controlSize(Metrics.primaryButtonControlSize)
        }
        .padding(Metrics.emptyStatePadding)
        .frame(maxWidth: Metrics.emptyStateMaxWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page indicator

    private var pageIndicator: some View {
        HStack(spacing: Metrics.pageIndicatorSpacing) {
            Text("Page \(viewModel.currentPageIndex + 1)")
                .font(Metrics.pageIndicatorFont)

            Spacer(minLength: 0)
        }
        .padding(.vertical, Metrics.pageIndicatorVerticalPadding)
        .padding(.horizontal, Metrics.pageIndicatorHorizontalPadding)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: Metrics.pageIndicatorCornerRadius,
                style: .continuous
            )
        )
        .padding(Metrics.pageIndicatorOuterPadding)
        .frame(
            maxWidth: Metrics.pageIndicatorMaxWidth,
            alignment: .leading
        )
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

// MARK: - Metrics

private enum Metrics {

    // MARK: - Fonts

    static let toolbarFont: Font =
        .system(size: 17, weight: .semibold)

    static let emptyStateTitleFont: Font =
        .system(size: 20, weight: .semibold)

    static let primaryButtonFont: Font =
        .system(size: 17, weight: .semibold)

    static let pageIndicatorFont: Font =
        .system(size: 13, weight: .semibold)

    // MARK: - Empty state

    static let emptyStateMaxWidth: CGFloat = 360
    static let emptyStatePadding: CGFloat = 20
    static let emptyStateSpacing: CGFloat = 12
    static let emptyStateIconSize: CGFloat = 44
    static let primaryButtonControlSize: ControlSize = .regular

    // MARK: - Page indicator

    static let pageIndicatorSpacing: CGFloat = 8
    static let pageIndicatorVerticalPadding: CGFloat = 10
    static let pageIndicatorHorizontalPadding: CGFloat = 10
    static let pageIndicatorCornerRadius: CGFloat = 12
    static let pageIndicatorOuterPadding: CGFloat = 14
    static let pageIndicatorMaxWidth: CGFloat? = 360
}
