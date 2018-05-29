//
//  ViewController.swift
//  Ichan
//
//  Created by Cédric Rolland on 28.05.18.
//  Copyright © 2018 Cédric Rolland. All rights reserved.
//

import UIKit
import FirebaseDatabase
import ARCore

enum HelloARState : Int {
    case defaultState
    case creatingRoom
    case roomCreated
    case hosting
    case hostingFinished
    case enterRoomCode
    case resolving
    case resolvingFinished
}

class ViewerViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var resolveButton: UIButton!
    @IBOutlet weak var roomCodeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var roomDataSource: RoomViewModel?
    
    private var gARSession: GARSession?
    private var firebaseReference: DatabaseReference?
//    private var arAnchor: ARAnchor?
    private var arAnchorsArray = [ARAnchor]()
    private var garAnchor: GARAnchor?
    private var garAnchorsArray = [GARAnchor]()
    private var state = HelloARState(rawValue: 0)
    private var roomCode = ""
    private var message = ""
    private var resolvedAnchors = 0
    private var lastRoomNumber: Int = 0 {
        didSet {
            //TODO
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseReference = Database.database().reference()
        roomDataSource = RoomViewModel()
        roomDataSource?.delegate = self
        sceneView.delegate = self
        sceneView.session.delegate = self
        gARSession = try! GARSession(apiKey: "AIzaSyAMyKNoBMm415DIPt05ronVlNvJ2zGlUPE", bundleIdentifier: nil)
        gARSession?.delegate = self
        gARSession?.delegateQueue = DispatchQueue.main
        enter(.defaultState)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count < 1 || state == .hosting || state == .creatingRoom || state == .resolving {
            return
        }
        let touch = Array(touches).first
        let touchLocation: CGPoint? = touch?.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation ?? CGPoint.zero, types: [.existingPlane, .existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if hitTestResults.count > 0, let result = hitTestResults.first {
            addAnchor(withTransform: result.worldTransform)
        }
    }
    
    // MARK: - Anchor Hosting / Resolving
    
    func resolveAnchor(withRoomCode roomCode: String) {
        self.roomCode = roomCode
        enter(.resolving)
        weak var weakSelf: ViewerViewController? = self
        
        firebaseReference?.child("hotspot_list").child(roomCode).observe(DataEventType.value, with: {(_ snapshot: DataSnapshot?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                let strongSelf: ViewerViewController? = weakSelf
                if strongSelf == nil || strongSelf?.state != .resolving || !(strongSelf?.roomCode == roomCode) {
                    return
                }
                var anchorIdsArray = [String]()
                if (snapshot?.value is [AnyHashable: Any]) {
                    if let value = snapshot?.value as? [AnyHashable: Any],
                        let anchorsIdHashtable = value["hosted_anchors"] as? [AnyHashable: String] {
                        for (_, anchorsId) in anchorsIdHashtable {
                            anchorIdsArray.append(anchorsId)
                        }
                    }
                }
                if anchorIdsArray.count > 0 {
                    for anchorId in anchorIdsArray {

                        strongSelf?.resolveAnchor(withIdentifier: anchorId)
                    }
                    strongSelf?.firebaseReference?.child("hotspot_list").child(roomCode).removeAllObservers()
                }
            })
        })
    }
    
    func resolveAnchor(withIdentifier identifier: String) {
        // Now that we have the anchor ID from firebase, we resolve the anchor.
        // Success and failure of this call is handled by the delegate methods
        // session:didResolveAnchor and session:didFailToResolveAnchor appropriately.
        let __newGarAnchor = try? gARSession?.resolveCloudAnchor(withIdentifier: identifier)
        
        if let _newGarAnchor = __newGarAnchor, let newGarAnchor = _newGarAnchor {
            garAnchor = newGarAnchor
            garAnchorsArray.append(newGarAnchor)
        }
    }
    
    func addAnchor(withTransform transform: matrix_float4x4) {
        let newAnchor = ARAnchor(transform: transform)
        arAnchorsArray.append(newAnchor)
        sceneView.session.add(anchor: newAnchor)
        // To share an anchor, we call host anchor here on the ARCore session.
        // session:disHostAnchor: session:didFailToHostAnchor: will get called appropriately.
        let _newGarAnchor = try! gARSession?.hostCloudAnchor(newAnchor)
        if let newGarAnchor = _newGarAnchor {
            garAnchor = newGarAnchor
            garAnchorsArray.append(newGarAnchor)
        }
        enter(.hosting)
    }
    
    // MARK: - Actions
    @IBAction func hostButtonPressed() {
        if state == .defaultState {
            enter(.creatingRoom)
            roomDataSource?.createRoom()
        } else {
            enter(.defaultState)
        }
    }
    
    @IBAction func resolveButtonPressed() {
        if state == .defaultState {
            enter(.enterRoomCode)
        } else {
            enter(.defaultState)
        }
    }
    
    // MARK: - Helper Methods
    func updateMessageLabel() {
        messageLabel.text = message
        roomCodeLabel.text = "Room: \(roomCode)"
    }
    
    func toggle(_ button: UIButton, enabled: Bool, title: String?) {
        button.isEnabled = enabled
        button.setTitle(title, for: .normal)
    }
    
    func cloudStateString(_ cloudState: GARCloudAnchorState) -> String? {
        switch cloudState {
        case GARCloudAnchorState.none:
            return "None"
        case GARCloudAnchorState.success:
            return "Success"
        case GARCloudAnchorState.errorInternal:
            return "ErrorInternal"
        case GARCloudAnchorState.taskInProgress:
            return "TaskInProgress"
        case GARCloudAnchorState.errorNotAuthorized:
            return "ErrorNotAuthorized"
        case GARCloudAnchorState.errorResourceExhausted:
            return "ErrorResourceExhausted"
        case GARCloudAnchorState.errorServiceUnavailable:
            return "ErrorServiceUnavailable"
        case GARCloudAnchorState.errorHostingDatasetProcessingFailed:
            return "ErrorHostingDatasetProcessingFailed"
        case GARCloudAnchorState.errorCloudIdNotFound:
            return "ErrorCloudIdNotFound"
        case GARCloudAnchorState.errorResolvingSdkVersionTooNew:
            return "ErrorResolvingSdkVersionTooNew"
        case GARCloudAnchorState.errorResolvingSdkVersionTooOld:
            return "ErrorResolvingSdkVersionTooOld"
        case GARCloudAnchorState.errorResolvingLocalizationNoMatch:
            return "ErrorResolvingLocalizationNoMatch"
        }
    }
    
    func showRoomCodeDialog() {
        let alertController = UIAlertController(title: "ENTER ROOM CODE", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction?) -> Void in
            if let roomCodeFields = alertController.textFields, let roomCode = roomCodeFields[0].text {
                if roomCode.count == 0 {
                    self.enter(.defaultState)
                } else {
                    self.resolveAnchor(withRoomCode: roomCode)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: {(_ action: UIAlertAction?) -> Void in
            self.enter(.defaultState)
        })
        alertController.addTextField(configurationHandler: {(_ textField: UITextField?) -> Void in
            textField?.keyboardType = .numberPad
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: false, completion: nil)
    }
    
    func enter(_ state: HelloARState) {
        switch state {
        case .defaultState:
            if arAnchorsArray.count > 0 {
                for arAnchor in arAnchorsArray {
                    sceneView.session.remove(anchor: arAnchor)
                }
                arAnchorsArray.removeAll()
            }
            if garAnchorsArray.count > 0 {
                for garAnchor in garAnchorsArray {
                    gARSession?.remove(garAnchor)
                }
                garAnchorsArray.removeAll()
            }
            resolvedAnchors = 0
            if self.state == .creatingRoom {
                message = "Failed to create room. Tap HOST or RESOLVE to begin."
            } else {
                message = "Tap HOST or RESOLVE to begin."
            }
            if self.state == .enterRoomCode {
                dismiss(animated: false, completion: {() -> Void in
                })
            } else if self.state == .resolving {
                firebaseReference?.child("hotspot_list").child(roomCode).removeAllObservers()
            }
            toggle(hostButton, enabled: true, title: "HOST")
            toggle(resolveButton, enabled: true, title: "RESOLVE")
            roomCode = ""
            
        case .creatingRoom:
            message = "Creating room..."
            toggle(hostButton, enabled: false, title: "HOST")
            toggle(resolveButton, enabled: false, title: "RESOLVE")
            
        case .roomCreated:
            message = "Tap on a plane to create anchor and host."
            toggle(hostButton, enabled: true, title: "CANCEL")
            toggle(resolveButton, enabled: false, title: "RESOLVE")
            
        case .hosting:
            message = "Hosting anchor..."
            
        case .hostingFinished:
            guard let garAnchor = self.garAnchor, let cloudState = cloudStateString(garAnchor.cloudState) else { return }
            message = "Finished hosting: \(cloudState)"
            
        case .enterRoomCode:
            showRoomCodeDialog()
            
        case .resolving:
            dismiss(animated: false, completion: {() -> Void in
            })
            message = "Resolving anchor..."
            toggle(hostButton, enabled: false, title: "HOST")
            toggle(resolveButton, enabled: true, title: "CANCEL")
            
        case .resolvingFinished:
            guard let garAnchor = self.garAnchor, let cloudState = cloudStateString(garAnchor.cloudState) else { return }
            message = "Finished resolving: \(cloudState)"
        }
        
        self.state = state
        
        updateMessageLabel()
    }
}

extension ViewerViewController: GARSessionDelegate {
    func session(_ session: GARSession, didHostAnchor anchor: GARAnchor) {
        if state != .hosting || !(anchor == garAnchor) {
            return
        }
        garAnchor = anchor
        enter(.hostingFinished)
        firebaseReference?.child("hotspot_list").child(roomCode).child("hosted_anchors").child("id_\(arAnchorsArray.count)").setValue(anchor.cloudIdentifier)
        let timestampInteger = Int64(Date().timeIntervalSince1970 * 1000)
        let timestamp = timestampInteger
        firebaseReference?.child("hotspot_list").child(roomCode).child("updated_at_timestamp").setValue(timestamp)
    }
    
    func session(_ session: GARSession, didFailToHostAnchor anchor: GARAnchor) {
        if state != .hosting || !(anchor == garAnchor) {
            return
        }
        garAnchor = anchor
        enter(.hostingFinished)
    }
    
    func session(_ session: GARSession, didResolve anchor: GARAnchor) {
        if (state != .resolving && resolvedAnchors > arAnchorsArray.count) /*|| !(anchor == garAnchor)*/ {
            print("did return")
            return
        }
        print("did resolve")
        garAnchor = anchor
        
        let newArAnchor = ARAnchor(transform: anchor.transform)
        arAnchorsArray.append(newArAnchor)
        sceneView.session.add(anchor: newArAnchor)
        enter(.resolvingFinished)
        resolvedAnchors += 1
    }
    
    func session(_ session: GARSession, didFailToResolve anchor: GARAnchor) {
        if state != .resolving || !(anchor == garAnchor) {
            return
        }
        garAnchor = anchor
        enter(.resolvingFinished)
    }
}

extension ViewerViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Forward ARKit's update to ARCore session
        try! gARSession?.update(frame)
    }
}

extension ViewerViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if (anchor is ARPlaneAnchor) == false {
            let scene = SCNScene(named: "example.scnassets/andy.scn")
            return scene?.rootNode.childNode(withName: "andy", recursively: false)
        } else {
            return SCNNode()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first
            else { return }
        
        planeNode.removeFromParentNode()
    }
}

extension ViewerViewController: RoomViewModelDelegate {
    func didCreateRoom(lastRoomNumber: Int) {
        self.lastRoomNumber = lastRoomNumber
        self.roomCode = "\(lastRoomNumber)"
        enter(.roomCreated)
    }

    func didReceiveLastRoomNumber(lastRoomNumber: Int) {
        self.lastRoomNumber = lastRoomNumber
    }
    
    func didFailCreatingRoom(error: Error) {
        enter(.defaultState)
    }
    
    func didFailGettingLastRoomNumber(error: Error) {
        showError(withMessage: "An error occured while retrieving the room number: \(error.localizedDescription)")
    }
}
