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
    
    var datamanager: DataManager?
    var delegate: TCameraSelectedDelegate?
    
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
        DOHUD.show()
        datamanager?.fetchCams(parameters: nil, completion: { (error) in
            DOHUD.hide()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = self.fetchController?.object(at: indexPath) {
            self.delegate?.trafficCamSelected(object)

        }
        tableView.deselectRow(at: indexPath, animated: true)
        if let mastervc = self.navigationController?.parent as? MasterViewController, let detailvc = self.delegate as? MapViewController {
            mastervc.showDetailViewController(detailvc, sender: self)
        }
    }
    
}

// -- > if you are reading data from a background thread—it may be computationally expensive to animate all the changes. Rather than responding to changes individually , you could just implement controllerDidChangeContent(_:) (which is sent to the delegate when all pending changes have been processed) to reload the table view.
extension TrafficCamsViewController: NSFetchedResultsControllerDelegate {
    

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
}
