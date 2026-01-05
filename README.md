# PDFChatReader

PDFChatReader is a demo iOS application that combines PDF document reading with an AI-powered chat, allowing users to interact with document content using natural language — both at the level of a single page and the entire document.

The project focuses on clean architecture, predictable state-driven UI, and a production-ready AI integration that follows SOLID principles.

<p align="center">
  <img
    width="1600"
    height="2030"
    alt="PDFReader_Mockup"
    src="https://github.com/user-attachments/assets/5dfc1f14-dae6-4183-b87d-3f9669508045"
  />
</p>

## Overview

The project demonstrates how an AI assistant can be directly embedded into a PDF reader, enabling users to ask questions, analyze text, and receive explanations based on:

- the current page
- the entire document

The solution is designed to scale without turning ViewModels into monoliths, maintaining a strict boundary between UI, business logic, and infrastructure code.

## Core Functionality

- Importing and rendering PDF files using PDFKit  
- Tracking the current page with automatic text context updates  
- AI chat with selectable context scope:
  - current page
  - entire document  
- Free-form questions and predefined quick actions  
- Assistant response actions:
  - copy to clipboard
  - regenerate response
  - explain in simpler terms  
- Explicit loading, error, and empty states  
- Fully state-driven UI with predictable behavior  
- Clear separation of responsibilities across layers  

## Architecture

- SwiftUI as the UI layer
- MVVM with clear View ↔ ViewModel separation
- Service layer designed according to SOLID principles
- Protocol-oriented approach for improved testability
- Dependency assembly via an AppContainer factory
- Clear separation of presentation, domain, and infrastructure layers
- Full isolation of AI integration from the UI layer

## AI Integration

- YandexGPT as the LLM backend
- Dedicated abstraction for completion services
- Explicit context management (Page / Document)
- No networking logic inside ViewModels
- Architecture ready for future extensions:
  - streaming responses
  - retry mechanisms
  - logging
  - analytics

## Tech Stack

- Swift 5.9+
- SwiftUI — UI construction and state management
- Combine — reactive state and data updates
- Swift Concurrency (async / await) — asynchronous networking and business logic
- PDFKit — PDF rendering and text analysis
- URLSession — network communication
- YandexGPT API — LLM backend for the AI assistant
- Protocol-Oriented Design — loose coupling and testability
- MVVM — architectural separation of concerns
- SOLID — service-layer design principles
- UIKit (used selectively) — Launch Screen, system services
- Xcode + iOS Simulator — development and debugging environment

## Disclaimer

This project is a demo and educational example and is not intended to be used as a full-featured PDF editor or chat application.
