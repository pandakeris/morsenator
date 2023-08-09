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

extension Entity {
    func scaleAnimated(with value: SIMD3<Float>, duration: CGFloat) {
        var scaleTransform = Transform()
        scaleTransform.scale = value
        move(to: transform, relativeTo: parent)
        move(to: scaleTransform, relativeTo: parent, duration: duration)
    }
}

class ARViewController: UIViewController, ARSessionDelegate {
    private var arView: ARView!

    var currentBuffer: CVPixelBuffer?

    let visionQueue = DispatchQueue(label: "morsenator.visionqueue")

    private var viewportSize: CGSize! {
        return arView.frame.size
    }

    private var detectRemoteControl: Bool = true

    private var isTouching = false

    private var buttonId: UInt64?
    private var buttonName: String?

    private var buttonModel: Entity?

    var viewWidth: Int = 0
    var viewHeight: Int = 0

    var box: ModelEntity!

    var recentIndexFingerPoint: CGPoint = .zero

    lazy var request: VNRequest = {
        var handPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        handPoseRequest.maximumHandCount = 1
        return handPoseRequest
    }()

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
//        arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]

        viewWidth = Int(arView.bounds.width)
        viewHeight = Int(arView.bounds.height)
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
        configuration.frameSemantics = [.personSegmentation]
        arView.session.run(configuration)

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)

        arView.session.delegate = self

//        let anchor = AnchorEntity() // Anchor (anchor that fixes the AR model)
//        anchor.position = simd_make_float3(0, -0.5, -1) // The position of the anchor is 0.5m below, 1m away the initial position of the device.
//        let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.1, 0.2), cornerRadius: 0.03))
//        // Make a model from a box mesh with a width of 0.3m, a height of 0.1m, a depth of 0.2m, and a radius of rounded corners of 0.03m.
//        box.transform = Transform(pitch: 0, yaw: 1, roll: 0) // Rotate the box model 1 radian on the Y axis
//        anchor.addChild(box) // Add a box to the child of the anchor in the hierarchy.
//        arView.scene.anchors.append(anchor) // Add an anchor to arView

        setupObject()
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

//    func session(_: ARSession, didUpdate frame: ARFrame) {
//        // Do not enqueue other buffers for processing while another Vision task is still running.
//        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
//
//        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
//            return
//        }
//
//        // Retain the image buffer for Vision processing.
//        currentBuffer = frame.capturedImage
//
//        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
//        let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) ?? .leftMirrored
//
//        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
//        visionQueue.async {
//            do {
//                // Release the pixel buffer when done, allowing the next buffer to be processed.
//                defer { self.currentBuffer = nil }
//                try requestHandler.perform([self.objectDetectionRequest])
//            } catch {
//                print("Error: Vision request failed with error \"\(error)\"")
//            }
//        }
//    }

    func session(_: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([(self?.request)!])

            } catch {
                print(error)
            }
        }
    }

    func handDetectionCompletionHandler(request: VNRequest?, error _: Error?) {
        // Get the position of the tip of the index finger from the result of the request
        guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
        guard let indexFingerTip = try? observation.recognizedPoints(.all)[.indexTip],
              indexFingerTip.confidence > 0.3 else { return }

        // Since the result of Vision is normalized to 0 ~ 1, it is converted to the coordinates of ARView.
        let normalizedIndexPoint = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.y, y: indexFingerTip.location.x), viewWidth, viewHeight)

        var buttonTouched = false

        // Perform a hit test with the acquired coordinates of the fingertips
        if let entities = arView.entities(at: normalizedIndexPoint) as? [ModelEntity] {
            for entity in entities {
//                let geom = entity.findEntity(named: "button2_Cylinder_001")
//                print("GAS\(geom?.name)")
                // Apply physical force to the box object you find
                // entity.addForce([0, 40, 0], relativeTo: nil)
                // To addForce, give the target entity a PhysicsBodyComponent
                // entity.scaleAnimated(with: [0.012, 0.012, 0.012], duration: 1.0)
                print("Entity id: \(entity.id)")
                print(buttonId)
                if entity.id == buttonId {
                    buttonTouched = true
                    print("Touching da button")
                    if buttonModel != nil && !isTouching {
                        for animation in buttonModel!.availableAnimations {
                            buttonModel!.playAnimation(animation.repeat(count: 1))
                            // usdzModel?.stopAllAnimations()
                        }
                        isTouching = true
                    }
                }
            }
        }
//        else {
//            isTouching = false
//        }

        if !buttonTouched {
            isTouching = false
        }

        if !isTouching {
            if buttonModel != nil {
                buttonModel?.stopAllAnimations()
            }
        }
    }

    private func setupObject() {
        let anchor = AnchorEntity(plane: .horizontal)

        let plane = ModelEntity(mesh: .generatePlane(width: 2, depth: 2), materials: [OcclusionMaterial()])
        anchor.addChild(plane)
        plane.generateCollisionShapes(recursive: false)
        plane.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)

//        box = ModelEntity(mesh: .generateBox(size: 0.05), materials: [SimpleMaterial(color: .white, isMetallic: true)])
//        box.generateCollisionShapes(recursive: false)
//        box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
//        box.position = [0, 0, 0]
//        anchor.addChild(box)

        let usdzModel = try? Entity.load(named: "button")
        if usdzModel != nil {
            // usdzModel?.generateCollisionShapes(recursive: true)
            let physics = PhysicsBodyComponent(massProperties: .default,
                                               material: .default,
                                               mode: .dynamic)

            let geom = usdzModel!.findEntity(named: "button2_Cylinder_001")
            print("GAS\(geom?.name)")
            // geom?.generateCollisionShapes(recursive: true)
//            if geom != nil {
//                geom.collision = CollisionComponent(shapes: [ShapeResource.generateConvex(from: geom.model!.mesh)])
//            }
//            for a in usdzModel!.children {
//                print("brooo\(a.children[0].children[0].children[1].name)")
//            }

            let body = geom?.visualBounds(relativeTo: nil)

            let width = (body!.max.x) - (body!.min.x)
            let height = (body!.max.y) - (body!.min.y)
            let depth = (body!.max.z) - (body!.min.z)

            let boxSize: SIMD3<Float> = [width, height, depth]

            box = ModelEntity(mesh: .generateBox(size: boxSize), materials: [SimpleMaterial(color: .white.withAlphaComponent(0), isMetallic: true)])
            box.generateCollisionShapes(recursive: false)
            box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
            box.position = [0, 0, 0]
            anchor.addChild(box)

            // usdzModel?.components.set(physics)
            // geom?.components.set(physics)
            anchor.addChild(usdzModel!)
            buttonId = box.id
            buttonName = usdzModel?.name
            buttonModel = usdzModel
        }

        arView.scene.addAnchor(anchor)

//        if usdzModel != nil {
//            for animation in usdzModel!.availableAnimations {
//                print("Playing animations")
//                usdzModel!.playAnimation(animation.repeat())
//                // usdzModel?.stopAllAnimations()
//            }
//        }
    }
}
