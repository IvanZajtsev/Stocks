//
//  InfoViewController.swift
//  Stocks
//
//  Created by Иван Зайцев on 10.02.2022.
//

import UIKit
class InfoViewController: UIViewController {
    
    var data: [String: Any] = [:]
    var newsData: [[String: Any]] = []
    
    @IBAction func numberButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToNumbers", sender: self)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var activityIndView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestNdownloadLogo()
        requestNewsData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "ReusableNewsCell")
        tableView.dataSource = self
        self.tableView.delegate = self
        tableView.reloadData()
        
    }
    func requestNewsData() {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(data["symbol"]!)/news?&token=pk_a435f29a0d6a49d59372559b109c3dde")!
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("‼️Network Error")
                return
            }
            self.parseNewsData(data: data)
        }
        dataTask.resume()
    }
    
    private func parseNewsData(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [[String: Any]]
            else {
                print("error")
                return
            }
          
            for i in 0..<json.count {
                guard
                    let source = json[i]["source"] as? String,
                    let headline = json[i]["headline"] as? String,
                    let summary = json[i]["summary"] as? String,
                    let siteURL = json[i]["url"] as? String
                else {
                    print("‼️Invalid JSON format")
                    return
                }
                self.newsData.append(["source": source, "headline": headline, "summary": summary, "url": siteURL])
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.symbolLabel.text = self.data["symbol"] as? String ?? "--"
                self.companyNameLabel.text = self.data["companyName"] as? String ?? "--"
            }
            
        } catch {
            print("‼️JSON parsing error: " + error.localizedDescription)
        }
    }
    private func requestNdownloadLogo() {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(data["symbol"]!)/logo?&token=pk_a435f29a0d6a49d59372559b109c3dde")!
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("‼️Network Error")
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [String: Any],
                    let picUrl = json["url"] as? String
                else {
                    print("‼️Invalid JSON format")
                    return
                }
                self.data["url"] = picUrl
                let url2 = URL(string: picUrl)!
                
                let dataTask2 = URLSession.shared.dataTask(with: url2) { (data, response, error) in
                    guard
                        error == nil,
                        (response as? HTTPURLResponse)?.statusCode == 200,
                        let data = data
                    else {
                        print("‼️Network Error")
                        return
                    }
                    self.data["url"] = picUrl
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }.resume()
            } catch {
                print("‼️JSON parsing error: " + error.localizedDescription)
            }
        }.resume()
    }
    
}

// MARK: - UITableViewDataSource

extension InfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableNewsCell", for: indexPath) as? NewsCell
        else {
            print ("error")
            return UITableViewCell()
        }
        
        cell.textView.text = newsData[indexPath.row]["headline"] as? String ?? "--"
        cell.summaryLabel.text = newsData[indexPath.row]["summary"] as? String ?? "--"
        cell.sourceLabel.text = newsData[indexPath.row]["source"] as? String ?? "--"
        
        return cell
    }
}
    // MARK: - UITableViewDelegate

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let urlToOpen = URL(string: newsData[indexPath.row]["url"] as? String ?? "") else {
            return
        }
        if UIApplication.shared.canOpenURL(urlToOpen) {
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNumbers" {
            let destinationVC = segue.destination as! NumbersViewController
            destinationVC.symbol = self.data["symbol"] as? String ?? "--"
        }
        
    }
}
