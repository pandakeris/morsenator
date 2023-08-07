//
//  MainView.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import SwiftUI

struct MainView: View {
    @State private var showScannerPage = false
    @State private var areatext:[ScannerData] = []
    
    var body: some View {
        NavigationStack{
            VStack{
                if areatext.count > 0{
                    List{
                        ForEach(areatext){text in NavigationLink(destination: ScrollView{Text(text.content)}, label: {Text(text.content).lineLimit(1)})}
                    }
                }
                else{
                    Text("Morse code is not valid").font(.headline)
                }
                    
            }
            .navigationTitle("Morse To Text")
            .navigationBarItems(trailing: Button(action: {self.showScannerPage = true}, label: {
                Image(systemName: "camera.viewfinder")
                    .font(.headline)
            })
                .sheet(isPresented: $showScannerPage, content: {
                    makeScannerView()
                })
            )
        }
    }
    private func makeScannerView()-> ScannerView{
        ScannerView(completion: {
            textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines){
                let newScanData = ScannerData(content: outputText)
                self.areatext.append(newScanData)
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
