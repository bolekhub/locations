//
//  TrafficCamsViewController.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import CoreData

class TrafficCamsViewController: UITableViewController {
    
    var datamanager: DataManager?

    lazy var fetchController: NSFetchedResultsController<TrafficCameraItem>? = {
        let context = CoreDataDAO.shared.mainContext!
        let fetchRequest = NSFetchRequest<TrafficCameraItem>(entityName: "TrafficCameraItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller: NSFetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: context,
                                       sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Traffic Cams"
        do {
            try self.fetchController?.performFetch()
        }catch {
            print("An error ocurred \(error.localizedDescription)")
        }
        datamanager = DataManager(api: TrafficAPI.default, dao: CoreDataDAO.shared)
    }
    
    @IBAction func refreshDataAction(_ sender: UIBarButtonItem) {
        datamanager?.fetchCams(parameters: nil, completion: { (error) in
            print("ready")
        })
    }
    
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
}


extension TrafficCamsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
 
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let tableView = self.tableView
        
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.confi
        default:
            print("-")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
