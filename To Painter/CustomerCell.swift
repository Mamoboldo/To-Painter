//
//  CustomerCell.swift
//  To Painter
//
//  Created by Marco Boldetti on 23/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var customerImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customerImage.layer.cornerRadius = 20
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
