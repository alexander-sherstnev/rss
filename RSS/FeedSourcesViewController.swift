//
//  FeedSourcesViewController.swift
//  RSS
//
//  Created by Alexander Sherstnev on 5/16/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import CoreData

class FeedSourcesViewController: UITableViewController {
    
    var _sources: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FeedSource")
        
        do {
            _sources = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Actions
    
    @IBAction func AddNewSource(_ sender: Any) {
        if _sources.count == 3 { return } // Max 3
        
        let alert = UIAlertController(title: "New Source",
                                      message: "Add a new Feed Source",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let url = textField.text else { return }
            
            self.saveFeedSource(url: url)
            self.tableView.reloadData()
        }
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedSource = _sources[indexPath.row]
        let url = feedSource.value(forKey: "url") as? URL
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table Cell", for: indexPath)
        cell.textLabel?.text = url?.absoluteString
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let source = _sources.remove(at: indexPath.row)
            deleteFeedSource(source: source)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Methods
    
    func saveFeedSource(url: String) {
        guard let feedURL = URL(string: url) else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let feedSourceEntity = NSEntityDescription.entity(forEntityName: "FeedSource", in: managedContext)!
        let feedSource = NSManagedObject(entity: feedSourceEntity, insertInto: managedContext)
        feedSource.setValue(feedURL, forKey: "url")
        
        do {
            try managedContext.save()
            _sources.append(feedSource)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFeedSource(source: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(source)
        do {
            try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
