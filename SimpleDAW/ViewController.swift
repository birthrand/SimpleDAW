//
//  ViewController.swift
//  SimpleDAW
//
//  Created by Betrand Nnamdi on 31/03/2020.
//  Copyright © 2020 Betrand Nnamdi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayerNode!
    var engine: AVAudioEngine!
    var player: AVAudioPlayerNode!
    var url: URL?
    var audioFile: AVAudioFile!
    var speedControl: AVAudioUnitVarispeed!
    var pitchControl:AVAudioUnitTimePitch!
    
    var numberOfRecords:Int = 0
    
    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    @IBOutlet weak var timeCode: UILabel!
    
    var pitchDetectController : UIViewController!
    
    var fileArray = [String]()
    
    @IBAction func play(_ sender: Any) {
//        if(audioPlayer.isPlaying)
//        {
//            audioPlayer.stop()
            audioPlayer.scheduleFile(audioFile, at: nil)
            audioPlayer.play()
//        }
    }
    @IBAction func pause(_ sender: Any) {
        audioPlayer.pause()
    }
    @IBAction func stop(_ sender: Any) {
        //audioPlayer.scheduleFile(audioFile, at: nil)
        audioPlayer.stop()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        
        pitchControl.pitch = currentValue        //speedControl.rate += 0.1
    }
    
    @IBAction func backButton(_ sender: Any) {
        audioPlayer.pause()
    }
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    @IBAction func recordTapped(_ sender: Any)
    {
        //Check if we have an active recorder
        if(audioRecorder == nil)
        {
            //numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("Recording\(fileArray.count+1).m4a")
            
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
                
                buttonLabel.setTitle("Stop Recording", for: .normal)
                fileArray.append(filename.absoluteString)
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
                //UserDefaults.standard.set(numberOfRecords, forKey: "myNumber");
                
                audioTableView.reloadData()
                let indexPath = IndexPath(row: fileArray.count-1, section: 0)
                audioTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                audioTableView.scrollToRow(at: indexPath, at: .top, animated: true)

                do
                {
                    try engine.start()
                    
                }
                catch{
                    
                }
                buttonLabel.setTitle("Start Recording", for: .normal)
                 timeCode.text = "";
            }
            catch
            {
                displayAlert(title: "Oops!", message: "Failed to stop")
            }
        }
    }
    
    
    @objc func timecodeFunc(){
        if((audioRecorder?.record()) != nil){
        let min = Int(audioRecorder.currentTime / 60)

        let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
        let playinTime = String(format: "%02d:%02d", min, sec)
        timeCode.text = playinTime
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        //print(getDirectory())
        
        let fm = FileManager.default
        let items = try! fm.contentsOfDirectory(at:getDirectory(), includingPropertiesForKeys: nil)

        for item in items {
            fileArray.append(item.absoluteString)
        }
        print(fileArray.count)
         
        // Do any additional setup after loading the view.
//        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
//        {
//            self.numberOfRecords = number
//        }
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
        
        
        
        engine = AVAudioEngine()
        audioFile = AVAudioFile()
        speedControl = AVAudioUnitVarispeed()
        pitchControl = AVAudioUnitTimePitch()
        audioPlayer = AVAudioPlayerNode()
        // attach and connect the audio player, pitch control and speed control
        // to the engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        do
        {
            // start the audio engine
            try engine.start()
            
        }
        catch{
            
        }
        
        // disable pitch shift slider
        // and audio playback controls
        // reduce opacity of the elements
        pitchSlider?.isEnabled = false
        playButton?.isEnabled = false
        playButton?.alpha = 0.2;
        pauseButton?.isEnabled = false
        pauseButton?.alpha = 0.2;
        stopButton?.isEnabled = false
        stopButton?.alpha = 0.2;
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
    
    //SETTING UP TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set the label of the selected row to the file name
        //let path = getDirectory().appendingPathComponent("Recording\(indexPath.row + 1).m4a")
//        let path = getDirectory().appendingPathComponent(fileArray[indexPath.row+1])
        
        let path = URL.init(string: fileArray[indexPath.row])
        let fileName = URL(fileURLWithPath: path!.absoluteString).deletingPathExtension().lastPathComponent
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fileName

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(audioPlayer.isPlaying){
            audioPlayer.pause()}

        //let path = getDirectory().appendingPathComponent("Recording\(indexPath.row + 1).m4a")
//        let path = getDirectory().appendingPathComponent(fileArray[indexPath.row+1])

        
//        print("File:")
//        print(fileArray[indexPath.row])
        let path = URL(string: fileArray[indexPath.row])
//        print("Path:")
//        print(path)
        do
        {
            
            audioFile = try AVAudioFile(forReading: path!)
            audioPlayer.scheduleFile(audioFile, at: nil)
            
            // enable pitch shift slider
            // and audio playback controls
            // set opacity of the elements to the max value
            pitchControl.pitch = pitchSlider.value;
            pitchSlider.isEnabled = true
            playButton?.isEnabled = true
            playButton?.alpha = 1.0;
            pauseButton?.isEnabled = true
            pauseButton?.alpha = 1.0;
            stopButton?.isEnabled = true
            stopButton?.alpha = 1.0;
        }
        catch
        {
            ///
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // if the delete option is tapped implement the code in this function
        if editingStyle == .delete{
            //let path = getDirectory().appendingPathComponent("Recording\(indexPath.row + 1).m4a")
//            let path = getDirectory().appendingPathComponent(fileArray[indexPath.row+1])
            let path = URL(string: fileArray[indexPath.row])
            let fileManager = FileManager.default
            
            do {
                //delete the file from the user's device
                try fileManager.removeItem(at: path!)
                //reduce the number of existing records
                //numberOfRecords-=1
                fileArray.remove(at: indexPath.row)
                //delete the row from the table
                audioTableView.deleteRows(at: [indexPath], with: .automatic)
                //update the table
                //UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            }
            catch{
               displayAlert(title: "OOPS", message: "Delete failed")
            }
            
        }
    }
}

