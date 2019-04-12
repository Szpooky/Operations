//
//  OperationCenter.swift
//  NSURLOperation
//
//  Created by Peter Sipos on 2019. 04. 09..
//  Copyright © 2019. Szpooky. All rights reserved.
//

import Foundation

class OperationCenter: NSObject {
    public static let shared = OperationCenter()
    open var operationCount: Int = 0
    open private(set) var operations: [BasicOperation] = [BasicOperation]()
    open private(set) var defaultQueue: OperationQueue = OperationQueue()
    open private(set) lazy var prioritedQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let operationsQueue = DispatchQueue(label: "com.URLOperationCenter.operations")
    
    open func reportAllOperations(completion: @escaping ([BasicOperation]) -> Void) {
        operations.removeAll()
        if(operationCount > 0) {
            NotificationCenter.default.post(name: NSNotification.Name.OperationRequestNotification, object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(self.operations)
                self.operations.removeAll()
            }
        }
    }
    
    open func reportOperation(_ operation: BasicOperation) {
        operationsQueue.sync {
            operations.append(operation)
        }
    }
    
    open func cancelAllOperations() {
        defaultQueue.cancelAllOperations()
        prioritedQueue.cancelAllOperations()
    }
}
