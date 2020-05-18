//
//  FeedListViewController.swift
//  RSS
//
//  Created by Alexander Sherstnev on 5/16/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import CoreData

class FeedListViewController: UITableViewController {
    
    var _feeds: NSMutableArray = []
    var _images: NSMutableArray = []
    var _sources: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.dataSource = self
        tableView.delegate = self
        
        loadRSS()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: Any) {
        loadRSS()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = _feeds.object(at: indexPath.row) as AnyObject
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table Cell", for: indexPath)
        
        cell.textLabel?.text = feed.object(forKey: "title") as? String
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.text = feed.object(forKey: "pubDate") as? String
        cell.detailTextLabel?.textColor = .black
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        // Load image
        if indexPath.row >= 0 && indexPath.row < _images.count {
            let imageURL = NSURL(string: _images[indexPath.row] as! String)
            let imageData = NSData(contentsOf: imageURL! as URL)
            var image = UIImage(data: imageData! as Data)
            image = resizeImage(image: image!, toTheSize: CGSize(width: 70, height: 70))
            
            let cellImageLayer: CALayer?  = cell.imageView?.layer
            cellImageLayer!.cornerRadius = 35
            cellImageLayer!.masksToBounds = true
            cell.imageView?.image = image
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Open Feed" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let feed = _feeds[indexPath.row] as AnyObject
            let feedURL = feed.object(forKey: "link") as! String

            let feedViewController = segue.destination as! FeedViewController
            feedViewController.url = feedURL
        }
    }

    // MARK: - Methods
    
    func loadRSS() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FeedSource")
        
        do {
            _sources = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        _feeds = []
        _images = []
        let parser = RSSParser()
        for source in _sources {
            let url = source.value(forKey: "url") as! URL
            parser.load(url)
            
            for feed in parser.feeds() { _feeds.add(feed) }
            for image in parser.images() { _images.add(image) }
        }
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize) -> UIImage {
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;

        let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
}
