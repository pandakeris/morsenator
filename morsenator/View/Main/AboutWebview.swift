//
//  AboutWebview.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 23/08/23.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // 1
    let url: URL

    // 2
    func makeUIView(context _: Context) -> WKWebView {
        return WKWebView()
    }

    // 3
    func updateUIView(_ webView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
