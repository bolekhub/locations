//
//  ImageViewController.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var camIdentifier: String?
    var datamanager: DataManager?
    @IBOutlet weak var imageContainer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datamanager = DataManager(api: TrafficAPI.default, dao: CoreDataDAO.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DOHUD.show()
        datamanager?.image(_forMetadataId: camIdentifier!, completion: { (image) in
            DOHUD.hide()
            DispatchQueue.main.async {
                self.imageContainer.image = image
            }
        })
    }
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
