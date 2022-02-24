//
//  NumbersViewController.swift
//  Stocks
//
//  Created by Иван Зайцев on 13.02.2022.
//

import UIKit

class NumbersViewController: UIViewController {
    
    var symbol = ""
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    @IBOutlet weak var openLabel: UILabel!
    
    @IBOutlet weak var highLabel: UILabel!
    
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var avgVolLabel: UILabel!
    var quoteData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestQuote(url: "https://cloud.iexapis.com/stable/stock/\(symbol)/batch?types=quote&token=pk_a435f29a0d6a49d59372559b109c3dde")
        
    }
    func requestQuote(url: String) {
       
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("‼️Network Error")
                return
            }
            self.parseQuote(data: data)
        }
        dataTask.resume()
    }
    
    
    private func parseQuote(data: Data) {
        do {
            self.quoteData.removeAll()
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let jsonQuote = json["quote"] as? [String: Any]
            else {
                return
            }
            let price = (jsonQuote)["latestPrice"] as? Double
            let priceChange = (jsonQuote)["change"] as? Double
            let open = (jsonQuote)["open"] as? Double
            let high = (jsonQuote)["high"] as? Double
            let low = (jsonQuote)["low"] as? Double
            let vol = (jsonQuote)["volume"] as? Double
            let avgVol = (jsonQuote)["avgTotalVolume"] as? Double
            
            // тут разбиралась ошибка JSON Parcing error
            
            self.quoteData["price"] = price
            self.quoteData["change"] = priceChange
            self.quoteData["open"] = open
            self.quoteData["high"] = high
            self.quoteData["low"] = low
            self.quoteData["volume"] = vol
            self.quoteData["avgTotalVolume"] = avgVol
            
            DispatchQueue.main.async {
                self.priceLabel.text = (price == nil) ? "--" : "\(price!)"
                self.priceChangeLabel.text = (priceChange == nil) ? "--" : "\(priceChange!)"
                self.openLabel.text = (open == nil) ? "--" : "\(open!)"
                self.highLabel.text = (high == nil) ? "--" : "\(high!)"
                self.lowLabel.text = (low == nil) ? "--" : "\(low!)"
                self.volumeLabel.text = (vol == nil) ? "--" : "\(vol!)"
                self.avgVolLabel.text = (avgVol == nil) ? "--" : "\(avgVol!)"
            }
            print("Success!")
        } catch {
            print("‼️JSON parsing error: " + error.localizedDescription)
        }
    }




}
