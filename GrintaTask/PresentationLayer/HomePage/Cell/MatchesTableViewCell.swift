//
//  MatchesTableViewCell.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var homeTeamName: UILabel!
    @IBOutlet weak var awayTeamName: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(match : Match) {
        homeTeamName.text = match.homeTeam?.name
        awayTeamName.text = match.awayTeam?.name
        if match.status == "FINISHED" {
            timeLeft.text = "\(match.score?.fullTime?.homeTeam?.string ?? "") - \(match.score?.fullTime?.awayTeam?.string ?? "")"
        } else {
            
            timeLeft.text = match.utcDate?.convertDate()
        }
        
    }    
    
}



