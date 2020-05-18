//
//  RSSParser.swift
//  RSS
//
//  Created by Alexander Sherstnev on 5/16/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    
    // Core
    var _parser: XMLParser = XMLParser()
    var _feeds: NSMutableArray = []
    var _images: NSMutableArray = []
    
    // RSS data
    var _elements: NSMutableDictionary = [:]
    var _element: NSString = ""
    var _title: NSMutableString = ""
    var _link: NSMutableString = ""
    var _description: NSMutableString = ""
    var _date: NSMutableString = ""
    
    // MARK: - Methods
    
    func load(_ url: URL) {
        _feeds = []
        _images = []
        _parser = XMLParser(contentsOf: url)!
        _parser.delegate = self
        _parser.shouldProcessNamespaces = false
        _parser.shouldReportNamespacePrefixes = false
        _parser.shouldResolveExternalEntities = false
        _parser.parse()
    }
    
    func feeds() -> NSMutableArray {
        return _feeds
    }
    
    func images() -> NSMutableArray {
        return _images
    }
    
    // MARK: - XML Parser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        _element = elementName as NSString
        if (_element as NSString).isEqual(to: "item") {
            _elements = [:]
            _title = ""
            _link = ""
            _description = ""
            _date = ""
        } else if (_element as NSString).isEqual(to: "enclosure") {
            if let urlString = attributeDict["url"] {
                _images.add(urlString)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        if (elementName as NSString).isEqual(to: "item") {
            if _title != "" {
                _elements.setObject(_title, forKey: "title" as NSCopying)
            }
            if _link != "" {
                _elements.setObject(_link, forKey: "link" as NSCopying)
            }
            if _description != "" {
                _elements.setObject(_description, forKey: "description" as NSCopying)
            }
            if _date != "" {
                _elements.setObject(_date, forKey: "pubDate" as NSCopying)
            }
            _feeds.add(_elements)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if _element.isEqual(to: "title") {
            _title.append(string)
        } else if _element.isEqual(to: "link") {
            _link.append(string)
        } else if _element.isEqual(to: "description") {
            _description.append(string)
        } else if _element.isEqual(to: "pubDate") {
            _date.append(string)
        }
    }
}
