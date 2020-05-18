//
//  FeedViewController.swift
//  RSS
//
//  Created by Alexander Sherstnev on 5/16/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import WebKit

class FeedViewController: UIViewController {

    @IBOutlet weak var _webView: WKWebView!
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url = url?.replacingOccurrences(of: " ", with:"")
                  .replacingOccurrences(of: "\n", with:"")
        _webView.load(URLRequest(url: URL(string: url! as String)!))
    }
    
    // MARK: - Actions
    
    @IBAction func share(_ sender: Any) {
        let shareURL = URL(string: url!)!
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        activityVC.isModalInPresentation = true
        present(activityVC, animated: true, completion: nil)
    }
}
