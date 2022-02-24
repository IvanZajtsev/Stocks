//
//  NewsCell.swift
//  Stocks
//
//  Created by Иван Зайцев on 11.02.2022.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.bringSubviewToFront(contentView)
        textView.superview?.bringSubviewToFront(textView)
        contentView.isUserInteractionEnabled = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
