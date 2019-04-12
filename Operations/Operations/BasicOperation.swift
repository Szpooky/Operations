//
//  ContainerOperation.swift
//  NSURLOperation
//
//  Created by Peter Sipos on 2019. 04. 09..
//  Copyright © 2019. Szpooky. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let OperationNotification = Notification.Name("OperationNotification")
    static let OperationRequestNotification = Notification.Name("OperationCenterNotification")
}

class BasicOperation: Operation {
    public let identifier: String = UUID().uuidString
    open var tag: Int = 0
    open var data: Data = Data()
    open var error: Error?
    open var object: Any?
    open var progressValue: Float = 0.0
    open var progressHandler: ((BasicOperation) -> Swift.Void) = { (operation) -> Void in }
    open var completionHandler: ((BasicOperation) -> Swift.Void) = { (operation) -> Void in }
    open var isSync: Bool = false
    open var isOperationRunning: Bool = false
    open var isOperationFinished: Bool = false
    open private(set) var isOperationCancelled: Bool = false
    open private(set) var isWaiting: Bool = false
    open var queue: OperationQueue = OperationCenter.shared.defaultQueue
    open lazy var ownedQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private let taskSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    override init() {
        super.init()
        OperationCenter.shared.operationCount += 1
        self.name = NSStringFromClass(type(of: self))
        NotificationCenter.default.addObserver(self, selector: #selector(report), name: NSNotification.Name.OperationRequestNotification, object: nil)
    }
    
    func run() {
        autoreleasepool {
            queue.addOperation(self)
            if isSync == true {
                let _ = semaphore.wait(timeout: .now() + 99999)
            }
        }
    }
    
    override func cancel() {
        isOperationCancelled = true
        ownedQueue.cancelAllOperations()
    }
    
    func isCancelled() -> Bool {
        return isOperationCancelled
    }
    
    func isRunning() -> Bool {
        return isOperationRunning
    }
    
    func isFinished() -> Bool {
        return isOperationFinished
    }
    
    open func started() {
        progressHandler(self)
    }
    
    open func processing() {
        progressHandler(self)
    }
    
    open func finish() {
        if isOperationCancelled == true && error == nil {
            error = NSError(domain: "URLOperation", code: -999, userInfo: [NSLocalizedDescriptionKey : "Operation cancelled"])
        }
        completionHandler(self)
        
        if isWaiting == true {
            taskSemaphore.signal()
        }
        
        self.isOperationRunning = false
        
        if error == nil && isOperationCancelled == false {
            isOperationFinished = true
        }
        
        if isSync == true {
            semaphore.signal()
        }
    }
    
    @objc func report() {
        OperationCenter.shared.reportOperation(self)
    }
    
    func forceQuit() {
        // under construction
        taskSemaphore.signal()
        semaphore.signal()
    }
    
    override func waitUntilFinished() {
        autoreleasepool {
            isWaiting = true
            let _ = taskSemaphore.wait(timeout: .now() + 99999)
        }
    }
    
    override func main() {
        if self.isCancelled == true {
            finish();
            return;
        }
        
        self.isOperationRunning = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        OperationCenter.shared.operationCount -= 1
        print("deinit " + (self.name ?? ""))
    }
}
