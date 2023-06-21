//
//  ReviewViewViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/15/23.
//

import UIKit
import CoreData

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var largePosterImg: UIImageView!
    @IBOutlet weak var myRatingSlider: UISlider!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var ratingValue: UILabel!
    
    var film: Film!
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rating and Comment functionality only available when user tap the Edit button.
        myRatingSlider.isEnabled = false
        commentBox.isEditable = false
        ratingValue.text = String(format: "%.1f", film.myRating)
        commentBox.text = film.myComment
        myRatingSlider.value = Float(film.myRating)
        
        // Use dispatch queue to show large poster from url in the DetailView window.
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: URL(string: self.film!.largePosterImgUrl)!)
            DispatchQueue.main.async {
                if imageData != nil {
                    self.largePosterImg.image = UIImage(data: imageData! as Data)
                }
            }
        }
        
        actionButton.setTitle("Save", for: .selected)
        actionButton.setTitle("Edit", for: .normal)
        actionButton.isSelected = false
        let unselectedColor = UIColor.systemBlue
        let selectedColor = UIColor.systemPink
        actionButton.tintColor = actionButton.isSelected ? selectedColor : unselectedColor
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    @objc private func didTapActionButton() {
        actionButton.isSelected = !actionButton.isSelected
        
        // Activate commentbox and slider
        myRatingSlider.isEnabled = actionButton.isSelected
        commentBox.isEditable = actionButton.isSelected
        
        actionButton.tintColor = actionButton.isSelected ? UIColor.systemPink : UIColor.systemBlue
        
        if !actionButton.isSelected {
            saveUserReview()
        }
    }
    
    @IBAction func ratingSliderValueChanged(_ sender: UISlider) {
        // Update the label with the real-time slider value
        let rating = Double(sender.value)
        ratingValue.text = String(format: "%.1f", rating)
    }
    
    func saveUserReview() {
        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", film.id)
        do {
            let fetchedFilms = try managedContext.fetch(fetchRequest)
            if let localFilm = fetchedFilms.first {
                localFilm.myRating = Double(myRatingSlider.value)
                localFilm.myComment = commentBox.text
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch or update LocalFilm: \(error)")
        }
    }
}
