//
//  ViewController.swift
//  Operations
//
//  Created by Peter Sipos on 2019. 04. 12..
//  Copyright © 2019. Peter Sipos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    weak var operation : SampleContainerOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.green
        button.setTitle("Start", for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 300.0, height: 60.0)
        button.center = view.center
        view.addSubview(button)
        button.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
        
        print("end viewDidLoad method")
    }

    @objc func cancelAction(sender: UIButton) {
        let title = sender.title(for: .normal)
        
        if let title = title, title == "Start" {
            let operation = createOperation()
            self.operation = operation
            operation.run()
            sender.setTitle("Cancel", for: .normal)
        } else {
            if let operation = self.operation {
                operation.cancel()
            }
            sender.setTitle("Start", for: .normal)
        }
    }
    
    func createOperation() -> SampleContainerOperation {
        
        let operation = SampleContainerOperation()
        operation.completionHandler = { (operation) -> Void in
            print("completionHandler SampleContainerOperation")
            if let error = operation.error {
                print(operation.error == nil ? "" : error.localizedDescription)
            }
        }
        operation.progressHandler = { (operation) -> Void in
            print(operation.progressValue)
        }
        //operation.saveToFile = true
        //operation.isSync = true
        operation.queue = URLOperation.prioritedQueue
        //operation.run()
        
        return operation
    }
}

