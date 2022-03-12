//
//  MovieListTableViewCell.swift
//  Movie Search
//
//  Created by Walid Hossain on 15/3/21.
//

import UIKit

class MovieListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverView: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
