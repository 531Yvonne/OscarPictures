//
//  ViewController.swift
//  OscarBestPictures
//
//  Created by Yves Yang on 3/27/23.
//

import UIKit
import CoreData

class FilmListViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var discoverTableView: UITableView!
    
    var films: [Film] = []
    // when [String]! Forced sign's added, need to assure fileNames is always an array of strings, otherwise the App will crash.
    var filmService: FilmService!
    
    // Add a spinner for the load Film into FilmListView process
    // activate and stop spinner implemented in func viewWillAppear below.
    var spinner = UIActivityIndicatorView(style: .medium)
    
    // Add Search Bar
    let searchController = UISearchController()
    var filteredFilms: [Film] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.filmService = FilmService()
        initSearchController()
    
        let randomButton = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(showRandomFilm))
        randomButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold), // Change the font size and weight as needed
            NSAttributedString.Key.foregroundColor: UIColor.systemBrown // Change the color as needed
        ], for: .normal)
        navigationItem.rightBarButtonItem = randomButton
        
        // Below 2 lines enable the table to show up
        self.discoverTableView.dataSource = self
        self.discoverTableView.delegate = self
    }
    
    // Implement this new func to separate ines from func viewDidLoad so that FilmListViewControllerTests can replace by mockFilmService()
    override func viewWillAppear(_ animated: Bool) {
        
        extractFromCoreData()
        if self.films.isEmpty {
            // Extract data using API
            
            // Launch the spinner before fetching films into ListView.
            self.spinner.translatesAutoresizingMaskIntoConstraints = false
            self.spinner.startAnimating()
            self.view.addSubview(spinner)
            self.spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            self.spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            guard let confirmedService = self.filmService else { return }
            confirmedService.getFilms(completion: { films, error in
                guard let films = films, error == nil else {
                    // When API won't work, an Alert will display.
                    self.displayAPIFailureAlert()
                    return
                }
                // When list view load successfully, stop the spinner.
                // If disable line below, the spinner will stuck at the view after loading the films.
                self.spinner.stopAnimating()
                self.films = films
                
                // When API works but returns an empty list, an message showing the list is empty will display.
                // An empty list API link is provided in FilmService.swift for testing purpose.
                if self.films.isEmpty {
                    self.displayListIsEmpty()
                }
                
                self.saveToCoreData()
                self.extractFromCoreData()
                self.discoverTableView.reloadData()
            })
        } else {
            print("Restore from Core Data")
            self.discoverTableView.reloadData()
        }
    }
    
    // Transfer Film data (extracted from API) to Core Data LocalData entity
    func saveToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for film in self.films {
            // Convert the Film object to a FilmEntity object and save it to Core Data
            _ = film.toManagedObject(context: managedContext)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        print("Films saved to Core Data")
    }
    
    func extractFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get reference to app delegate")
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<LocalFilm> = LocalFilm.fetchRequest()

        do {
            let fetchedFilms = try managedContext.fetch(fetchRequest)
            self.films = fetchedFilms.map { $0.toFilm() }
        } catch let error as NSError {
            // Handle the error appropriately
            print("Error fetching films: \(error), \(error.userInfo)")
        }
    }
    
    // Add Below Block to Display a Label showing the List is Empty.
    func displayListIsEmpty() {
        let displayLabel = UILabel()
        displayLabel.text = "Oops, the API is working, but looks like the fetched list is EMPTY! 🤔"
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
    
    
    // Add Below Block to Display an Alert when encounter API Failure (Unable to fetch film data)
    func displayAPIFailureAlert() {
        let alertController = UIAlertController(title: "Connection Error", message: "Unable to Fetch Data From API", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.viewWillAppear(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Enable the moves from one controler to another detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailViewController else {
                return
        }

        if let selectedIndexPath = discoverTableView.indexPathForSelectedRow {
            let selectedFilm = (searchController.isActive) ? filteredFilms[selectedIndexPath.row] : films[selectedIndexPath.row]
            destination.film = selectedFilm
        }
        
        // Below code shows after refactoring version using "guard" to avoid the nested clauses.
//        guard let destination = segue.destination as? DetailViewController else {return}
//        guard let selectedIndexPath = self.discoverTableView.indexPathForSelectedRow else {return}
//        guard let confirmedCell = self.discoverTableView.cellForRow(at: selectedIndexPath) as? FilmCell else {return}
//        let confirmedFilm = confirmedCell.film
//        destination.film = confirmedFilm
        
        // Below code shows before refactoring version using multiple conditional statement.
//        if let destination = segue.destination as? DetailViewController {
//            if let selectedIndexPath = self.discoverTableView.indexPathForSelectedRow {
//                if let confirmedCell = self.discoverTableView.cellForRow(at: selectedIndexPath) as? FilmCell {
//                    let confirmedFilm = confirmedCell.film
//                    destination.film = confirmedFilm
//                }
//            }
//        }
    }
    
    @objc func showRandomFilm() {
            // Handle the button tap here
            if let randomFilm = films.randomElement() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailViewController = storyboard.instantiateViewController(withIdentifier: "detailview") as! DetailViewController
                detailViewController.film = randomFilm
                navigationController?.pushViewController(detailViewController, animated: true)
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
            discoverTableView.backgroundView = noResultsLabel
        } else {
            discoverTableView.backgroundView = nil
        }
        discoverTableView.reloadData()
    }
}

// Use extension separately to add functions to a certain class instead of mixing in the ViewController Class above
extension FilmListViewController: UITableViewDataSource {
    //MARK: Data Source
    //Uppercase mark use to show clear section title at right side minimap.
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive) {
            return filteredFilms.count
        } else {
            return self.films.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.discoverTableView.dequeueReusableCell(withIdentifier: "filmCell") as! FilmCell
        // "as! className" means down cast to FilmCell class (which is a subclass of the required return value: UITableViewCell). Need to assure the subclass is always a subclass of UITableViewCell class otherwise App will crash.
        
        // "as? className" means optional down cast. When can't return UITableViewCell, will return nil.
        
        let currentFilm: Film
        
        if (searchController.isActive) {
            currentFilm = filteredFilms[indexPath.row]
        } else {
            currentFilm = films[indexPath.row]
        }
        
        cell.film = currentFilm
        
        // Set the accessory view based on the "like" attribute
        let heart = UIImageView(frame: CGRect(x: 0, y: 65, width: 25, height: 25))
            heart.image = UIImage(systemName: "heart.fill")
            heart.tintColor = .systemPink
        
        cell.accessoryView = currentFilm.like ? heart : .none
            
        return cell
        }
}

extension FilmListViewController: UITableViewDelegate {
    //MARK: Delegate

// Below func adds a checkmark when click on a certain cell.
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if
//            // Use if statement to avoid the scenario where cellForRow() returns nil
//            let cell = self.discoverTableView.cellForRow(at: indexPath) as? FilmCell,
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
            let cell = self.discoverTableView.cellForRow(at: indexPath) as? FilmCell,
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
            let cell = self.discoverTableView.cellForRow(at: indexPath) as? FilmCell,
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
