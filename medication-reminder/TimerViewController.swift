//
//  TimerViewController.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/01.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Toaster

class TimerViewController: UIViewController {
    
    //the uiview used when data was found for today. 
    //If no data was found we default to the no dataview
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var noDataView: UIView!
    
    //the checkbox / hourglass
    @IBOutlet weak var borderImageView: UIBorderImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var borderImageViewBottomConstraint: NSLayoutConstraint!
    
    //alarm bell ripple view
    @IBOutlet weak var rippleView_1: UIBorderView!
    
    //labels
    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var dosageRequiredLabel: UILabel!
    @IBOutlet weak var takeAtLabel: UILabel!
    @IBOutlet weak var alarmCountdownLabel: UILabel!
    
    //button
    @IBOutlet weak var prescriptionTakenButton: UIButton!
    //animated
    @IBOutlet weak var alarmBell: UIImageView!
    
    //references
    private var alarmTimer: Timer?
    private var countdownLabelTimerRef: Timer?
    private var player: AVAudioPlayer?
    private var secondsLayer: CAShapeLayer!
    private var timerLayer: CAShapeLayer!
    
    //the model used to display this views data
    private var model: ScheduleModel?
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //set bottom constraint constant proportionally to parent height
        let viewHeight = imageContainer.frame.size.height
        borderImageViewBottomConstraint.constant = viewHeight * 0.3
        
        //calculate the radius needed for a circle now that constraints have been resized
        borderImageView.makeCircular()
        //set the border to clear
        borderImageView.setBorderColor(.clear)
        borderImageView.setShadow()
        
        //setup the uiview used in the alarm animation
        rippleView_1.setBorderColor(UIColor(red: 0.5, green: 0, blue: 0.25, alpha: 0.75))
        rippleView_1.makeCircular()
        
        //construct the layers used in the timer circle
        setupCircleTimers()
        
        //make the prescription taken button circular
        prescriptionTakenButton.makeCircular()
        prescriptionTakenButton.clipsToBounds = true
        
        //delay the view did appear to prevent the user seeing any setup
        super.viewDidAppear(animated);
        
