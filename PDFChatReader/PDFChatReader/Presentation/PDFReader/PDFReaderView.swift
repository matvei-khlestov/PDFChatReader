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
    @StateObject private var viewModel = PDFReaderViewModel()
    
    @State private var isImporterPresented = false
    @State private var importError: String?
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var layout: Layout {
        horizontalSizeClass == .regular ? .pad : .phone
    }
    
    private var metrics: Metrics {
        Metrics(layout: layout)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let doc = viewModel.document {
                    PDFKitViewRepresentable(
                        document: doc,
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
            .navigationTitle("PDF Reader")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Open") { isImporterPresented = true }
                        .font(metrics.toolbarFont)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chat") {
                        viewModel.isChatPresented = true
                    }
                    .font(metrics.toolbarFont)
                    .disabled(viewModel.document == nil)
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    viewModel.setDocument(from: url)
                case .failure(let error):
                    importError = error.localizedDescription
                }
            }
            .alert("Import failed", isPresented: Binding(get: {
                importError != nil
            }, set: {
                _ in importError = nil
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError ?? "")
            }
            .sheet(isPresented: $viewModel.isChatPresented) {
                if viewModel.document != nil {
                    ChatView(contextProvider: { viewModel.currentPageText })
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: metrics.emptyStateSpacing) {
            Image(systemName: "doc.richtext")
                .font(.system(size: metrics.emptyStateIconSize, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
            
            Text("Open a PDF to start")
                .font(metrics.emptyStateTitleFont)
                .multilineTextAlignment(.center)
            
            Button("Open PDF") { isImporterPresented = true }
                .font(metrics.primaryButtonFont)
                .buttonStyle(.borderedProminent)
                .controlSize(metrics.primaryButtonControlSize)
        }
        .padding(metrics.emptyStatePadding)
        .frame(maxWidth: metrics.emptyStateMaxWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: metrics.pageIndicatorSpacing) {
            Text("Page \(viewModel.currentPageIndex + 1)")
                .font(metrics.pageIndicatorFont)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, metrics.pageIndicatorVerticalPadding)
        .padding(.horizontal, metrics.pageIndicatorHorizontalPadding)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: metrics.pageIndicatorCornerRadius, style: .continuous))
        .padding(metrics.pageIndicatorOuterPadding)
        .frame(maxWidth: metrics.pageIndicatorMaxWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

private extension PDFReaderView {
    enum Layout {
        case phone
        case pad
    }
    
    struct Metrics {
        let layout: Layout
        
        // MARK: - Fonts
        
        var toolbarFont: Font {
            switch layout {
            case .phone:
                return .system(size: 17, weight: .semibold)
            case .pad:
                return .system(size: 22, weight: .semibold)
            }
        }
        
        var emptyStateTitleFont: Font {
            switch layout {
            case .phone:
                return .system(size: 20, weight: .semibold)
            case .pad:
                return .system(size: 28, weight: .semibold)
            }
        }
        
        var primaryButtonFont: Font {
            switch layout {
            case .phone:
                return .system(size: 17, weight: .semibold)
            case .pad:
                return .system(size: 21, weight: .semibold)
            }
        }
        
        var pageIndicatorFont: Font {
            switch layout {
            case .phone:
                return .system(size: 13, weight: .semibold)
            case .pad:
                return .system(size: 16, weight: .semibold)
            }
        }
        
        // MARK: - Layout
        
        var emptyStateMaxWidth: CGFloat {
            switch layout {
            case .phone:
                return 360
            case .pad:
                return 600
            }
        }
        
        var emptyStatePadding: CGFloat {
            switch layout {
            case .phone:
                return 20
            case .pad:
                return 34
            }
        }
        
        var emptyStateSpacing: CGFloat {
            switch layout {
            case .phone:
                return 12
            case .pad:
                return 20
            }
        }
        
        var emptyStateIconSize: CGFloat {
            switch layout {
            case .phone:
                return 44
            case .pad:
                return 66
            }
        }
        
        var primaryButtonControlSize: ControlSize {
            switch layout {
            case .phone:
                return .regular
            case .pad:
                return .extraLarge
            }
        }
        
        var pageIndicatorSpacing: CGFloat { 8 }
        
        var pageIndicatorVerticalPadding: CGFloat {
            switch layout {
            case .phone:
                return 10
            case .pad:
                return 14
            }
        }
        
        var pageIndicatorHorizontalPadding: CGFloat {
            switch layout {
            case .phone:
                return 10
            case .pad:
                return 16
            }
        }
        
        var pageIndicatorCornerRadius: CGFloat {
            switch layout {
            case .phone:
                return 12
            case .pad:
                return 16
            }
        }
        
        var pageIndicatorOuterPadding: CGFloat {
            switch layout {
            case .phone:
                return 14
            case .pad:
                return 18
            }
        }
        
        var pageIndicatorMaxWidth: CGFloat? {
            switch layout {
            case .phone:
                return 360
            case .pad:
                return 600
            }
        }
    }
}

#Preview {
    PDFReaderView()
}
