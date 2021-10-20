//
//  SecondTableViewController.swift
//  BucketListLearnPlatform
//
//  Created by Rodrigo Leyva on 10/11/21.
//

import UIKit

protocol SecondVCDelegate: AnyObject{
    func cancelButtonPressed(by controller: UIViewController)
    func itemSaved(by controller: SecondTableViewController, with text: String, at indexPath: NSIndexPath?)
}

class SecondTableViewController: UITableViewController {
    
    weak var delegate: SecondVCDelegate?
    var edittedItem: String?
    var indexPath: NSIndexPath?

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = edittedItem

        // Uncomment the following line to preserve selection between presentations
        //
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if let text = textField.text{
            delegate?.itemSaved(by: self, with: text, at: indexPath)
        }
        
    }
    
}
