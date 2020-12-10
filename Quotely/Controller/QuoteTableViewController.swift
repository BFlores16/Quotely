//
//  QuoteTableViewController.swift
//  Quotely
//
//  Created by Brando Flores on 12/9/20.
//  product ID: com.BrandoFlores.Quotely.PremiumQuotes

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
        
    let productID = "com.BrandoFlores.Quotely.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        // Add our QuoteTableViewController as the delegate for SKPaymenTransactionObserver
        SKPaymentQueue.default().add(self)
        
        if isPurchased() {
            showPremiumQuotes()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased() {
            return quotesToShow.count
        }
        else {
            // +1 is the get more quotes cell
            
            return quotesToShow.count + 1
        }
    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.isUserInteractionEnabled = false
            cell.textLabel?.numberOfLines = 0
            
            // Explicitly set cells that are to be normal cells, otherwise,
            // the reusable cells will be loaded into the table view and look strange
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
        }
        else {
            cell.isUserInteractionEnabled = true
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.03405794129, green: 0.576638639, blue: 0.6086307168, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }

        return cell
     }
    
    //MARK: - Table view delegate functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - In-App purchase functions
    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            // In-App purchase request
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
        else {
            print("User unable to make purchases")
        }
    }
    
    // Delegate function listening for user payment
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // User payment successful
                print("Payment successful")
                
                showPremiumQuotes()
                
                // terminate the transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if transaction.transactionState == .failed{
                // Payment failed
                print("Payment failed")
                
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Transaction failed due to error: \(errorDescription)")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if transaction.transactionState == .restored {
                // Restore successful
                showPremiumQuotes()
                print("Transaction Restored")
                
                // Hide restore button if restore successful
                navigationItem.setRightBarButton(nil, animated: true)
                
                // terminate the transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func showPremiumQuotes() {
        // Set value that user has already purchased the product
        UserDefaults.standard.set(true, forKey: productID)
        
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }
    
    // Check if user has purchased premium quotes
    func isPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: productID)
    }
    
    @IBAction func restoreButtonPressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
}
