//
//  MyRecordViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/11/23.
//

import UIKit
import CoreData

class MyRecordViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate{

    @IBOutlet weak var myRecordTableView: UITableView!
    
    @IBOutlet weak var watchedNumberLabel: UILabel!
    @IBOutlet weak var toWatchNumberLabel: UILabel!
    @IBOutlet weak var likedNumberLabel: UILabel!
    
    var films: [Film] = []
    // when [String]! Forced sign's added, need to assure fileNames is always an array of strings, otherwise the App will crash.
    var allFilms: [Film] = []
    
    // Add Search Bar
    let searchController = UISearchController()
    var filteredFilms: [Film] = []
    
    let noRecordLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show Number of Records for each category
        initSearchController()
        
        self.myRecordTableView.allowsSelection = true
        // Below 2 lines enable the table to show up
        self.myRecordTableView.dataSource = self
        self.myRecordTableView.delegate = self
    }
    
    // Implement this new func to separate ines from func viewDidLoad so that FilmListViewControllerTests can replace by mockFilmService()
    override func viewWillAppear(_ animated: Bool) {
        // Get a reference to the persistent container
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        // Create a fetch request for the LocalFilm entity
        let fetchRequest = NSFetchRequest<LocalFilm>(entityName: "LocalFilm")
        
        // Execute the fetch request and get the results
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            // Convert the LocalFilm objects to Film objects
            self.allFilms = fetchResults.map { $0.toFilm() }
            updateCount()
            self.films = self.allFilms.filter { $0.confirmedWatched }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // When to watch is an empty list, an message showing the list is empty will display.
        if self.films.isEmpty {
            self.displayListIsEmpty()
        } else {
            noRecordLabel.isHidden = true
        }
        self.myRecordTableView.reloadData()
    }
    
    func updateCount() {
        watchedNumberLabel.text = "\(self.allFilms.filter { $0.confirmedWatched }.count)"
        toWatchNumberLabel.text = "\(self.allFilms.filter { $0.addedToWatch }.count)"
        likedNumberLabel.text = "\(self.allFilms.filter { $0.like }.count)"
    }
    
    // Add Below Block to Display a Label showing the List is Empty.
    func displayListIsEmpty() {
        noRecordLabel.text = "No Record!\nStart watching today!"
        noRecordLabel.numberOfLines = 0 // set to multiline
        noRecordLabel.font = UIFont.systemFont(ofSize: 25)
        noRecordLabel.textAlignment = .center
        noRecordLabel.textColor = .black
        view.addSubview(noRecordLabel)
        noRecordLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noRecordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noRecordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noRecordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            noRecordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)])
    }
    
    // Enable the moves from one controler to another detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ReviewViewController else {
            return
        }

        if let selectedIndexPath = myRecordTableView.indexPathForSelectedRow {
            let selectedFilm = (searchController.isActive) ? filteredFilms[selectedIndexPath.row] : films[selectedIndexPath.row]
            destination.film = selectedFilm
        }
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.scopeButtonTitles = ["Both", "Title", "Genre"]
        searchController.searchBar.placeholder = "Search Films"
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!

        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton)
    }
    
    // Function to conduct search for Titlename or Genre or Both.
    public func filterForSearchTextAndScopeButton(searchText: String, scopeButton: String = "Both") {
        filteredFilms = films.filter {
            film in
            var isScopeMatch = false
            switch scopeButton {
            case "Both":
                isScopeMatch = true
            case "Title":
                isScopeMatch = !film.name.isEmpty
            case "Genre":
                isScopeMatch = !film.genre.isEmpty
            default:
                isScopeMatch = false
            }
            if(searchController.searchBar.text != "") {
                let isNameMatch = film.name.lowercased().contains(searchText.lowercased())
                let isGenreMatch = film.genre.lowercased().contains(searchText.lowercased())
                switch scopeButton {
                case "Both":
                    return isScopeMatch && (isNameMatch || isGenreMatch)
                case "Title":
                    return isScopeMatch && isNameMatch
                case "Genre":
                    return isScopeMatch && isGenreMatch
                default:
                    return false
                }
            } else {
                return isScopeMatch
            }
        }
        // Add a label showing "No result" when the search can't find any match.
        if filteredFilms.isEmpty {
            let noResultsLabel = UILabel()
                noResultsLabel.text = "No Results Found"
                noResultsLabel.font = UIFont.systemFont(ofSize: 24)
                noResultsLabel.textAlignment = .center
            myRecordTableView.backgroundView = noResultsLabel
        } else {
            myRecordTableView.backgroundView = nil
        }
        myRecordTableView.reloadData()
    }
}

// Use extension separately to add functions to a certain class instead of mixing in the ViewController Class above
extension MyRecordViewController: UITableViewDataSource {
    //MARK: Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive) {
            return filteredFilms.count
        } else {
            return films.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myRecordTableView.dequeueReusableCell(withIdentifier: "filmCell") as! FilmCell
        // "as! className" means down cast to FilmCell class (which is a subclass of the required return value: UITableViewCell). Need to assure the subclass is always a subclass of UITableViewCell class otherwise App will crash.
        
        // "as? className" means optional down cast. When can't return UITableViewCell, will return nil.
        
        let currentFilm: Film
        
        if (searchController.isActive) {
            currentFilm = filteredFilms[indexPath.row]
        } else {
            currentFilm = films[indexPath.row]
        }
        
        cell.film = currentFilm
        
        return cell
        }
}

extension MyRecordViewController: UITableViewDelegate {
    //MARK: Delegate

// Below func adds a checkmark when click on a certain cell.
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if
//            // Use if statement to avoid the scenario where cellForRow() returns nil
//            let cell = self.toWatchTableView.cellForRow(at: indexPath) as? FilmCell,
//            let confirmedFilm = cell.film
//        {
//            confirmedFilm.confirmedWatched = true
//            cell.accessoryType = confirmedFilm.confirmedWatched ? .checkmark : .none
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MyRecordToReviewPage", sender: nil)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if
            let cell = self.myRecordTableView.cellForRow(at: indexPath) as? FilmCell,
            let confirmedFilm = cell.film
        {
            let like = confirmedFilm.like
            
            let title = like ?
            NSLocalizedString("Unlike", comment: "Unlike") :
            NSLocalizedString("Like", comment: "Like")
            
            let heart = UIImageView(frame: CGRect(x: 0, y: 65, width: 25, height: 25))
                heart.image = UIImage(systemName: "heart.fill")
                heart.tintColor = .systemPink
            
            let action = UIContextualAction(
                style: .normal,
                title: title,
                handler:
                    {
                        (action, view, completionHandler) in
                        // Update like status in data source
                        confirmedFilm.like = !confirmedFilm.like
                        
                        // Add heart to cell when swipe to "Like"
                        cell.accessoryView = confirmedFilm.like ? heart : .none
                        
                        // Save the changes
                        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", confirmedFilm.id)
                        do {
                            let fetchedFilms = try managedContext.fetch(fetchRequest)
                            if let localFilm = fetchedFilms.first {
                                localFilm.like = confirmedFilm.like
                                try managedContext.save()
                                print("like status saved")
                                self.updateCount()
                                completionHandler(true)
                            }
                        } catch {
                            print("Failed to save like status: \(error)")
                            completionHandler(false)
                        }
                    }
            )
            
            action.backgroundColor = like ? .gray : .systemPink

            return UISwipeActionsConfiguration(actions: [action])
        }
        return nil
    }
}