        //get the next scheduled medicine for today 
        getCurrentMedication()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove all references that could cause a leak
        alarmTimer?.invalidate()
        countdownLabelTimerRef?.invalidate()
        player?.stop()
        self.rippleView_1.stopAnimations()
        clearCircleAnimation()
        
    }
    
    //BUTTONS
    @IBAction func prescriptionTakenButton(_ sender: Any) {
        
        //check model is not null
        guard let model = self.model else {
            return
        }
        
        //check if the user was meant to take this medication now
        if model.getTimeIntervalUntilDue() <= 0 {
        
            //update the db
            ScheduleRestService().medicationTaken(model: model, callback: {
            
                //get the next medication required for today
                self.getCurrentMedication()
                Toast(text: "Prescription Taken", delay: 0, duration: 3).show()
        
            })
            
        }
        
    }
    
    //May be used on init and for every re-init thereafter.
    //Re-init will occur on user taking medication
    private func getCurrentMedication(){
        ScheduleRestService().getNextMedication { (model) in
            
            if let model = model {
                
                //reset the view for this model's data
                self.resetView(model: model)
                self.dataView.isHidden = false
                self.noDataView.isHidden = true
                
            } else {
            
                //hide the data view as no model was found
                self.dataView.isHidden = true
                self.noDataView.isHidden = false
                
                
            }
            
        }
    }
    
    //CONVENIENCE
    
    /**
     Creates a timer for when the user should take their medication
     */
    func setAlarmTimer() -> Timer {
        
        //if model null then return timer object
        guard let model = self.model else {
            return Timer()
        }
    
        //return a timer set to go off when user must take medication
        return Timer.scheduledTimer(withTimeInterval: model.getTimeIntervalUntilDue(), repeats: false, block: { _ in
            
            //perform ui updates to reflect alarm state
            self.timeToTakeMedication()
            
            
        })
        
    }
    
    /**
     Creates a timer to update the countdown label's text as medication time approaches
     */
    func setCountdownTimer() -> Timer {
        
        //return a timer object if model is null
        guard model != nil else {
            return Timer()
        }
        
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            
            //get the hours / mins / sec left in the scheduleperiod
            let _hours = Int(floor(self.model!.getTimeIntervalUntilDue()/(60*60)))
            let _minutes = Int(floor(self.model!.getTimeIntervalUntilDue().truncatingRemainder(dividingBy: 60*60)/60))
            let _seconds = Int(floor(self.model!.getTimeIntervalUntilDue().truncatingRemainder(dividingBy: 60*60).truncatingRemainder(dividingBy: 60)))
            
            var hours = "\(_hours)"
            var minutes = "\(_minutes)"
            var seconds = "\(_seconds)"
            
            // Append a zero in front of hours / mins / sec if digit less than 10
            if _hours < 10 {
                hours = "0" + hours
            }
            
            if _minutes < 10 {
                minutes = "0" + minutes
            }
            
            if _seconds < 10 {
                seconds = "0" + seconds
            }
            
            //set label text
            self.alarmCountdownLabel.text = "\(hours) : \(minutes) : \(seconds)"
            
        })
        
    }
    
    /**
     Resets the view for the next scheduled medication
     IE the period while the user waits to take their next medication
     */
    func resetView(model: ScheduleModel){
        
        //update the model
        self.model = model
        
        //setup the medication required labels
        self.medicationNameLabel.text = model.getName()
        self.dosageRequiredLabel.text = model.getDosage()
        self.takeAtLabel.text = model.getHourAndMinute()
        
        //hide buttons and visible alerts
        self.prescriptionTakenButton.isHidden = true
        self.alarmBell.isHidden = true
        self.rippleView_1.isHidden = true
        
        //stop animation and audio
        self.rippleView_1.stopAnimations()
        stopAlarm()
        
        //setup new timers
        self.alarmTimer = self.setAlarmTimer()
        self.countdownLabelTimerRef = self.setCountdownTimer()
        
        //reset the countdown labels text
        alarmCountdownLabel.text = ""
        alarmCountdownLabel.textColor = UIColor(red: 117/256, green: 117/256, blue: 117/256, alpha: 1)
        
        //setup new animations
        animateCircleTimers(timeTillDue: model.getTimeIntervalUntilDue(), timePeriod: model.getTimeIntervalSinceRegistered())
        showCircleTimers()
        
        
    }
    
    /**
     Sets the view into alert mode
     IE the time when the user should now take their medication
     */
    func timeToTakeMedication(){
        
        //show alert ui elements
        self.prescriptionTakenButton.isHidden = false
        self.alarmBell.isHidden = false
        self.rippleView_1.isHidden = false
        
        //stop non-alert animations
        clearCircleAnimation()
        hideCircleTimers()
        
        //stop the label timer
        self.countdownLabelTimerRef?.invalidate()
        
        //update the countdown label
        alarmCountdownLabel.text = "Prescription Taken?"
        alarmCountdownLabel.textColor = UIColor(red: 76/256, green: 175/256, blue: 80/256, alpha: 1)
    
        //play audio and animations
        playAlarm()
        self.rippleView_1.animateRipple()
        
    }
    
    //stop both circular timer animations
    func clearCircleAnimation(){
        
        secondsLayer.removeAnimation(forKey: "drawBorder")
        timerLayer.removeAnimation(forKey: "drawBorder")
        
    }
    
    //hides the circle timers
    func hideCircleTimers(){
        secondsLayer.isHidden = true
        timerLayer.isHidden = true
    }
    
    //shows the circle timers
    func showCircleTimers(){
        secondsLayer.isHidden = false
        timerLayer.isHidden = false
    }
    
    //performs the initial setup for the circle timers
    func setupCircleTimers(){
        
        //initialise the layers
        secondsLayer = CAShapeLayer()
        timerLayer = CAShapeLayer()
        
        //calculate the offset, center and base radius
        let viewHeight = imageContainer.frame.size.height
        
        let circleCenter = CGPoint(x: borderImageView.frame.origin.x + borderImageView.frame.width / 2,
                                   y: viewHeight * 0.2 + borderImageView.frame.height / 2)
        let circleRadius = borderImageView.frame.width / 2
        
        //borders of the circle timers
        let secondsLayerBorderWidth: CGFloat = 4
        let timerLayerBorderWidth: CGFloat = 8
        let padding: CGFloat = 4
        
        //#############################
        //Each circle has their own radius and is drawn on top of the borderImageView.
        //The borderImageView is what contains the hourglass / checkmark
        //#############################
        //The circle radius is from the borderImageView; this is the biggest that the circle timer can ever be
        //Remove padding from each circle timer radius to give a little extra border to the borderImageView
        //Adjust the radius of each layer relative each other
        //#############################
        let secondsLayerRadius: CGFloat = circleRadius - timerLayerBorderWidth - padding
        let timerLayerRadius: CGFloat = circleRadius - secondsLayerBorderWidth / 2 - padding
        
        
        //create the circle using all the calculated parameters
        secondsLayer.createAnimatableCircleBorder(center: circleCenter,
                                                  radius: secondsLayerRadius,
                                                  strokeColor: UIColor(red: 153/256, green: 50/256, blue: 102/256, alpha: 1),
                                                  fillColor: .clear,
                                                  lineWidth: secondsLayerBorderWidth)
        
        timerLayer.createAnimatableCircleBorder(center: circleCenter,
                                                radius: timerLayerRadius,
                                                strokeColor: UIColor(red: 183/256, green: 111/256, blue: 147/256, alpha: 1),
                                                fillColor: .clear,
                                                lineWidth: timerLayerBorderWidth)
        
        //insert each layer into the current view
        view.layer.insertSublayer(secondsLayer, above: imageContainer.layer)
        view.layer.insertSublayer(timerLayer, below: secondsLayer)
        
    }
    
    /**
     sets up the animations for the circle timers
     */
    func animateCircleTimers(timeTillDue: TimeInterval, timePeriod: TimeInterval){
        
        //animate the end stroke
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        //animation params
        animation.duration = 60
        animation.fromValue = 0
        animation.toValue = 1
        animation.repeatCount = Float.infinity
        
        //apply the animation
        secondsLayer.add(animation, forKey: "drawBorder")
        
        //animation params
        //can just reuse existing animation object
        animation.fromValue = 1 - (timeTillDue / timePeriod)
        animation.duration = timeTillDue
        
        //apply animation again
        timerLayer.add(animation, forKey: "drawBorder")
        
    }
    
    /**
     Plays audio to alert the user
     */
    func playAlarm(){
    
        let path = Bundle.main.path(forResource: "alarm", ofType: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.prepareToPlay()
            player?.play()
        } catch {
            //normally some remote logging would go here
        }
    
    }
    
    /**
     stops playing the alarm
     */
    func stopAlarm(){
        player?.stop()
    }
    
}
