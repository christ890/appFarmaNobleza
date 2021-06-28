//
//  CellTableViewCell.swift
//  appFarmaNobleza
//
//  Created by DARK NOISE on 27/06/21.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imagenp: UIImageView!
    @IBOutlet weak var nombreP: UILabel!
    @IBOutlet weak var descP: UILabel!
    @IBOutlet weak var precioP: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
