//
//  Recognator.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import SwiftUI
import Vision
import VisionKit

final class Recognator{
    let cameraScan: VNDocumentCameraScan
    init(cameraScan: VNDocumentCameraScan) {
        self.cameraScan = cameraScan
    }
    private let queue = DispatchQueue(label: "scan-codes", qos: .default,attributes: [],autoreleaseFrequency: .workItem)
    
    func recognizing(withCompletionHandler completionHandler:@escaping ([String]?) -> Void) {
        queue.async {
            let image = (0..<self.cameraScan.pageCount).compactMap({
                self.cameraScan.imageOfPage(at: $0).cgImage
            })
            let imagesRequest = image.map({(image: $0, request:VNRecognizeTextRequest())})
            let textPerPage = imagesRequest.map{image,request->String in
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do{
                    try handler.perform([request])
                    guard let obsevations = request.results as? [VNRecognizedTextObservation] else{return ""}
                    return obsevations.compactMap({$0.topCandidates(1).first?.string}).joined(separator: "\n")
                }
                catch{
                    print(error)
                    return ""
                }
            }
            DispatchQueue.main.async {
                completionHandler(textPerPage)
            }
        }
    }
}
