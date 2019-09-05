//
//  TrafficCamsViewController.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//
import UIKit
import CoreData

protocol TCameraSelectedDelegate: class {
    func trafficCamSelected(_ item: TrafficCameraItem)
}

class TrafficCamsViewController: UITableViewController {
    
    /// avoid that on startup in a horizontal compact size the split view controller collapse
    fileprivate var collapseDetailViewController = true
    
    /// coordinator between api and data access
    var datamanager: DataManager?
    
    /// send the selected object to detail vc
    weak var delegate: TCameraSelectedDelegate?
    
    /// filter table elements
    let searchController = UISearchController(searchResultsController: nil)
    
    /// keep in sync the model from coredata and the ui. On initial fetch of all dataset, a background thread handle all
    /// ssave operations, once all saved the change is merged to parent context wich notify FRC and update the UI
    lazy var fetchController: NSFetchedResultsController<TrafficCameraItem>? = {
        let context = CoreDataDAO.shared.mainContext!
        let fetchRequest = NSFetchRequest<TrafficCameraItem>(entityName: "TrafficCameraItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller: NSFetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: context,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    
    //MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Traffic Cams"
        datamanager = DataManager(api: TrafficAPI.default, dao: CoreDataDAO.shared)
        setupView()
        fetchControllerFetch()
    }
    
    //MARK: - UI Actions
    @IBAction func refreshDataAction(_ sender: UIBarButtonItem) {
        
        DOHUD.show()
        datamanager?.fetchCams( completion: { (error) in
            DOHUD.hide()
        })
    }
    
    
    //MARK: - UITableViewDataSource, UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let frc = self.fetchController {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = self.fetchController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitle_cell", for: indexPath)
        if let object = self.fetchController?.object(at: indexPath) {
            cell.textLabel?.text = object.title
            cell.detailTextLabel?.text = object.view
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let object = self.fetchController?.object(at: indexPath) {
            delegate?.trafficCamSelected(object)
        }

        if let detailvc = self.delegate as? MapViewController, let detailNavigationController = detailvc.navigationController  {
            self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }

        collapseDetailViewController = true
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

 
    
}


// MARK: - Private instance methods
private extension TrafficCamsViewController {
    
     func filterContentforText(_ search: String, scope: String = "A") {
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", scope, search)
        fetchController?.fetchRequest.predicate = predicate
        fetchControllerFetch()
        tableView.reloadData()
    }
    
     func fetchControllerFetch() {
        do {
            try self.fetchController?.performFetch()
        }catch {
            print("An error ocurred \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func setupView() {
        //self.splitViewController?.maximumPrimaryColumnWidth = UIScreen.main.bounds.width/2
        //self.splitViewController?.minimumPrimaryColumnWidth = UIScreen.main.bounds.width/2
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter"
        searchController.searchBar.scopeButtonTitles = ["Title", "Region"]
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

    // -- > if you are reading data from a background thread—it may be computationally expensive to animate all the changes.
    // Rather than responding to changes individually , you could just implement controllerDidChangeContent(_:)
    // (which is sent to the delegate when all pending changes have been processed) to reload the table view.
extension TrafficCamsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
}


//MARK: - UISearchResultsUpdating
extension TrafficCamsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty   else {
            fetchController?.fetchRequest.predicate = nil
            fetchControllerFetch()
            return
        }
        
        let scope = searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex]
        filterContentforText(text, scope: scope!.lowercased())
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchController?.fetchRequest.predicate = nil
        fetchControllerFetch()
    }
    
}
