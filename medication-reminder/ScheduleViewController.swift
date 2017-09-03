//
//  ScheduleViewController.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/01.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit
import Toaster

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //the cell identifier for this table view
    private let cellIdentifier = "tableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    //Core Data or a dictionary of arrays could be used to expand beyond 3 days
    private var tableDataToday = [ScheduleModel]()
    private var tableDataTomorrow = [ScheduleModel]()
    private var tableDataDayAfter = [ScheduleModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableview config
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        
        //request all data for the next 3 days from db
        ScheduleRestService().getMedicationSchedule { (array) in
            
            //safely unpack array
            if let array = array {
                
                let date = Date()
                let calendar = Calendar.current
                
                //get the current date of the following days
                let today = calendar.component(.day, from: date)
                let tomorrow = calendar.component(.day, from: date.addingTimeInterval(24*60*60))
                let dayAfter = calendar.component(.day, from: date.addingTimeInterval(2*24*60*60))
                
                //allocate each model to its array
                for model in array {
                    
                    if let day = model.getDay() {
                        
                        switch day {
                            case today:
                                self.tableDataToday.append(model)
                            case tomorrow:                                
                                self.tableDataTomorrow.append(model)
                            case dayAfter:
                                self.tableDataDayAfter.append(model)
                            default:
                                continue
                        }
                        
                    }
                    
                }
                
                //only reload if the array had any data
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    
    //TABLE VIEW 
    //SECTION | ROW | CELL
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return tableDataToday.count
        case 1:
            return tableDataTomorrow.count
        case 2:
            return tableDataDayAfter.count
        default:
            return 0
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellDataArray: [ScheduleModel]
        
        //assign the array to use
        switch indexPath.section {
        case 0:
            cellDataArray = tableDataToday
        case 1:
            cellDataArray = tableDataTomorrow
        case 2:
            cellDataArray = tableDataDayAfter
        default:
            return UITableViewCell() //if we dont find a match stop execution
        }
        
        //safely dequeue cell of correct type
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UIScheduleTableViewCell {
            
            //setup cell and return
            cell.setupCell(with: cellDataArray[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    //TABLE VIEW HEADERS
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        case 2:
            return "Day After Tomorrow"
        default:
            return nil
        }
        
    }
    
    
    
    // EDITING ROWS
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //handle swipe event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //alert controller setup
            let alertController = UIAlertController(title: "Delete Scheduled Medication", message: "Are you sure you want to delete this medication?", preferredStyle: .actionSheet)
            
            
            //alert controller delete event
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                var model : ScheduleModel!
                
                //assign the model
                switch indexPath.section {
                case 0:
                    model = self.tableDataToday[indexPath.row]
                case 1:
                    model = self.tableDataTomorrow[indexPath.row]
                case 2:
                    model = self.tableDataDayAfter[indexPath.row]
                default:
                    //safely end execution
                    return
                }
                
                //request data to be deleted
                ScheduleRestService().deleteScheduledMedication(indexPath: indexPath, model: model, callback: { indexPath in
                
                    //toast notification
                    Toast(text: "Scheduled Medication Deleted", delay: 0, duration: 3).show()
                    
                    //update data source
                    switch indexPath.section {
                    case 0:
                        self.tableDataToday.remove(at: indexPath.row)
                    case 1:
                        self.tableDataTomorrow.remove(at: indexPath.row)
                    case 2:
                        self.tableDataDayAfter.remove(at: indexPath.row)
                    default:
                        return
                    }
                    
                    //delete row
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    
                })
                
            }))
            
            //alert controller cancel event
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            //present alert controller
            self.present(alertController, animated: true)
            
        }
        
    }
    
}
