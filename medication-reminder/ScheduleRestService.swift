//
//  scheduleRestService.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/02.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 Service for interacting with the medications rest api
 */
class ScheduleRestService {
    
    //The base url this service queries against
    private let urlPrefix = "\(REST_DOMAIN)/api/medications"
    private let formatter = DateFormatter()
    private let calendar = Calendar.current
    
    init() {
        //set the date formatter to use the current mongo date format
        formatter.dateFormat = MONGO_DATE_FORMAT
    }
    
    /**
     The current valid schedule model for today. Asynchronous.
     - returns: A ScheduleModel
     */
    public func getNextMedication(callback: @escaping ((ScheduleModel?) -> ())){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //24 * 60 * 60 - extends schedule query to tomorrow
        let url = urlPrefix + getScheduleQuery(with: 24 * 60 * 60)
        
        let method = HTTPMethod.get
        
        Alamofire.request(url, method: method)
            .validate()
            .responseData { (responseData) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            //safely unpack data
            if let responseData = responseData.data {
                
                //unpack the data into an array
                if let array = JSON(data: responseData).array {
                    
                    let todayMS = Date().timeIntervalSinceReferenceDate
                    
                    //remove any scheduled medication for today that has elapsed
                    var schedule = array.filter({ (json) -> Bool in
                        
                        //get when this medication must be taken
                        let _date = self.formatter.date(from: json["time"].stringValue)
                        
                        if let _date = _date {
                            
                            return _date.timeIntervalSinceReferenceDate > todayMS
                            
                        } else {
                            
                            return false
                            
                        }
                        
                    })
        
                    
                    //sort the remaining elements into soonest first and latest last
                    schedule.sort(by: { (json_1, json_2) -> Bool in
                    
                        if let date_1 = self.formatter.date(from: json_1["time"].stringValue),
                            let date_2 = self.formatter.date(from: json_2["time"].stringValue) {
                    
                            return date_1.timeIntervalSinceReferenceDate < date_2.timeIntervalSinceReferenceDate
                    
                        }
                                            
                        return false
                                            
                    })
                    
                    
                    //if we have json data left in the array send it back to the controller
                    if let json = schedule.first {
                        callback(ScheduleModel(json))
                    } else {
                        callback(nil)
                    }
                    
                } else {
                    //return nil if data couldnt be unpacked into array
                    callback(nil)
                }
                
            } else {
                //if data could not be unpacked safely then return
                callback(nil)
            }
            
        }
        
    }
    
    /**
     The schedule for the next 3 days. Asynchronous.
     - returns: ScheduleModel Array
     */
    public func getMedicationSchedule(callback: @escaping ([ScheduleModel]?) -> ()){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //24 * 60 * 60 extends schedule query to tomorrow
        let url = urlPrefix + getScheduleQuery(with: 3 * 24 * 60 * 60)
        let method = HTTPMethod.get
        
        
        Alamofire.request(url, method: method)
            .validate()
            .responseData { (responseData) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // safely unpack data
                if let responseData = responseData.data {
                    
                    //safely get array
                    if let array = JSON(data: responseData).array {
                        
                        let todayMS = Date().timeIntervalSinceReferenceDate
                        
                        //remove any medication from today that has elapsed
                        var filteredArray = array.filter({ (json) -> Bool in
                            
                            let _date = self.formatter.date(from: json["time"].stringValue)
                            
                            if let _date = _date {
                                
                                return _date.timeIntervalSinceReferenceDate > todayMS
                                
                            } else {
                                
                                return false
                                
                            }
                            
                        })
                        
                        
                        //sort the remaining elements -> soonest first
                        filteredArray.sort(by: { (json_1, json_2) -> Bool in
                            
                            if let date_1 = self.formatter.date(from: json_1["time"].stringValue),
                                let date_2 = self.formatter.date(from: json_2["time"].stringValue) {
                                
                                return date_1.timeIntervalSinceReferenceDate < date_2.timeIntervalSinceReferenceDate
                                
                            }
                            
                            return false
                            
                        })
                        
                        var schedule = [ScheduleModel]()
                        
                        //iterate over the sorted array; build each object and then
                        //add to the schedule array
                        for json in filteredArray {
                            schedule.append(ScheduleModel(json))
                        }
                        
                        //send the array back to the controller
                        callback(schedule)
                        
                    } else {
                        
                        //return nil if array couldnt be unpacked
                        callback(nil)
                        
                    }
                    
                } else {
                    
                    //return nil if data couldnt be unpacked
                    callback(nil)
                    
                }
                
        }
        
    }
    
    /**
     Updates the DB to show the user has taken their medication. Asynchronous.
    */
    public func medicationTaken(model: ScheduleModel, callback: @escaping () -> ()){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = "\(urlPrefix)/\(model.getID())"
        let method = HTTPMethod.put
        
        //update model
        let parameters: [String : Any] = [
            "_id": model.getID(),
            "name": model.getName(),
            "completed": true,
            "time": model.getTimeRaw(),
            "dosage": model.getDosage(),
            "__v": model.getVVariable(),
            "d" : ["c":model.getCVariable()]
        ]
        
        Alamofire.request(url, method: method, parameters: parameters)
            .validate()
            .responseData { (responseData) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                //let the controller know that update successful
                callback()
                
            };
        
        
    }
    
    /**
     Deletes a Scheduled Medication for the user. Asynchronous.
     */
    public func deleteScheduledMedication(indexPath: IndexPath, model: ScheduleModel, callback: @escaping (IndexPath) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = "\(urlPrefix)/\(model.getID())"
        let method = HTTPMethod.delete
        
        Alamofire.request(url, method: method)
            .validate()
            .responseData { (responseData) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                //let the controller know that data was successfully deleted
                callback(indexPath)
                
        }
        
    }
    
    /**
     Dont pass in less than 24 hours otherwise you will get a blank json array
     */
    private func getScheduleQuery(with interval: Int) -> String {
        
        //get the current date and adjust the future date for the passed in interval
        let currentDate = Date()
        var futureDate = Date()
        futureDate = futureDate.addingTimeInterval(TimeInterval(interval))
        
        //get the necessary components
        let today = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let tomorrow = calendar.dateComponents([.year, .month, .day], from: futureDate)
        
        //blank variables incase a value couldnt be unpacked
        var start = ""
        var end = ""
        
        //set the start query
        if let month = today.month, let day = today.day, let year = today.year {
            
            start = "start=\(month)/\(day)/\(year)"
            
        }
        
        //set the end query
        if let month = tomorrow.month, let day = tomorrow.day, let year = tomorrow.year {
            
            end = "end=\(month)/\(day)/\(year)"
            
        }
        
        return "?\(start)&\(end)"
        
    }
    
}
