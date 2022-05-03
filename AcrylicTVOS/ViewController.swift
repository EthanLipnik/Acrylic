//
//  ViewController.swift
//  AcrylicTVOS
//
//  Created by Ethan Lipnik on 5/1/22.
//

import UIKit
import MeshKit

class ViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let meshView = MeshView()
        
        meshView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        meshView.addSubview(snapshotView)
        
        snapshotView.frame = meshView.bounds
        
        meshView.isUserInteractionEnabled = false
        
        return meshView
    }()
    
    lazy var snapshotView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.isHidden = true
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return imageView
    }()
    
    lazy var instructionsButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        
        button.addTarget(self, action: #selector(showInstructions), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isHidden = true
        
        return button
    }()
    
    lazy var timerButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setImage(UIImage(systemName: "timer", compatibleWith: traitCollection), for: .normal)
        
        button.addTarget(self, action: #selector(showTimer), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isHidden = true
        
        return button
    }()
    
    lazy var meshService: MeshService = {
        let meshService = MeshService()
        meshService.width = 5
        meshService.height = 5
#if !targetEnvironment(simulator)
        meshService.subdivsions = 32
#else
        meshService.subdivsions = 8
#endif
        meshService.generate(Palette: .randomPalette(includesMonochrome: false),
                             luminosity: .bright,
                             positionMultiplier: 0.6)
        
        return meshService
    }()
    
    lazy var gradientTimer: Timer? = {
        return Timer.scheduledTimer(timeInterval: 30,
                                    target: self,
                                    selector: #selector(newGradient),
                                    userInfo: nil,
                                    repeats: true)
    }()
    
    lazy var hideUITimer: Timer? = {
        return Timer.scheduledTimer(timeInterval: 5,
                                    target: self,
                                    selector: #selector(toggleUI),
                                    userInfo: nil,
                                    repeats: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(meshView)
        view.addSubview(instructionsButton)
        view.addSubview(timerButton)
        
        NSLayoutConstraint.activate([
            instructionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            instructionsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            
            timerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            timerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
        ])
        
        meshView.create(self.meshService.colors,
                        width: self.meshService.width,
                        height: self.meshService.height,
                        subdivisions: self.meshService.subdivsions)
        
        createDisplayLink()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newGradient))
        view.addGestureRecognizer(tapGesture)
        
        let menuGesture = UITapGestureRecognizer(target: self, action: #selector(toggleUI))
        menuGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(menuGesture)
        
        toggleUI()
        gradientTimer?.fire()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        meshView.frame = CGRect(x: -(view.bounds.width - view.bounds.height), y: 0, width: view.bounds.width * 2, height: view.bounds.height * 2)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            newGradient()
        }
    }
    
    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(step))
        if #available(tvOS 15.0, *) {
            displaylink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
        } else {
            displaylink.preferredFramesPerSecond = 60
        }
        
        displaylink.add(to: .main,
                        forMode: .default)
    }
    
    var isGeneratingNewGradient: Bool = false
    @objc func newGradient() {
        guard !isGeneratingNewGradient else { return }
        isGeneratingNewGradient = true
        
        let timerInterval = gradientTimer?.timeInterval ?? 30
        gradientTimer?.invalidate()
        gradientTimer = nil
        
        snapshotView.alpha = 0
        snapshotView.isHidden = false
        
        snapshotView.image = meshView.snapshot()
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut]) { [weak self] in
            self?.snapshotView.alpha = 1
        } completion: { [weak self] _ in
            self?.meshService.generate(Palette: .randomPalette(includesMonochrome: false),
                                       luminosity: self?.traitCollection.userInterfaceStyle == .dark ? .dark : .bright,
                                 positionMultiplier: 0.6)
            
            UIView.animate(withDuration: 1,
                           delay: 0,
                           options: [.curveEaseInOut]) { [weak self] in
                self?.snapshotView.alpha = 0
            } completion: { [weak self] _ in
                self?.snapshotView.isHidden = true
                
                if let self = self {
                    self.gradientTimer = Timer(timeInterval: timerInterval, target: self, selector: #selector(self.newGradient), userInfo: nil, repeats: true)
                    
                    if let gradientTimer = self.gradientTimer {
                        RunLoop.main.add(gradientTimer, forMode: .default)
                    }
                }
                
                self?.isGeneratingNewGradient = false
            }
        }
    }
    
    @objc func toggleUI() {
        hideUITimer?.invalidate()
        hideUITimer = nil
        
        if instructionsButton.isHidden || timerButton.isHidden {
            instructionsButton.alpha = 0
            instructionsButton.isHidden = false
            
            timerButton.alpha = 0
            timerButton.isHidden = false
            
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) { [weak self] in
                self?.instructionsButton.alpha = 1
                self?.timerButton.alpha = 1
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.hideUITimer = Timer.scheduledTimer(timeInterval: 5,
                                                        target: self,
                                                        selector: #selector(self.toggleUI),
                                                        userInfo: nil,
                                                        repeats: true)
            }
        } else {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) { [weak self] in
                self?.instructionsButton.alpha = 0
                self?.timerButton.alpha = 0
            } completion: { [weak self] _ in
                self?.instructionsButton.isHidden = true
                self?.timerButton.isHidden = true
            }
        }
    }
    
    @objc func showInstructions() {
        let message = """
        • Click the touchpad to generate a new mesh.
        • Press the Menu button to show UI.
        • You can download the iOS and macOS app for more features.
        """
        let alertView = UIAlertController(title: "Instructions", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertView, animated: true)
    }
    
    @objc func showTimer() {
        func updateTimer(_ duration: TimeInterval) {
            gradientTimer?.invalidate()
            gradientTimer = nil
            
            gradientTimer = Timer(timeInterval: duration, target: self, selector: #selector(newGradient), userInfo: nil, repeats: true)
            gradientTimer?.fire()
            
            if let gradientTimer = gradientTimer {
                RunLoop.main.add(gradientTimer, forMode: .default)
            }
        }
        
        let alertView = UIAlertController(title: "Timer Duration", message: nil, preferredStyle: .alert)
        
#if DEBUG
        alertView.addAction(UIAlertAction(title: "[DEBUG] 2s", style: .destructive) { _ in
            updateTimer(2)
        })
#endif
        
        alertView.addAction(UIAlertAction(title: "30s", style: .default) { _ in
            updateTimer(30)
        })
        
        alertView.addAction(UIAlertAction(title: "1m", style: .default) { _ in
            updateTimer(60)
        })
        
        alertView.addAction(UIAlertAction(title: "3m", style: .default) { _ in
            updateTimer(180)
        })
        
        alertView.addAction(UIAlertAction(title: "5m", style: .default) { _ in
            updateTimer(300)
        })
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertView, animated: true)
    }
    
    struct Point: Hashable {
        var x: Int
        var y: Int
    }
    
    lazy var directions: [Point: CGPoint] = {
        let nodes = meshService.colors
            .map({ $0.point })
            .filter({ point in
                let x = point.x
                let y = point.y
                return x != 0 && x != meshService.width - 1 && y != 0 && y != meshService.height - 1
            })
            .map { point -> (Point, CGPoint) in
                let x = CGFloat(point.x)
                let y = CGFloat(point.y)
                
                return (Point(x: point.x, y: point.y), CGPoint(x: .random(in: (x - 0.6)..<(x + 0.6)), y: .random(in: (y - 0.6)..<(y + 0.6))))
            }
        
        var directions = [Point: CGPoint]()
        
        nodes.forEach({ directions[$0.0] = $0.1 })
        
        return directions
    }()
    
    @objc func step(displaylink: CADisplayLink) {
        var framerate: Float
        if #available(tvOS 15.0, *) {
            framerate = displaylink.preferredFrameRateRange.preferred ?? displaylink.preferredFrameRateRange.maximum
        } else {
            framerate = Float(displaylink.preferredFramesPerSecond)
        }
        
        if framerate == 0 {
            framerate = 60
        }
        
        for i in 0..<meshService.colors.count {
            let color = meshService.colors[i]
            let point = color.point
            if var direction = directions[Point(x: point.x, y: point.y)] {
                
                func directionX() -> Float {
                    return Float(direction.x) - color.location.x
                }
                func directionY() -> Float {
                    return Float(direction.y) - color.location.y
                }
                
                if Float(round(direction.x)) == round(color.location.x) || Float(round(direction.y)) == round(color.location.y) {
                    let x = CGFloat(point.x)
                    let y = CGFloat(point.y)
                    let newDirection = CGPoint(x: .random(in: (x - 0.6)..<(x + 0.6)), y: .random(in: (y - 0.6)..<(y + 0.6)))
                    direction = newDirection
                    directions[Point(x: point.x, y: point.y)] = newDirection
                }
                
                meshService.colors[i].location.x += directionX() / framerate / 10
                meshService.colors[i].location.y += directionY() / framerate / 10
            }
        }
        
        meshView.create(self.meshService.colors,
                        width: self.meshService.width,
                        height: self.meshService.height,
                        subdivisions: self.meshService.subdivsions)
    }
}

