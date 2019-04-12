//
//  NSURLOperation.swift
//  NSURLOperation
//
//  Created by Szpooky on 2019. 04. 05..
//  Copyright © 2019. Szpooky. All rights reserved.
//

import Foundation

class URLOperation: BasicOperation {
    open var request: URLRequest?
    open var response: HTTPURLResponse?
    open var session: URLSession = URLSessionObserver.shared.defaultSession
    open var saveToFile: Bool = false
    open var filePath: String = ""
    open weak var task: URLSessionTask?
    public static let defaultQueue: OperationQueue = OperationQueue()
    public static let prioritedQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func cancel() {
        super.cancel()
        if let task = self.task { task.cancel() } else { finish() }
    }
    
    override func main() {
        autoreleasepool {
            super.main()
            
            if let request = self.request, error == nil {
                if saveToFile == true {
                    let task = self.session.downloadTask(with: request)
                    self.task = task
                } else {
                    let task = self.session.dataTask(with: request)
                    self.task = task
                }
                
                if let task = self.task {
                    task.taskDescription = identifier
                    URLSessionObserver.shared.addURLOperation(self)
                    print("operationID: " + identifier)
                    task.resume()
                    self.isOperationRunning = true
                    
                    waitUntilFinished()
                    
                    URLSessionObserver.shared.removeURLOperation(self)
                }
                
                print("here")
            }
        }
    }
    
    class URLSessionObserver: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {
        public static let shared = URLSessionObserver()
        open private(set) var defaultSession: URLSession = URLSession.shared
        open private(set) var backgroundSession: URLSession = URLSession.shared
        private(set) var operations: [String: URLOperation] = [:]
        private let operationsQueue = DispatchQueue(label: "com.URLOperationCenter.operations")
        
        override init() {
            super.init()
            
            defaultSession = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: defaultQueue)
            
            backgroundSession = URLSession.init(configuration: URLSessionConfiguration.background(withIdentifier: "shared"), delegate: self, delegateQueue: defaultQueue)
        }
        
        func cancelAllOperations() {
            URLOperation.defaultQueue.cancelAllOperations()
            URLOperation.prioritedQueue.cancelAllOperations()
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            if let operationID = dataTask.taskDescription, let httpResponse = response as? HTTPURLResponse {
                self.operation(operationID: operationID) { (operation) in
                    operation.response = httpResponse
                    operation.processing()
                    print("didReceive response: " + String(describing: httpResponse))
                }
            }
            completionHandler(URLSession.ResponseDisposition.allow)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            if let operationID = downloadTask.taskDescription {
                self.operation(operationID: operationID) { (operation) in
                    operation.filePath = location.absoluteString
                    operation.finish()
                    print("didFinishDownloadingTo: " + location.absoluteString)
                }
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            if let operationID = downloadTask.taskDescription {
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite == 0 ? 1 : totalBytesExpectedToWrite) * 100.0
                
                self.operation(operationID: operationID) { (operation) in
                    operation.progressValue = progress
                    operation.processing()
                    print("progress: " + String(describing: operationID))
                }
            }
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if let operationID = dataTask.taskDescription {
                self.operation(operationID: operationID) { (operation) in
                    if data.count > 0 {
                        operation.data.append(data)
                        if let response = operation.response, let contentLengthValue = response.allHeaderFields["Content-Length"] as? String {
                            if let contentLength = Float(contentLengthValue), contentLength != 0.0 {
                                operation.progressValue = (Float(operation.data.count) / contentLength) * 100.0
                            }
                        }
                    }
                    operation.processing()
                    print("didReceive data: " + String(describing: operationID))
                }
            }
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
            downloadTask.taskDescription = dataTask.taskDescription
            if let operationID = downloadTask.taskDescription {
                self.operation(operationID: operationID) { (operation) in
                    operation.task = downloadTask
                }
            }
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
            streamTask.taskDescription = dataTask.taskDescription
            if let operationID = streamTask.taskDescription {
                self.operation(operationID: operationID) { (operation) in
                    operation.task = streamTask
                }
            }
        }
        
        func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
            
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let operationID = task.taskDescription {
                self.operation(operationID: operationID) { (operation) in
                    operation.error = error
                    operation.finish()
                    print("didCompleteWithError: " + String(describing: operationID))
                }
            }
        }
        
        open func addURLOperation(_ operation: URLOperation) {
            operationsQueue.sync {
                operations[operation.identifier] = operation
            }
        }
        
        open func removeURLOperation(_ operation: URLOperation) {
            operationsQueue.sync {
                operations[operation.identifier] = nil
            }
        }
        
        open func operation(operationID: String, completion: @escaping (URLOperation) -> Void) {
            operationsQueue.sync {
                if let operation = operations[operationID] {
                    completion(operation)
                }
            }
        }
    }
}
