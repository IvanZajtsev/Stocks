//
//  ViewController.swift
//  Stocks
//
//  Created by Иван Зайцев on 07.02.2022.
//

import UIKit
import Network
class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var activityIndView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let listTypes = ["gainers", "mostactive", "losers"]
    let listRuTypes = ["Победители", "Активные", "Проигравшие"]
    var pickerView = UIPickerView()
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    var groupNumber = -1
    
    override func viewWillAppear(_ animated: Bool) {
//        print("viewdidappear")
        dateLabel.text = formatdate("ddMMMM")
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
//        print("viewdidload")
        monitorNetwork()
        self.view.bringSubviewToFront(activityIndView)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        navigationController?.navigationBar.tintColor = .white
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        groupTextField.inputView = pickerView
        dateLabel.text = formatdate("ddMMMM")
        
        tableView.refreshControl = myRefreshControl
        tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.dataSource = self
        tableView.delegate = self
        DispatchQueue.main.async {
            self.requestQuote(url: "https://cloud.iexapis.com/stable/stock/market/list/gainers?&token=pk_a435f29a0d6a49d59372559b109c3dde")
        }
    }
    
    // MARK: - private properties
    
    var pickedStock = 0
    let defaults = UserDefaults.standard
    let exampleDict = ["companyName" : "Apple Inc." , "symbol" : "AAPL" , "price" : 344567.6 , "change" :0.43 ] as [String : Any]
    var data: [[String: Any]] = []
    
    // MARK: -  methods
   
    
    private func requestQuote(url: String) {
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
            self.data.removeAll()
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [[String: Any]]
            else {
                print("ошибка")
                return
            }
            for i in 0..<json.count {
                
                let companyName = json[i]["companyName"] as? String ?? ""
                let companySymbol = json[i]["symbol"] as? String ?? ""
                let price = json[i]["latestPrice"] as? Double
                let priceChange = json[i]["change"] as? Double
                
                // тут разбиралась ошибка JSON Parcing error
                
                self.data.append(["companyName": companyName , "symbol": companySymbol , "price": price, "change" : priceChange])
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.view.bringSubviewToFront(self.tableView)
            }
            print("Success!")
        } catch {
            print("‼️JSON parsing error: " + error.localizedDescription)
        }
    }

    func formatdate(_ template: String) -> String {
        let aDate = NSDate()
        let ru_GB = Locale(identifier: "ru_GB")
        var df = DateFormatter()
        let custom = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: ru_GB)
        df.dateFormat = custom
        return df.string(from: aDate as Date)
    }
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.sync {
                    self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                    self.navigationController?.navigationBar.barTintColor = .black
                    self.navigationController?.navigationBar.shadowImage = UIImage()
//                    print("ok")
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                    self.navigationController?.navigationBar.barTintColor = .red
                    self.navigationController?.navigationBar.shadowImage = UIImage()
                    self.activityIndicator.stopAnimating()
                    self.view.bringSubviewToFront(self.tableView)
                    self.showConnectionAlert()
//                    print("disconnect")
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func showConnectionAlert() {
        let alert = UIAlertController(title: "Передача данных выключена", message: "Для доступа к данным включите передачу данных по сотовой сети или используйте WI-FI. Затем перейдите на первый экран и потяните для обновления или выберите другую группу акций.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in
        }))
        present(alert, animated:  true)
    }
    
    
    @objc func refresh(sender: UIRefreshControl) {
        self.requestQuote(url: "https://cloud.iexapis.com/stable/stock/market/list/\((groupNumber == -1) ? "gainers" : listTypes[groupNumber])?&token=pk_a435f29a0d6a49d59372559b109c3dde")
        sender.endRefreshing()
    }
    

    
}
// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickedStock = indexPath.row
        self.performSegue(withIdentifier: "goToInfo", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInfo" {
            let destinationVC = segue.destination as! InfoViewController
            destinationVC.data  = data[pickedStock]
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? Cell
        else { return UITableViewCell() }
        
        cell.fullNameLabel.text = data[indexPath.row]["companyName"] as? String ?? "--"
        cell.symbolLabel.text = data[indexPath.row]["symbol"] as? String ?? "--"
        cell.priceLabel.text = ((data[indexPath.row]["price"] as? Double) != nil) ? (NSString(format: "%.2f", (data[indexPath.row]["price"] as! Double)) as String)  : "--"
        
        cell.priceChangeLabel.text = ((data[indexPath.row]["change"] as? Double) != nil) ? "\(data[indexPath.row]["change"] as! Double)" : "--"
        if ((data[indexPath.row]["change"] as? Double) == nil) {
            cell.priceChangeView.backgroundColor = .darkGray
        }
        
        if ((data[indexPath.row]["change"] as? Double) != nil && (data[indexPath.row]["change"] as? Double)! > 0) {
            cell.priceChangeLabel.text = "+" + (NSString(format: "%.2f", (data[indexPath.row]["change"] as! Double)) as String)
            cell.priceChangeView.backgroundColor = UIColor(red: 20/255, green: 230/255, blue: 156/255, alpha: 1)
        } else if ((data[indexPath.row]["change"] as? Double) != nil && (data[indexPath.row]["change"] as? Double)! < 0) {
            cell.priceChangeLabel.text = (NSString(format: "%.2f", (data[indexPath.row]["change"] as! Double)) as String)
            cell.priceChangeView.backgroundColor = .red
        } else if ((data[indexPath.row]["change"] as? Double) != nil && (data[indexPath.row]["change"] as? Double)! == 0) {
            cell.priceChangeLabel.text = "0.00"
            cell.priceChangeView.backgroundColor = .darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        listTypes.count
    }


}
// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listRuTypes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupTextField.text = listRuTypes[row]
        self.groupNumber = row
        groupTextField.resignFirstResponder()
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndView)
        requestQuote(url: "https://cloud.iexapis.com/stable/stock/market/list/\(listTypes[row])?&token=pk_a435f29a0d6a49d59372559b109c3dde")
    }
}
