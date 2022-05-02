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
    
    lazy var meshService: MeshService = {
        let meshService = MeshService()
        meshService.width = 5
        meshService.height = 5
        meshService.subdivsions = 32
        meshService.generate(Palette: .randomPalette(includesMonochrome: false),
                             luminosity: .bright,
                             positionMultiplier: 0.6)
        
        return meshService
    }()
    
    lazy var timer: Timer = {
        return Timer.scheduledTimer(timeInterval: 300,
                                    target: self,
                                    selector: #selector(newGradient),
                                    userInfo: nil,
                                    repeats: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(meshView)
        
        meshView.create(self.meshService.colors,
                        width: self.meshService.width,
                        height: self.meshService.height,
                        subdivisions: self.meshService.subdivsions)
        
        createDisplayLink()
        
        timer.fire()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newGradient))
        view.addGestureRecognizer(tapGesture)
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
        displaylink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
        
        displaylink.add(to: .main,
                        forMode: .default)
    }
    
    var isGeneratingNewGradient: Bool = false
    @objc func newGradient() {
        guard !isGeneratingNewGradient else { return }
        isGeneratingNewGradient = true
        
        timer.invalidate()
        
        snapshotView.alpha = 0
        snapshotView.isHidden = false
        
        snapshotView.image = meshView.snapshot()
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) { [weak self] in
            self?.snapshotView.alpha = 1
        } completion: { [weak self] _ in
            self?.meshService.generate(Palette: .randomPalette(includesMonochrome: false),
                                       luminosity: self?.traitCollection.userInterfaceStyle == .dark ? .dark : .bright,
                                 positionMultiplier: 0.6)
            
            UIView.animate(withDuration: 1,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) { [weak self] in
                self?.snapshotView.alpha = 0
            } completion: { [weak self] _ in
                self?.snapshotView.isHidden = true
                
                self?.timer.fire()
                self?.isGeneratingNewGradient = false
            }
        }
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
        let framerate = displaylink.preferredFrameRateRange.preferred ?? displaylink.preferredFrameRateRange.maximum
        
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
                
                meshService.colors[i].location.x += directionX() / framerate / 5
                meshService.colors[i].location.y += directionY() / framerate / 5
            }
        }
        
        meshView.create(self.meshService.colors,
                        width: self.meshService.width,
                        height: self.meshService.height,
                        subdivisions: self.meshService.subdivsions)
    }
}

