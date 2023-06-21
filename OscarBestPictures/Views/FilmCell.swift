//
//  FilmCell.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 3/27/23.
//

import UIKit

class FilmCell: UITableViewCell {
    
    @IBOutlet weak var filmNameLabel: UILabel!
    @IBOutlet weak var filmGenreLabel: UILabel!
    @IBOutlet weak var filmPosterImg: UIImageView!
    
    var film: Film? {
        didSet {
            self.filmNameLabel.text = film?.name
            self.filmGenreLabel.text = film?.genre
            // Below line used to show film poster stored locally in assets folder
//            self.filmPosterImg.image = UIImage(named: film!.name)
            
            // Use dispatch queue to show film poster from url.
            DispatchQueue.global(qos: .userInitiated).async {
                let filmImageData = NSData(contentsOf: URL(string: self.film!.posterImgUrl)!)
                DispatchQueue.main.async {
                    self.filmPosterImg.image = UIImage(data: filmImageData! as Data)
                    
                    // Change the poster layout to a circle:
                    self.filmPosterImg.layer.cornerRadius = self.filmPosterImg.frame.width / 2
                }
            }
            
            // Below line associates with the click to add checkmark function implemented in FilmListViewController.
//            self.accessoryType = film!.confirmedWatched ? .checkmark : .none
            
            // Scroll Resilience: Also implement the accessoryView change on cell to avoid reusable cells issue (adding hearts to some other cells)
            let heart = UIImageView(frame: CGRect(x: 0, y: 65, width: 25, height: 25))
                heart.image = UIImage(systemName: "heart.fill")
                heart.tintColor = .systemPink

            self.accessoryView = film!.like ? heart :.none
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
