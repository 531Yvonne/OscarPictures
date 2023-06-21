//
//  DetailViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 4/9/23.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var largePosterImg: UIImageView!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    
    // Buttons in Detail View
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var addToWatchButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var film: Film!
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporarily print selected film's property to the debugging panel for debugging purpose:
        print(film!)

        // Do any additional setup after loading the view.
        
        // Use dispatch queue to show large poster from url in the DetailView window.
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: URL(string: self.film!.largePosterImgUrl)!)
            DispatchQueue.main.async {
                if imageData != nil {
                    self.largePosterImg.image = UIImage(data: imageData! as Data)
                }
            }
        }
        
        // Show data for each labels
        self.imdbRatingLabel.text = "\(film.imdbRating)"
        self.directorLabel.text = film.director
        self.countryLabel.text = film.country
        self.yearLabel.text = "\(film.year)"
        self.plotLabel.text = film.plot
        self.titleLabel.text = film.name

        
        // Implement Button for WebView. (Referred to WKWebView Tutorial by iOS Academy)
        view.addSubview(learnMoreButton)
        learnMoreButton.addTarget(self, action: #selector(didTapLearnMoreButton), for: .touchUpInside)
       
        watchedButton.setTitle("Watched", for: .selected)
        watchedButton.setTitle("Mark as Watched", for: .normal)
        watchedButton.isSelected = film.confirmedWatched
        let unselectedColor = UIColor.systemTeal
        let selectedColor = UIColor.systemGray
        watchedButton.tintColor = watchedButton.isSelected ? selectedColor : unselectedColor
        watchedButton.addTarget(self, action: #selector(didTapWatchedButton), for: .touchUpInside)
        
        
        addToWatchButton.setTitle("Added", for: .selected)
        addToWatchButton.setTitle("Add to Watch", for: .normal)
        addToWatchButton.isSelected = film.addedToWatch
        addToWatchButton.tintColor = addToWatchButton.isSelected ? selectedColor : unselectedColor
        addToWatchButton.addTarget(self, action: #selector(didTapToWatchButton), for: .touchUpInside)
    }
    
    @objc private func didTapLearnMoreButton() {
        guard let url = URL(string: film.imdbUrl) else {
            return
        }
        let vc = WebViewController(url: url, title: "IMDb")
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc private func didTapWatchedButton() {
        film.confirmedWatched = !film.confirmedWatched
        watchedButton.isSelected = film.confirmedWatched
        watchedButton.tintColor = watchedButton.isSelected ? UIColor.systemGray : UIColor.systemTeal
        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", film.id)
        do {
            let fetchedFilms = try managedContext.fetch(fetchRequest)
            if let localFilm = fetchedFilms.first {
                localFilm.confirmedWatched = film.confirmedWatched
                // Save the changes
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch or update LocalFilm: \(error)")
        }
        
    }
    
    @objc private func didTapToWatchButton() {
        film.addedToWatch = !film.addedToWatch
        addToWatchButton.isSelected = film.addedToWatch
        addToWatchButton.tintColor = addToWatchButton.isSelected ? UIColor.systemGray : UIColor.systemTeal
        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", film.id)
        do {
            let fetchedFilms = try managedContext.fetch(fetchRequest)
            if let localFilm = fetchedFilms.first {
                localFilm.confirmedToWatch = film.addedToWatch
                // Save the changes
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch or update LocalFilm: \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
