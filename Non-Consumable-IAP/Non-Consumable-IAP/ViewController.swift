//
//  ViewController.swift
//  Non-Consumable-IAP
//
//  Created by Biznatch on 25/08/20.
//  Copyright © 2020 Silver Seahog. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // Buttons
    @IBOutlet weak var unlockProButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    // Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Product Request Instance
    var productsRequest = SKProductsRequest()
    
    // Fetched products array
    var validProducts = [SKProduct]()
    
    // Your product's index
    var productIndex = 0
    
    
    // viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show indicator initially
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        // Hide unlock button initially
        unlockProButton.isHidden = true

        // Fetch products on main thread
        DispatchQueue.main.async {
            self.fetchAvailableProducts()
        }
    }
    
    
    
    func fetchAvailableProducts()  {
        // Set your product's identifier
        let productIdentifiers = NSSet(objects:
            "com.iap.unlockproversion"  // 1
        )
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        // Set deleagte and start
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            // Get retrieved products
            validProducts = response.products
            
            // Here's your product at index 0
            let prodUnlockPro = response.products[0] as SKProduct
            print("1st product: " + prodUnlockPro.localizedDescription)
            
            // Now that you have product info, show unlock button and stop indicator
            DispatchQueue.main.async {
                self.unlockProButton.isHidden = false
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    // Tells the observer that a user initiated an in-app purchase from the App Store.
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    // Tells if a product can be purchased
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    // Initiate purchase process
    func purchaseMyProduct(_ product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Purchases are disabled in your device!")
            makeAlert(title: "Oops!", message: "Purchases are disabled in your device!", buttonTitle: "Okay")

            UserDefaults.standard.set(false, forKey: "isUserPro") // Retrive this is app code to unlock features
        }
    }
    
    // Update the user with purchase result
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if productIndex == 0 {
                        print("You've unlocked the Pro version!")
                        
                        DispatchQueue.main.async {
                            self.unlockProButton.isHidden = true
                            
                            self.activityIndicator.startAnimating()
                            self.activityIndicator.isHidden = true
                        }
                        
                        unlockProButton.setTitle("PRO version purchased", for: .normal)
                        UserDefaults.standard.set(true, forKey: "isUserPro")
                        
                        makeAlert(title: "Congratulations!", message: "You've unlocked the Pro version!", buttonTitle: "Okay")
                    }
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print("Payment has failed.")
                    UserDefaults.standard.set(false, forKey: "isUserPro")
                    makeAlert(title: "Oops!", message: "Payment has failed.", buttonTitle: "Okay")

                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print("Purchase has been successfully restored!")
                    UserDefaults.standard.set(true, forKey: "isUserPro")
                    makeAlert(title: "Congratulations!", message: "Purchase has been successfully restored!", buttonTitle: "Okay")

                    break
                    
                default: break
                }
            }
        }
    }    
    
    // Initiate restore
    func restorePurchase() {
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // Tells if restore succeeded 
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("The Payment was successfull!")
    }
    
    
    
    // Buy IAP button -------------------------------------
    @IBAction func unlockProButt(_ sender: UIButton) {
        productIndex = 0
        purchaseMyProduct(validProducts[productIndex])

        DispatchQueue.main.async {
            self.unlockProButton.isHidden = true
            
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
        
    }
    
    // Restore IAP button
    @IBAction func restorePurchaseButt(_ sender: UIButton) {
        
        restorePurchase()
        
        DispatchQueue.main.async {
            self.unlockProButton.isHidden = true
            
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
    }
    
    // Custom alert control function
    func makeAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle, style: .default) { (action:UIAlertAction) in
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
