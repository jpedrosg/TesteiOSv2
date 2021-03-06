//
//  APICaller.swift
//  Accenture iOS Test
//
//  Created by João Pedro Giarrante on 26/07/20.
//  Copyright © 2020 João Pedro Giarrante. All rights reserved.
//

import Foundation

struct APICaller {
    
    
    func getAccountInfo(user: String, password: String, delegate: LoginViewController) {
        let parameters = ["user": user, "password": password]
        var request = URLRequest(url: URL(string: "https://bank-app-test.herokuapp.com/api/login")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if let error = error {
                    delegate.getAccountInfoError(error: nil)
                    print("APICaller - getAccountInfo:\n" + error.localizedDescription)
                    
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    
                    let userAccount = json["userAccount"] as? NSDictionary
                    let error = json["error"] as? NSDictionary
                    
                    if(error != nil && error!.count > 0){
                        DispatchQueue.main.async {
                            delegate.getAccountInfoError(error: error!)
                        }
                    }else if(userAccount != nil){
                        DispatchQueue.main.async {
                            delegate.getAccountInfoResponse(response: userAccount!)
                        }
                    }
                    
                }
            } catch {
                delegate.getAccountInfoError(error: nil)
            }
        })

        task.resume()
    }
    
    func getUserTransactions(user: NSNumber, delegate: MainViewController) {
        var request = URLRequest(url: URL(string: "https://bank-app-test.herokuapp.com/api/statements/" + user.stringValue)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if let error = error {
                  delegate.getUserTransactionsError(error: nil)
                  print("APICaller - getUserTransactions:\n" + error.localizedDescription)
                    
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    let statementList = json["statementList"] as? [NSDictionary]
                    let error = json["error"] as? NSDictionary
                    if(error != nil && error!.count > 0){
                        delegate.getUserTransactionsError(error: error)
                    }else if(statementList != nil){
                        DispatchQueue.main.async {
                            delegate.getUserTransactionsResponse(response: statementList!)
                        }
                    }
                }
            } catch {
                delegate.getUserTransactionsError(error: nil)
            }
        })

        task.resume()
    }
    
    
    
}
