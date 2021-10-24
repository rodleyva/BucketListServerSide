//
//  TaskModel.swift
//  BucketListLearnPlatform
//
//  Created by Rodrigo Leyva on 10/24/21.
//

import Foundation
import Alamofire

struct DeleteReponse: Codable{
    let message: String
}

struct AddTask: Codable{
    var id : Int?
    var objective: String
}

class TaskModel{

    
    static func getAllTask(completionHandler:@escaping (_ taskModel: [AddTask]?, _ error: Error?)->Void){
        
        AF.request("https://saudibucketlistapi.herokuapp.com/tasks/", method: .get).responseDecodable(of: [AddTask].self){ response in
            
            
            switch response.result{
            case .success(let items):

                completionHandler(items,nil)

            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil,error)
            }
            
        }
        
    }
    
    
    static func createTask(parameters: AddTask?, completionHandler:@escaping (_ error: Error?)->Void){
        
        AF.request("https://saudibucketlistapi.herokuapp.com/tasks/", method: .post, parameters: parameters).responseDecodable(of: AddTask.self) { response in
            
            switch response.result{
            case .success(let task):
                debugPrint(task)
                completionHandler(nil)
                
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }
    }
    
    static func updateTask(with id: Int, parameters: AddTask? ,completionHandler: @escaping (_ error: Error?)-> Void){
        AF.request("https://saudibucketlistapi.herokuapp.com/tasks/\(id)/", method: .put, parameters: parameters).responseDecodable(of: AddTask.self){ response in
            
            switch response.result{
            case .success(let task):
                debugPrint(task)
                completionHandler(nil)
                
            case .failure(let error):
                completionHandler(error)
            }
            
        }
    }
    
    static func deleteTask(with id: Int, completionHandler: @escaping (_ error: Error?)->Void){
        AF.request("https://saudibucketlistapi.herokuapp.com/tasks/\(id)/", method: .delete).responseDecodable(of: DeleteReponse.self){ response in
            
            switch response.result{
            case .success(let message):
                debugPrint(message)
                completionHandler(nil)
                
            case .failure(let error):
                completionHandler(error)
            }
            
        }
    }
    
    
    
    
}
