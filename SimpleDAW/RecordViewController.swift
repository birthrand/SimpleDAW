//
//  RecordViewController.swift
//  SimpleDAW
//
//  Created by Betrand Nnamdi on 19/04/2020.
//  Copyright © 2020 Betrand Nnamdi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class RecordViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate{

    

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
//    var audioPlayer: AVAudioPlayerNode!
//    var engine: AVAudioEngine!
//    var player: AVAudioPlayerNode!
//    var url: URL?

    @IBOutlet weak var recordTapped: UIButton!

    @IBOutlet weak var timeLabel: UILabel!
   
    
    
    
    var isRecording:Bool = false
    //var isPlaying:Bool = false
    var fileArray = [String]()
    var numberOfRecords=0
    
    @IBAction func recordTap(_ sender: UIButton) {
        
        if isRecording {
            
            isRecording = false
            recordTapped.setBackgroundImage(UIImage(systemName:"mic.circle"), for: .normal)
       }
       else
       {
        
        isRecording = true
        
        recordTapped.setBackgroundImage(UIImage(systemName: "stop.circle"), for: .normal)
       }
    }
    
    @IBAction func recordTapped(_ sender: Any)
    {
        //Check if we have an active recorder
        if(audioRecorder == nil)
        {
            var filename = getDirectory().appendingPathComponent("Recording\(fileArray.count+1).m4a")
            if(fileArray.contains(filename.absoluteString))
            {
                if let index = fileArray.firstIndex(of: filename.absoluteString) {
                    fileArray.remove(at: index)
                }
                filename = getDirectory().appendingPathComponent("Recording\(fileArray.count+2).m4a")
            }
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey:1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start audio recording
            do
            {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                try recordingSession.setCategory(AVAudioSession.Category.record)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timecodeFunc), userInfo: nil, repeats: true)

                fileArray.append(filename.absoluteString)
                print(fileArray.count)
                //print(fileArray)
                
            }
            catch
            {
                displayAlert(title: "Oops!", message: "Recording Failed")
            }
        }
        else
        {
            //Stop audio recording
            do
            {
                audioRecorder.stop()
               
                audioRecorder = nil
                try recordingSession.setCategory(AVAudioSession.Category.playback)

                 timeLabel.text = "";
                self.tabBarController?.selectedIndex = 1
            }
            catch
            {
                displayAlert(title: "Oops!", message: "Failed to stop")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if((segue.destination as? UITabBarController) != nil)
        {
        let barViewControllers: UITabBarController? = segue.destination as? UITabBarController
        let recordView = barViewControllers?.viewControllers?[0] as! RecordViewController
        //print(fileArray)
        recordView.fileArray = fileArray

        // access the second tab bar
        let playView = barViewControllers?.viewControllers?[1] as! PlaybackController
        playView.fileArray = recordView.fileArray
        }
    }
    
    @objc func timecodeFunc(){
        if((audioRecorder?.record()) != nil){
        let min = Int(audioRecorder.currentTime / 60)

        let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
        let playinTime = String(format: "%02d:%02d", min, sec)
        timeLabel.text = playinTime
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        recordTapped?.pulsate()
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        //print(recordingSession.sampleRate)
        //print(AKSettings.sampleRate)
        
        //prints ACCEPTED if permissions were granted
        AVAudioSession.sharedInstance().requestRecordPermission{(hasPermission) in
            if hasPermission
            {
                print("ACCEPTED")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }


    //Function that gets path to directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function that displays an alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
