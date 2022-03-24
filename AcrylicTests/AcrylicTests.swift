//
//  AcrylicTests.swift
//  AcrylicTests
//
//  Created by Ethan Lipnik on 10/23/21.
//

import XCTest
@testable import Acrylic

class AcrylicTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRender() {
        measure(metrics: [XCTMemoryMetric()]) {
            
            DispatchQueue.global(qos: .userInitiated).async {
                let meshService = MeshService()
                meshService.width = 3
                meshService.height = 3
                meshService.subdivsions = 36
                meshService.randomizePointsAndColors()
                
#if targetEnvironment(macCatalyst)
                let resolution = CGSize(width: 6144, height: 6144)
#else
                let resolution = CGSize(width: 1280, height: 1280)
#endif
                
                let render = meshService.render(resolution: resolution)
                
                DispatchQueue.main.async {
                    do {
                        let _ = render.pngData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
