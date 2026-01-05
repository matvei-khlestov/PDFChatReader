//
//  HTTPResponseValidating.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol HTTPResponseValidating {
    func validate(data: Data, response: URLResponse) throws
}
