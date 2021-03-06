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
            
            if self.error == nil {  // skip the next step if error occurs
                print("first Operation OK")
                let downloadOperation = runOperation2()
                print(downloadOperation.filePath)
                // work with operation 2
                // ......
            }
            
            if self.error == nil { // skip the next step if error occurs
                print("second Operation OK")
                let downloadOperation = runOperation3()
                print(downloadOperation.filePath)
                // work with operation 3
                // ......
            }
            
            var i = 0
            while i < 5 {
                if self.error == nil && self.isCancelled == false { // skip the next step if error occurs
                    print("second Operation OK")
                    let downloadOperation = runOperation3()
                    print(downloadOperation.filePath)
                    // work with operation 3
                    // ......
                    if self.isCancelled == false {
                        sleep(3)
                    }
                }
                
                i += 1
                
                if self.isCancelled == true {
                    break
                }
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
        operation.tag = 1
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        self.addSubOperation(operation)
        
        return operation
    }
    
    private func runOperation2() -> URLOperation {
        let operation = URLOperation()
        operation.tag = 2
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        operation.isDownloadOperation = true
        self.addSubOperation(operation)
        
        return operation
    }
    
    private func runOperation3() -> URLOperation {
        let operation = URLOperation()
        operation.tag = 3
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in self.progressValue = operation.progressValue; self.processing(operation) }
        operation.isDownloadOperation = true
        self.addSubOperation(operation)
        
        return operation
    }
}
