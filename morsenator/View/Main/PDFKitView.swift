//
//  PDFKitView.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 24/08/23.
//

import PDFKit
import SwiftUI

// Add this:
struct PDFKitView: UIViewRepresentable {
    let url: URL // new variable to get the URL of the document

    func makeUIView(context _: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        // Creating a new PDFVIew and adding a document to it
        let pdfView = PDFView()
        DispatchQueue.main.async {
            pdfView.document = PDFDocument(url: url)
        }
        return pdfView
    }

    func updateUIView(_: PDFView, context _: UIViewRepresentableContext<PDFKitView>) {
        // we will leave this empty as we don't need to update the PDF
    }
}
