//
//  SampleContainerOperation.swift
//  NSURLOperation
//
//  Created by Peter Sipos on 2019. 04. 09..
//  Copyright © 2019. Szpooky. All rights reserved.
//

import Foundation

class SampleContainerOperation: BasicOperation {
    override func main() {
        autoreleasepool {
            super.main()
            
            var operation : URLOperation = runOperation()
            
            if let error = self.error {
                print(error.localizedDescription)
            } else {
                print("first Operation OK")
                operation = runOperation()
            }
            
            if let error = self.error {
                print(error.localizedDescription)
            } else {
                print("second Operation OK")
                operation = runOperation()
            }
            
            if let error = self.error {
                print(error.localizedDescription)
            } else {
                print("third Operation OK")
            }
            
            finish()
        }
    }
    
    private func runOperation() -> URLOperation {
        let operation = URLOperation()
        let request = URLRequest(url: URL(string: "https://d2qguwbxlx1sbt.cloudfront.net/TextInMotion-VideoSample-1080p.mp4")!)
        operation.request = request
        operation.progressHandler = { (operation) -> Void in print("progress: " + String(operation.progressValue)) }
        //operation.saveToFile = true
        operation.isSync = true
        operation.queue = self.ownedQueue
        operation.run()
        self.error = operation.error
        
        return operation
    }
}
