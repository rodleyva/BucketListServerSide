//
//  ViewController.swift
//  BucketListLearnPlatform
//
//  Created by Rodrigo Leyva on 10/11/21.
//

import UIKit
import Alamofire



class TableViewController: UITableViewController {
    
    var items = [Tasks]()
    

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
        //creating context
        //let context = getUpdatedContext()
        //creating a new item
        //let item = BucketListItem.init(context: context)
        let item = Tasks(id: UUID(), createdAt: Date(), objective: text)
        // setting the item's text
        // appending item to our list so it shows
        // on the table view
        items.append(item)
        
        let encoder = JSONParameterEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        encoder.encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        AF.request("http://127.0.0.1:8080/tasks", method: .post, parameters: item, encoder: encoder).response { response in
            
            debugPrint(response)
        }
        
        //make api call
        
//        do{
//            //finally saving the context so the item
//            //is persisted
//            try context.save()
//        }catch{
//            print(error.localizedDescription)
//        }
        
    }
    // read item from core data
    func fetchAllItems(){
        // make API call
        
        AF.request("http://127.0.0.1:8080/tasks", method: .get).responseJSON{ response in
            
            if let data = response.data{
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let items = try! decoder.decode([Tasks].self, from: data)
                
                DispatchQueue.main.async {
                    self.items = items
                    self.tableView.reloadData()
                }
                
            }
           
            
        }
        
        
//        let context = getUpdatedContext()
//        let itemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BucketListItem")
        
//        do{
//            let results = try context.fetch(itemRequest)
//            items = results as! [BucketListItem]
//        }catch{
//            print(error.localizedDescription)
//        }

    }
    // update data from core data
    func updateItem(text: String, path: Int){
        
//        let context = getUpdatedContext()
        items[path].objective = text
        
        guard let id = items[path].id else {return}
        
        let encoder = JSONParameterEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        encoder.encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        AF.request("http://127.0.0.1:8080/tasks/\(id)", method: .post, parameters: items[path], encoder: encoder).response{ reponse in
            
            switch reponse.result{
            case .success(_):
                print(reponse.response?.statusCode)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.createAlert(title: "Error", message: "There was an error updating your note on the server \(error.localizedDescription)")
                }
            }
            
        }
        
//        do{
//            try context.save()
//        }catch{
//            print(error.localizedDescription)
//        }
        
        
    }
    //delete item from core data
    func deleteItem(path: Int){
        //let context = getUpdatedContext()
        
        //context.delete(items[path])
        
        
        guard let id = items[path].id else {return}
        
        
        
        
        AF.request("http://127.0.0.1:8080/tasks/\(id)", method: .delete).response{ response in
            
            switch response.result{
            case .success(_):
                DispatchQueue.main.async {
                    self.items.remove(at: path)
                    self.tableView.reloadData()
                    self.createAlert(title: "Success", message: "Succesfully delete note from server")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.createAlert(title: "Error could not delte note", message: error.localizedDescription)
                }
            }
        }
        
//        do{
//            try context.save()
//        }catch{
//            print(error.localizedDescription)
//        }
        
        
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

