//
//  SampleContainerOperation.swift
//  Operations
//
//  Created by Peter Sipos on 2019. 04. 12..
//  Copyright © 2019. Peter Sipos. All rights reserved.
//

import Foundation

class SampleContainerOperation: BasicOperation {
    private let operationCounter: Float = 3.0
    
    override func main() {
        autoreleasepool {
            super.main()
            
            let _ = runOperation1()
            // work with operation 1
            // ......
            
            if self.error == nil {  // throw by operation 1
                print("first Operation OK")
                let _ = runOperation2()
                // work with operation 2
                // ......
            }
            
            if self.error == nil { // throw by operation 2
                print("second Operation OK")
                let _ = runOperation3()
                // work with operation 3
                // ......
            }
            
            finish()
        }
    }
    
    func processing(_ operation: BasicOperation) {
        self.progressValue = (100.0 / operationCounter) * Float(operation.tag - 1) + operation.progressValue / operationCounter
        super.processing()
    }
    
    private func runOperation1() -> URLOperation {
        let operation = URLOperation()
        operation.parent = self
        operation.tag = 1
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        operation.isSync = true
        operation.queue = self.ownedQueue
        operation.run()
        self.error = operation.error // feel the trick!
        
        return operation
    }
    
    private func runOperation2() -> URLOperation {
        let operation = URLOperation()
        operation.parent = self
        operation.tag = 2
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        operation.isDownloadOperation = true
        operation.isSync = true
        operation.queue = self.ownedQueue
        operation.run()
        self.error = operation.error // feel the trick!
        
        return operation
    }
    
    private func runOperation3() -> URLOperation {
        let operation = URLOperation()
        operation.parent = self
        operation.tag = 3
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        operation.isDownloadOperation = true
        operation.isSync = true
        operation.queue = self.ownedQueue
        operation.run()
        self.error = operation.error // feel the trick!
        
        return operation
    }
}
