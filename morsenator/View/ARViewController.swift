//
//  ARViewController.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 01/08/23.
//

import ARKit
import RealityKit
import SwiftUI
import UIKit
import Vision

// MARK: - ARViewIndicator

struct ARViewIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    func makeUIViewController(context _: Context) -> ARViewController {
        return ARViewController()
    }

    func updateUIViewController(_:
        ARViewIndicator.UIViewControllerType, context _:
        UIViewControllerRepresentableContext<ARViewIndicator>) {}
}

class ARViewController: UIViewController, ARSessionDelegate {
//    var arView: ARView {
//        return view as! ARView
//    }
    
    private var arView: ARView!
        
    var currentBuffer: CVPixelBuffer?
    
    let visionQueue = DispatchQueue(label: "morsenator.visionqueue")

    private var viewportSize: CGSize! {
        return arView.frame.size
    }

//    override func loadView() {
//        view = ARView()
//    }

    private var detectRemoteControl: Bool = true

    lazy var objectDetectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: yolov8s().model)
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.processDetections(for: request, error: error)
            }
            return request
        } catch {
            fatalError("Failed to load Vision ML model.")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
//        arView.delegate = self
//        arView.scene = SCNScene()
        arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
//
//        let node = SCNNode()
//        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        arView.scene.rootNode.addChildNode(node)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - Functions for standard AR view handling

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)

        arView.session.delegate = self
        
        let anchor = AnchorEntity() // Anchor (anchor that fixes the AR model)
        anchor.position = simd_make_float3(0, -0.5, -1) // The position of the anchor is 0.5m below, 1m away the initial position of the device.
        let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.1, 0.2), cornerRadius: 0.03))
         // Make a model from a box mesh with a width of 0.3m, a height of 0.1m, a depth of 0.2m, and a radius of rounded corners of 0.03m.
        box.transform = Transform(pitch: 0, yaw: 1, roll: 0) // Rotate the box model 1 radian on the Y axis
        anchor.addChild(box) // Add a box to the child of the anchor in the hierarchy.
        arView.scene.anchors.append(anchor) // Add an anchor to arView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        detectRemoteControl = true
    }

//    func renderer(_: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard anchor.name == "remoteObjectAnchor" else { return }
//        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
//        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        node.addChildNode(sphereNode)
//    }

    // MARK: - ARSCNViewDelegate

//    func sessionWasInterrupted(_: ARSession) {}
//
//    func sessionInterruptionEnded(_: ARSession) {}
//    func session(_: ARSession, didFailWithError _: Error) {}
//    func session(_: ARSession, cameraDidChangeTrackingState _: ARCamera) {}

    func processDetections(for request: VNRequest, error: Error?) {
        guard error == nil else {
            print("Object detection error: \(error!.localizedDescription)")
            return
        }
        
        guard let results = request.results else { return }
        
        if detectRemoteControl == false {
            return
        }

        for observation in results where observation is VNRecognizedObjectObservation {
            let ss = observation as? VNRecognizedObjectObservation
            print(ss?.labels.first?.identifier)
            guard let objectObservation = observation as? VNRecognizedObjectObservation,
                  let topLabelObservation = objectObservation.labels.first,
                  topLabelObservation.identifier == "dog",
                  topLabelObservation.confidence > 0.9
            else { continue }

            guard let currentFrame = arView.session.currentFrame else { continue }

            // Get the affine transform to convert between normalized image coordinates and view coordinates
            let fromCameraImageToViewTransform = currentFrame.displayTransform(for: .portrait, viewportSize: viewportSize)
            // The observation's bounding box in normalized image coordinates
            let boundingBox = objectObservation.boundingBox
            // Transform the latter into normalized view coordinates
            let viewNormalizedBoundingBox = boundingBox.applying(fromCameraImageToViewTransform)
            // The affine transform for view coordinates
            let t = CGAffineTransform(scaleX: viewportSize.width, y: viewportSize.height)
            // Scale up to view coordinates
            let viewBoundingBox = viewNormalizedBoundingBox.applying(t)

            let midPoint = CGPoint(x: viewBoundingBox.midX,
                                   y: viewBoundingBox.midY)

            let results = arView.hitTest(midPoint, types: [.featurePoint])
            guard let result = results.first else { continue }

//            let anchor = ARAnchor(name: "remoteObjectAnchor", transform: result.worldTransform)
//            arView.session.add(anchor: anchor)
            

            // Add a new anchor at the tap location.
            let arAnchor = ARAnchor(transform: result.worldTransform)
            arView.session.add(anchor: arAnchor)
            
            let anchor = AnchorEntity(anchor: arAnchor) // Anchor (anchor that fixes the AR model)
            anchor.position = simd_make_float3(0, -0.5, -1) // The position of the anchor is 0.5m below, 1m away the initial position of the device.
            let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.1, 0.2), cornerRadius: 0.03))
             // Make a model from a box mesh with a width of 0.3m, a height of 0.1m, a depth of 0.2m, and a radius of rounded corners of 0.03m.
            box.transform = Transform(pitch: 0, yaw: 1, roll: 0) // Rotate the box model 1 radian on the Y axis
            anchor.addChild(box) // Add a box to the child of the anchor in the hierarchy.
            arView.scene.anchors.append(anchor) // Add an anchor to arView

            print(midPoint)

            detectRemoteControl = false
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.

        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        
        
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) ?? .leftMirrored


        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.objectDetectionRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }

    }

//    func renderer(_: SCNSceneRenderer, willRenderScene _: SCNScene, atTime _: TimeInterval) {
//        // Get the capture image (which is a cvPixelBuffer) from the current ARFrame
//        guard let capturedImage = arView.session.currentFrame?.capturedImage else { return }
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: capturedImage,
//                                                        orientation: .leftMirrored,
//                                                        options: [:])
//
//        do {
//            try imageRequestHandler.perform([objectDetectionRequest])
//        } catch {
//            print("Failed to perform image request.")
//        }
//    }
}
