//
//  ScheduleModel.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/02.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScheduleModel {
    
    private var id: String!
    private var name: String!
    private var dosage: String!
    private var completed: Bool!
    private var time: String!
    
    private var vVariable: String!
    private var cVariable: String!
    
    init(_ json: JSON) {
        
        self.id = json["_id"].string
        self.name = json["name"].string
        self.dosage = json["dosage"].string
        self.completed = json["completed"].bool
        self.time = json["time"].string
        self.cVariable = json["d"]["c"].stringValue
        self.vVariable = json["__v"].stringValue
        
    }
    
    //Getters and Setters
    
    public func getID() -> String {
        return id
    }
    
    public func setID(id: String){
        self.id = id
    }
    
    public func setName(name: String) {
        self.name = name
    }
    
    public func getName() -> String {
        return name
    }
    
    public func setDosage(dosage: String) {
        self.dosage = dosage
    }
    
    public func getDosage() -> String {
        return dosage
    }
    
    public func setCompleted(completed: Bool) {
        self.completed = completed
    }
    
    public func getCompleted() -> Bool {
        return completed
    }
    
    public func setTime(time: String){
        self.time = time
    }
    
    public func getTimeRaw() -> String {
        return time
    }
    
    public func getTime() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = MONGO_DATE_FORMAT
        
        return formatter.date(from: time)
        
    }
    
    public func getVVariable() -> String {
        return vVariable
    }
    
    public func getCVariable() -> String {
        return cVariable
    }
    
    // TIME PERIOD GETTERS WITH MANIPULATION
    
    public func getDay() -> Int? {
        
        if let date = getTime() {
            return Calendar.current.component(.day, from: date)
        }
        
        return nil
        
    }
    
    /**
     Gets the seconds until the medication is due
     */
    public func getTimeIntervalUntilDue() -> TimeInterval {
        let date = Date()
        
        if let dueDate = getTime() {
            
            return dueDate.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
            
        }
        
        return 0
    }
    
    public func getTimeIntervalSinceRegistered() -> TimeInterval {
        
        let formatter = DateFormatter()
        formatter.dateFormat = MONGO_DATE_FORMAT
        
        if let startDate = formatter.date(from: cVariable), let dueDate = formatter.date(from: time) {
            
            return dueDate.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
            
        }
        
        return 0
    }
    
    /**
     Gets the hour and minute that medication is due.
     Will add a 0 before single digit timeperiods
     */
    public func getHourAndMinute() -> String {
        
        let date = getTime()
        let calendar = Calendar.current
        
        if let date = date {
            
            var hour = "00"
            var minute = "00"
            
            let time = calendar.dateComponents([.hour, .minute], from: date)
            
            if let _hour = time.hour {
                hour = "\(_hour)"
                
                if _hour < 10 {
                    hour = "0" + hour
                }
                
            }
            
            if let _minute = time.minute {
                minute = "\(_minute)"
                
                if _minute < 10 {
                    minute = "0" + minute
                }
            }
            
            return "\(hour) : \(minute)"
            
        } else {
            return "Time Error"
        }
        
    }
    
}
