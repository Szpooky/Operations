//
//  BasicOperation.swift
//  Operations
//
//  Created by Peter Sipos on 2019. 04. 12..
//  Copyright © 2019. Peter Sipos. All rights reserved.
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
    open weak var parent: BasicOperation?
    open var object: Any?
    open var progressValue: Float = 0.0
    open var progressHandler: ((BasicOperation) -> Swift.Void) = { (operation) -> Void in }
    open var completionHandler: ((BasicOperation) -> Swift.Void) = { (operation) -> Void in }
    open var isSync: Bool = false
    open var queue: OperationQueue = OperationCenter.shared.defaultQueue
    open lazy var ownedQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private let taskSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private var isOperationExecuting: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    private var isOperationFinished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    private var isOperationCancelled: Bool = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    private var isWaiting: Bool = false
    
    override init() {
        super.init()
        OperationCenter.shared.operationCount += 1
        self.name = NSStringFromClass(type(of: self))
        NotificationCenter.default.addObserver(self, selector: #selector(report), name: NSNotification.Name.OperationRequestNotification, object: nil)
    }
    
    func run() {
        autoreleasepool {
            if self.isExecuting == false && self.isCancelled == false && self.isFinished == false {
                queue.addOperation(self)
                if isSync == true {
                    let _ = semaphore.wait(timeout: .now() + 99999)
                }
            }
        }
    }
    
    override func start() {
        super.start()
    }
    
    override func cancel() {
        isOperationCancelled = true
        ownedQueue.cancelAllOperations()
    }
    
    override var isCancelled : Bool {
        return isOperationCancelled
    }
    
    override var isExecuting: Bool {
        return isOperationExecuting
    }
    
    override var isFinished: Bool {
        return isOperationFinished
    }
    
    override var isReady: Bool {
        return true
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
        
        self.isOperationExecuting = false
        
        isOperationFinished = true
        
        if isSync == true {
            semaphore.signal()
        }
    }
    
    @objc func report() {
        OperationCenter.shared.reportOperation(self)
    }
    
    func wait() {
        autoreleasepool {
            if isWaiting == false {
                isWaiting = true
                let _ = taskSemaphore.wait(timeout: .now() + 99999)
            }
        }
    }
    
    override func main() {
        if self.isCancelled == true {
            finish();
            return;
        }
        
        isOperationExecuting = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        OperationCenter.shared.operationCount -= 1
        print("deinit " + (self.name ?? ""))
    }
}
