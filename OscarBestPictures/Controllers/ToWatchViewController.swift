//
//  ToWatchViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 5/11/23.
//

import UIKit
import CoreData

class ToWatchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var toWatchTableView: UITableView!
    
    var films: [Film] = []
    // when [String]! Forced sign's added, need to assure fileNames is always an array of strings, otherwise the App will crash.
    
    // Add Search Bar
    let searchController = UISearchController()
    var filteredFilms: [Film] = []
    
    let displayLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        initSearchController()
        self.toWatchTableView.allowsSelection = true
        // Below 2 lines enable the table to show up
        self.toWatchTableView.dataSource = self
        self.toWatchTableView.delegate = self
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
        fetchRequest.predicate = NSPredicate(format: "confirmedToWatch == true")
        
        // Execute the fetch request and get the results
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            // Convert the LocalFilm objects to Film objects
            self.films = fetchResults.map { $0.toFilm() }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            
        // When to watch is an empty list, an message showing the list is empty will display.
        if self.films.isEmpty {
            self.displayListIsEmpty()
        } else {
            displayLabel.isHidden = true
        }
        self.toWatchTableView.reloadData()
    }
    
    // Add Below Block to Display a Label showing the List is Empty.
    func displayListIsEmpty() {
        displayLabel.text = "Your To-Watch List is EMPTY! 🤔"
        displayLabel.numberOfLines = 0 // set to multiline
        displayLabel.font = UIFont.systemFont(ofSize: 25)
        displayLabel.textAlignment = .center
        displayLabel.textColor = .black
        view.addSubview(displayLabel)
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                displayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                displayLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                displayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                displayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)])
    }
    
    // Enable the moves from one controler to another detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailViewController else {
                return
        }

        if let selectedIndexPath = toWatchTableView.indexPathForSelectedRow {
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
            toWatchTableView.backgroundView = noResultsLabel
        } else {
            toWatchTableView.backgroundView = nil
        }
        toWatchTableView.reloadData()
    }
}

// Use extension separately to add functions to a certain class instead of mixing in the ViewController Class above
extension ToWatchViewController: UITableViewDataSource {
    //MARK: Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive) {
            return filteredFilms.count
        } else {
            return films.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.toWatchTableView.dequeueReusableCell(withIdentifier: "filmCell") as! FilmCell
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

extension ToWatchViewController: UITableViewDelegate {
    //MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToWatchToDetail", sender: nil)
    }

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
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if
            let cell = self.toWatchTableView.cellForRow(at: indexPath) as? FilmCell,
            let confirmedFilm = cell.film
        {
            let watched = confirmedFilm.confirmedWatched
            let toWatch = confirmedFilm.addedToWatch
            
            let title1 = watched ?
            NSLocalizedString("Unwatched", comment: "Unwatched") :
            NSLocalizedString("Watched", comment: "Watched")
            
            let title2 = toWatch ?
            NSLocalizedString("Remove from to-watch", comment: "Remove from to-watch") :
            NSLocalizedString("Add to watch", comment: "Add to watch")

            let action1 = UIContextualAction(
                style: .normal,
                title: title1,
                handler:
                    {
                        (action, view, completionHandler) in
                        // Update watch status in data source
                        confirmedFilm.confirmedWatched = !confirmedFilm.confirmedWatched
                        
                        // Save the changes
                        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", confirmedFilm.id)
                        do {
                            let fetchedFilms = try managedContext.fetch(fetchRequest)
                            if let localFilm = fetchedFilms.first {
                                localFilm.confirmedWatched = confirmedFilm.confirmedWatched
                                try managedContext.save()
                                print("Watch status saved")
                                completionHandler(true)
                            }
                        } catch {
                            print("Failed to save watch status: \(error)")
                            completionHandler(false)
                        }
                    }
            )
            
            let action2 = UIContextualAction(
                style: .normal,
                title: title2,
                handler:
                    {
                        (action, view, completionHandler) in
                        // Update to-watch status in data source
                        confirmedFilm.addedToWatch = !confirmedFilm.addedToWatch
                        
                        // Save the changes
                        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", confirmedFilm.id)
                        do {
                            let fetchedFilms = try managedContext.fetch(fetchRequest)
                            if let localFilm = fetchedFilms.first {
                                localFilm.confirmedToWatch = confirmedFilm.addedToWatch
                                try managedContext.save()
                                print("To-watch status saved")
                                // Remove the record if swiped to remove from to-watch list
                                self.films.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                                completionHandler(true)
                            }
                        } catch {
                            print("Failed to save to-watch status: \(error)")
                            completionHandler(false)
                        }
                    }
            )
            
            action1.backgroundColor = watched ? .gray : .systemBlue
            action2.backgroundColor = toWatch ? .gray : .systemTeal

            return UISwipeActionsConfiguration(actions: [action1, action2])
        }
        return nil
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if
            let cell = self.toWatchTableView.cellForRow(at: indexPath) as? FilmCell,
            let confirmedFilm = cell.film
        {
            // Implemented with the help of Session 2 note link: https://useyourloaf.com/blog/table-swipe-actions/
            
            // Get current like or not status from data source: Film
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
