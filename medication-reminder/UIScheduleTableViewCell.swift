//
//  UIScheduleTableViewCell.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/02.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit

class UIScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    public func setupCell(with model: ScheduleModel){
        
        titleLabel.text = model.getName()
        detailLabel.text = model.getHourAndMinute()
        subtitleLabel.text = model.getDosage()
        
    }

}
