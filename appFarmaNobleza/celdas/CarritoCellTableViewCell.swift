//
//  CarritoCellTableViewCell.swift
//  appFarmaNobleza
//
//  Created by DARK NOISE on 27/06/21.
//

import UIKit

class CarritoCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgCarro: UIImageView!
    @IBOutlet weak var nombreCar: UILabel!
    @IBOutlet weak var deletebutton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
