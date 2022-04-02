//
//  MeshViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import MeshKit
import Combine
import SwiftUI

class MeshViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let view = MeshView()
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.subviews.forEach({ $0.layer.cornerRadius = 30; $0.layer.cornerCurve = .continuous; $0.layer.masksToBounds = true })
        
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
//        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var grabbersView: GrabbersView = {
        let view = GrabbersView(meshService)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var meshService: MeshService = .init()
    
    init(_ meshService: MeshService) {
        self.meshService = meshService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(UIDevice.current.userInterfaceIdiom == .mac, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(meshView)
        meshView.addSubview(grabbersView)
        
        NSLayoutConstraint.activate([
//            meshView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//            meshView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            grabbersView.leadingAnchor.constraint(equalTo: meshView.leadingAnchor),
            grabbersView.trailingAnchor.constraint(equalTo: meshView.trailingAnchor),
            grabbersView.bottomAnchor.constraint(equalTo: meshView.bottomAnchor),
            grabbersView.topAnchor.constraint(equalTo: meshView.topAnchor)
        ])
        
//        meshView.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude).activate(with: .defaultLow)
//
//        meshView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor).activate(with: .defaultHigh)
//        meshView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).activate(with: .defaultHigh)
//
//        meshView.widthAnchor.constraint(equalTo: meshView.heightAnchor).activate(with: .required)
        
        meshService.$colors
            .sink { [weak self] colors in
                guard let self = self else { return }
                self.meshView.create(colors, width: self.meshService.width, height: self.meshService.height, subdivisions: self.meshService.subdivsions)
                
                self.grabbersView.setPoints(colors, width: self.meshService.width, height: self.meshService.height)
            }
            .store(in: &cancellables)
        
        meshService.$subdivsions
            .sink { [weak self] subdivions in
                guard let self = self else { return }
                self.meshView.create(self.meshService.colors, width: self.meshService.width, height: self.meshService.height, subdivisions: subdivions)
            }
            .store(in: &cancellables)
        
        meshService.$isRenderingAsWireframe
            .sink { [weak self] isRenderingAsWireframe in
                self?.meshView.debugOptions = isRenderingAsWireframe ? [.renderAsWireframe] : []
            }
            .store(in: &cancellables)
        
        meshService.$selectedPoint
            .sink { [weak self] point in
                self?.grabbersView.subviews.forEach({ ($0 as? GrabbersView.GrabberView)?.updateSelection(point) })
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        meshView.create(meshService.colors,
                        width: meshService.width,
                        height: meshService.height,
                        subdivisions: meshService.subdivsions)
        
        grabbersView.setPoints(meshService.colors,
                               width: meshService.width,
                               height: meshService.height)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let meshSize = min(view.bounds.height, view.bounds.width) - (40 + (view.safeAreaInsets.top * 2))
        meshView.frame = CGRect(x: 20, y: 20, width: meshSize, height: meshSize)
        meshView.center = CGPoint(x: view.center.x, y: view.center.y + (view.safeAreaInsets.top / 2))
        
        grabbersView.setPoints(meshService.colors, width: meshService.width, height: meshService.height, withAnimation: false)
    }
}

struct EditorView: UIViewControllerRepresentable {
    @EnvironmentObject var meshService: MeshService
    
    func makeUIViewController(context: Context) -> MeshViewController {
        return .init(meshService)
    }
    
    func updateUIViewController(_ uiViewController: MeshViewController, context: Context) {
        uiViewController.meshService = meshService
    }
}

class GrabbersView: UIView {
    
    private(set) var width: Int = 0
    private(set) var height: Int = 0
    
    var meshService: MeshService = .init()
    
    init(_ meshService: MeshService = .init()) {
        super.init(frame: .zero)
        self.meshService = meshService
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private final func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deselectGrabbers))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func deselectGrabbers() {
        meshService.selectedPoint = nil
    }
    
    func setPoints(_ colors: [MeshNode.Color], width: Int, height: Int, withAnimation animates: Bool = true) {
        self.width = width
        self.height = height
        
        var updatedGrabbers: Set<GrabberView> = []
        
        colors.forEach { color in
            if let grabber = (subviews as? [GrabberView])?.first(where: { $0.node.point == color.point }) {
                grabber.updateLocation(color.location, meshSize: CGSize(width: width, height: height), size: CGSize(width: bounds.width, height: bounds.height), withAnimation: animates)
                
                grabber.updateSelection(meshService.selectedPoint)
                
                updatedGrabbers.insert(grabber)
            } else {
                let view = createGrabber(color)
                addSubview(view)
                
                updatedGrabbers.insert(view)
            }
        }
        
        (subviews as? [GrabberView])?.forEach { grabber in
            if !updatedGrabbers.contains(where: { $0.node.point == grabber.node.point }) {
                grabber.removeFromSuperview()
            }
        }
    }
    
    final func createGrabber(_ node: MeshNode.Color) -> GrabberView {
        let view = GrabberView(node, meshSize: CGSize(width: width, height: height), parentSize: bounds.size, meshService: meshService)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        let pointerInteraction = UIPointerInteraction(delegate: self)
        view.addInteraction(pointerInteraction)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(updateGesture))
        panGesture.allowedScrollTypesMask = [.all]
        
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    @objc func updateGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let grabberView = (subviews as? [GrabberView])?.first(where: { $0.node == (recognizer.view as? GrabberView)?.node }) else { return }
        
        let meshService = meshService
        
        if recognizer.state == .began {
            meshService.selectedPoint = .init(x: grabberView.node.point.x, y: grabberView.node.point.y)
        }
        
        guard grabberView.node.point.x != 0 && grabberView.node.point.x != meshService.width - 1 && grabberView.node.point.y != 0 && grabberView.node.point.y != meshService.height - 1 else { return }
        
        let location = recognizer.location(in: self)
        
        let width = CGFloat(width) - 1
        let height = CGFloat(height) - 1
        
        let x = min(width, max(0, location.x / (bounds.width / width)))
        let y = height - min(height, max(0, location.y / (bounds.height / height)))
        
        if let index = meshService.colors.firstIndex(where: { $0.point == grabberView.node.point }) {
            meshService.colors[index].location = (Float(x), Float(y))
        }
    }
    
    class GrabberView: UIView {
        var node: MeshNode.Color
        var meshSize: CGSize
        
        var meshService: MeshService = .init()
        
        init(_ node: MeshNode.Color, meshSize: CGSize, parentSize: CGSize? = nil, meshService: MeshService = .init()) {
            self.node = node
            self.meshSize = meshSize
#if targetEnvironment(macCatalyst)
            super.init(frame: .init(origin: .zero, size: .init(width: 20, height: 20)))
#else
            super.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
#endif
            self.meshService = meshService
            
            setup(meshSize: meshSize, parentSize: parentSize)
        }
        
        override init(frame: CGRect) {
            fatalError()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        final func setup(meshSize: CGSize, parentSize: CGSize?) {
            backgroundColor = UIColor.secondarySystemFill
            layer.cornerRadius = bounds.width / 2
            
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 10
            layer.shadowOpacity = 0.4
            
            if !(node.point.x != 0 && node.point.x != Int(meshSize.width) - 1 && node.point.y != 0 && node.point.y != Int(meshSize.height) - 1) {
                backgroundColor = UIColor.quaternarySystemFill
            }
            
            if let size = parentSize {
                updateLocation(node.location, meshSize: meshSize, size: size)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectNode))
            tapGesture.numberOfTapsRequired = 1
            addGestureRecognizer(tapGesture)
        }
        
        @objc func selectNode() {
            meshService.selectedPoint = .init(x: node.point.x, y: node.point.y)
        }
        
        final func updateSelection(_ selectedPoint: MeshService.Point?) {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction], animations: { [weak self] in
                if let selectedPoint = selectedPoint, let node = self?.node, selectedPoint.nodePoint == node.point {
                    self?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                    self?.transform = .init(scaleX: 1.1, y: 1.1)
                } else {
                    if let node = self?.node, let meshSize = self?.meshSize {
                        if !(node.point.x != 0 && node.point.x != Int(meshSize.width) - 1 && node.point.y != 0 && node.point.y != Int(meshSize.height) - 1) {
                            self?.backgroundColor = UIColor.quaternarySystemFill
                        } else {
                            self?.transform = .identity
                            self?.backgroundColor = UIColor.secondarySystemFill
                        }
                    }
                }
            })
        }
        
        final func updateLocation(_ location: (x: Float, y: Float), meshSize: CGSize, size: CGSize, withAnimation animates: Bool = true) {
            self.meshSize = meshSize
            let point = CGPoint(x: (size.width / (meshSize.width - 1)) * CGFloat(location.x),
                                y: size.height - ((size.height / (meshSize.height - 1)) * CGFloat(location.y)))
            
            if animates {
                UIView.animate(withDuration: 0.05, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) { [weak self] in
                    self?.center = point
                }
            } else {
                center = point
            }
        }
    }
}

extension GrabbersView: UIPointerInteractionDelegate {
#if !targetEnvironment(macCatalyst)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .hidden()
    }
#endif
}

extension NSLayoutConstraint {
    @discardableResult
    func activate(with priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        isActive = true
        return self
    }
}
