//
//  MainView.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @State private var showScannerPage = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var morses: FetchedResults<MorseOCR>
    @State private var areatext: [ScannerData] = []
    @EnvironmentObject var speechController: SpeechController
    @State private var morseCode = ""
    @State private var isCopied = false

    var body: some View {
        VStack {
            if morses.count > 0 {
                List {
                    ForEach(morses) { morse in NavigationLink(destination: ScrollView {
                        if isCopied {
                            // Shows up only when copy is done
                            Text("Copied successfully!")
                                .foregroundColor(.white)
                                .bold()
                                .font(.footnote)
                                .frame(width: 140, height: 30)
                                .background(Color.indigo.cornerRadius(7))
                        }
                        Text("Text Read: ").font(.title2).padding(.vertical)
                        Button {
                            let clipboard = UIPasteboard.general
                            clipboard.setValue(morse.text ?? "", forPasteboardType: UTType.plainText.identifier)
                            isCopied = true
                            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                                isCopied = false
                            }
                        } label: {
                            Image(systemName: "clipboard")
                        }.buttonStyle(IconButton(width: 30, height: 30))
                        Text(morse.text ?? "").padding(.vertical)
                        Text("Morse: ").font(.title2).padding(.vertical)
                        Button {
                            let clipboard = UIPasteboard.general
                            clipboard.setValue(word2Morse(words: morse.text ?? ""), forPasteboardType: UTType.plainText.identifier)
                            isCopied = true
                            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                                isCopied = false
                            }
                        } label: {
                            Image(systemName: "clipboard")
                        }.buttonStyle(IconButton(width: 30, height: 30))
                        Text(word2Morse(words: morse.text ?? "")).padding(.vertical)
                    }, label: { Text(morse.text ?? "").lineLimit(1) }) }
                        .onDelete(perform: deleteMorse)
                }
            } else {
                Text("Scan to view morse code").font(.headline)
            }
        }
        .navigationTitle("Morse To Text")
        .navigationBarItems(trailing: Button(action: { self.showScannerPage = true }, label: {
            Image(systemName: "camera.viewfinder")
                .font(.headline)
        })
        .sheet(isPresented: $showScannerPage, content: {
            makeScannerView()
        })
        )
    }

    private func deleteMorse(offsets: IndexSet) {
        withAnimation {
            offsets.map { morses[$0] }.forEach(moc.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try moc.save()
        } catch {
            let error = error as NSError
            fatalError("An error occured: \(error)")
        }
    }

    private func makeScannerView() -> ScannerView {
        ScannerView(completion: {
            textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) {
                let newScanData = ScannerData(content: outputText)
                self.areatext.append(newScanData)
            }

            areatext.forEach { text in
                let morse = MorseOCR(context: moc)
                morse.text = text.content
                try? moc.save()
            }

            self.showScannerPage = false
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
