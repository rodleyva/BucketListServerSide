//
//  ViewController.swift
//  BucketListLearnPlatform
//
//  Created by Rodrigo Leyva on 10/11/21.
//

import UIKit
import Alamofire
import CloudKit




class TableViewController: UITableViewController {
    
    var items = [AddTask]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        // Do any additional setup after loading the view.
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "bucketCell", for: indexPath)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "bucketCell")

        cell.textLabel?.text = items[indexPath.row].objective
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row \(indexPath.row)")
        //update core data
        performSegue(withIdentifier: "onlySegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // remove the item at indexPath
        // reload the table view
        deleteItem(path: indexPath.row)
        
        tableView.reloadData()
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem{
            let navigationController = segue.destination as! UINavigationController
            
            let secondVC = navigationController.topViewController as! SecondTableViewController
            secondVC.delegate = self
        }
        if let sender = sender as? NSIndexPath{
            let navigationController = segue.destination as! UINavigationController
            
            let secondVC = navigationController.topViewController as! SecondTableViewController
            
            let item = items[sender.row]
            secondVC.edittedItem = item.objective
            //New line
            secondVC.indexPath = sender
            secondVC.delegate = self
        }
    }
    
    // core data
//    func getUpdatedContext()->NSManagedObjectContext{
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        return delegate.persistentContainer.viewContext
//
//    }
    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    // create item to core data
    func addItem(text: String){
        
        let item = AddTask(objective: text)
        
        TaskModel.createTask(parameters: item) { error in
            if let error = error {
                print("Error:\(error.localizedDescription)")
                // show user an error
            }
        }
        
        
        items.append(item)
        self.tableView.reloadData()
        
        
        
    }
    // read item from core data
    func fetchAllItems(){
        // make API call
        
        TaskModel.getAllTask { taskModel, error in
            if let error = error{
                print(error.localizedDescription)
                //show the user an error
                return
            }
            if let taskModel = taskModel {
                DispatchQueue.main.async {
                    self.items = taskModel
                    self.tableView.reloadData()
                }
            }
        }
        

    }
    // update data from core data
    func updateItem(text: String, path: Int){
        
        guard let id = items[path].id else {return}
        
        
        items[path].objective = text
        
        TaskModel.updateTask(with: id, parameters: items[path]) { error in
            if let error = error{
                print(error.localizedDescription)
                //Show user an error
            }
            
        }
        tableView.reloadData()
        
        
    }
    //delete item from core data
    func deleteItem(path: Int){
        
        guard let id = items[path].id else {return}
        
        TaskModel.deleteTask(with: id) { error in
            if let error = error {
                //TEll user there's an error deleting
                print(error.localizedDescription)
            }
        }
        
        self.items.remove(at: path)
        self.tableView.reloadData()
        
        
    }
    
    


}

extension TableViewController: SecondVCDelegate{
    

    func itemSaved(by controller: SecondTableViewController, with text: String, at indexPath: NSIndexPath?) {
        
        
        // if indexPath exist then we want to edit instead of append
        if let ip = indexPath{
            
            //update our data
            updateItem(text: text, path: ip.row)
            
        }else{
            addItem(text: text)
            
        }
        
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonPressed(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

