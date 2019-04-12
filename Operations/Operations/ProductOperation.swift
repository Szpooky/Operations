//
//  ProductOperation.swift
//  NSURLOperation
//
//  Created by Peter Sipos on 2019. 04. 09..
//  Copyright © 2019. Szpooky. All rights reserved.
//

import Foundation
import StoreKit

class ProductOperation : BasicOperation, SKProductsRequestDelegate {
    open var productIdentifiers: [String]?
    private var request: SKProductsRequest?
    open var products: [SKProduct]?
    open var invalidProductIdentifiers: [String]?
    
    override func main() {
        autoreleasepool {
            super.main()
            
            if let productIdentifiers = self.productIdentifiers, productIdentifiers.count > 0 {
                let request = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
                request.delegate = self
                self.request = request
                request.start()
                
                waitUntilFinished()
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        if let request = self.request { request.cancel() } else { finish() }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        invalidProductIdentifiers = response.invalidProductIdentifiers
        finish()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        self.error = error
        finish()
    }
}
