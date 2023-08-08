//
//  ScannerView.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinate {
        return Coordinate(completion: completionHandler)
    }

    final class Coordinate: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([String]?) -> Void

        init(completion: @escaping ([String]?) -> Void) {
            completionHandler = completion
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let recognizer = Recognator(cameraScan: scan)
            recognizer.recognizing(withCompletionHandler: completionHandler)
        }

        func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            completionHandler(nil)
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError _: Error) {
            completionHandler(nil)
        }
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}

    typealias UIViewControllerType = VNDocumentCameraViewController

    private let completionHandler: ([String]?) -> Void

    init(completion: @escaping ([String]?) -> Void) {
        completionHandler = completion
    }
}
