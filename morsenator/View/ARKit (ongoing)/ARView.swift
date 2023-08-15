//
//  ARView.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 01/08/23.
//

import SwiftUI

protocol BottomSheetDelegate {
    func dismissBottomSheet()
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    @State private var timer: Timer?
    @EnvironmentObject var arMorseModel: ARMorseModel

    func makeUIViewController(context _: Context) -> ARViewController {
        let viewController = ARViewController()
        viewController.arMorseModel = arMorseModel
        return viewController
    }

    func updateUIViewController(_: ARViewController, context _: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }

    func makeCoordinator() -> ARViewControllerContainer.Coordinator {
        return Coordinator(self)
    }
}

struct ARView_Previews: PreviewProvider {
    @State static var dialogMessage: String?
    @State static var bmImages: [String] = []
    @State static var firstPrimeTime: Bool = false

    static var previews: some View {
        ZStack {
            ARViewControllerContainer()
                .ignoresSafeArea()

            Image("shiba-1")
                .resizable()
                .scaledToFit().frame(width: 250)
                .padding(.top, -190)
                .padding(.leading, -100)
        }
    }
}

extension ARViewControllerContainer {
    class Coordinator: NSObject, ObservableObject, BottomSheetDelegate {
        func dismissBottomSheet() {
            // TODO: Ignore this
        }

        var parent: ARViewControllerContainer

        init(_ parent: ARViewControllerContainer) {
            self.parent = parent
        }

        // Set dialog timer and disappear within 5 second
        func addDialog(message _: String) {
            // Invalidate any existing timer
        }

        func doneFirstPrimeTime(bool _: Bool) {}
    }
}
