//
//  Cell.swift
//  Stocks
//
//  Created by Иван Зайцев on 08.02.2022.
//

import UIKit

class Cell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceChangeView.layer.masksToBounds = true
        priceChangeView.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        // Configure the view for the selected state
    }
    
}
