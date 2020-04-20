//
//  PlaybackController.swift
//  SimpleDAW
//
//  Created by Betrand Nnamdi on 20/04/2020.
//  Copyright © 2020 Betrand Nnamdi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class PlaybackController: UIViewController,  UITableViewDataSource, UITableViewDelegate{

    
    var audioPlayer: AVAudioPlayerNode!
    var engine: AVAudioEngine!
    var player: AVAudioPlayerNode!
    var url: URL?
    var audioFile: AVAudioFile!
    var speedControl: AVAudioUnitVarispeed!
    var pitchControl:AVAudioUnitTimePitch!
    //@IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var pitchSlider: UISlider!
    //@IBOutlet weak var playButton: UIButton!
    //@IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    //@IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var audioPlayBtn: UIButton!
    
    @IBOutlet weak var recordTapped: UIButton!

    //@IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    
    @IBAction func backBtn(_ sender: Any) {
        audioPlayer.stop()
        do{
         try recordingSession.setActive(false)
        }
        catch{
            
        }
    }
    
    @IBOutlet weak var recordingTableView: UITableView!{
        didSet {
            recordingTableView.dataSource = self
            recordingTableView.delegate = self
        }
    }
    var isPlaying:Bool = false
    
    
    var fileArray = [String]()
    
    
    
    @IBAction func playTapped(_ sender: UIButton) {
        let chkImage = sender.currentBackgroundImage!
        if chkImage == (UIImage(systemName: "play.circle")){
            sender.setBackgroundImage(UIImage(systemName: "pause.circle"), for: .normal)

            audioPlayer.play()
        }
            else {
            sender.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
            audioPlayer.pause()
        }

    }
    
    var toggleState = 1
        @IBAction func play(_ sender: Any) {
            }
 
            @IBAction func stop(_ sender: UIButton) {
                //audioPlayer.scheduleFile(audioFile, at: nil)
                if audioPlayBtn.currentBackgroundImage == UIImage(systemName: "pause.circle"){
                audioPlayBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
                       
                audioPlayer.stop()
            }
    }
            @IBAction func sliderChanged(_ sender: UISlider) {
                let currentValue = Float(sender.value)
                
                pitchControl.pitch = currentValue        //speedControl.rate += 0.1
            }
            
            @IBAction func backButton(_ sender: Any) {
                audioPlayer.pause()
            }
    

    var recordingSession:AVAudioSession!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        recordingSession = AVAudioSession.sharedInstance()
        do{
        try recordingSession.setCategory(AVAudioSession.Category.playback)
        }
        catch{
            
        }
        AVAudioSession.sharedInstance()
//        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
//
        
        let fm = FileManager.default
        let items = try! fm.contentsOfDirectory(at:getDirectory(), includingPropertiesForKeys: nil)
        fileArray.removeAll()
        for item in items {
            
            fileArray.append(item.absoluteString)
        }

        
        recordingTableView?.reloadData()
//
        let indexPath = IndexPath(row: fileArray.count-1, section: 0)
        //print(indexPath)
        recordingTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        recordingTableView.scrollToRow(at: indexPath, at: .top, animated: true)

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

        //if(indexPath.row < 0){
        // disable pitch shift slider
        // and audio playback controls
        // reduce opacity of the elements
        pitchSlider?.isEnabled = false
        pitchLabel?.isEnabled = false
        audioPlayBtn?.isEnabled = false
        audioPlayBtn?.alpha = 0.2;
        //pauseButton?.isEnabled = false
        //pauseButton?.alpha = 0.2;
        stopButton?.isEnabled = false
        stopButton?.alpha = 0.2;
    //}
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // After successfully finish song playing will stop audio player and remove from memory
            print("Audio player finished playing")
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            // Write code to play next audio.
            // or change icon to play icon
            audioPlayBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
//    let myarray = ["item1", "item2", "item3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        recordingTableView.dataSource = self
        //recordingTableView.reloadData()
//        recordingTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
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
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cell:")
        print(fileArray.count)
        //set the label of the selected row to the file name
        let path = URL.init(string: fileArray[indexPath.row])
        let fileName = URL(fileURLWithPath: path!.absoluteString).deletingPathExtension().lastPathComponent
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fileName
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //if(audioPlayer.isPlaying){
//             if isPlaying {
              isPlaying = false
              audioPlayBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
          //}
                            
            audioPlayer.stop()
//        }

        let path = URL(string: fileArray[indexPath.row])
        do
        {
            
            audioFile = try AVAudioFile(forReading: path!)
            audioPlayer.scheduleFile(audioFile, at: nil)
            
            // enable pitch shift slider
            // and audio playback controls
            // set opacity of the elements to the max value
            pitchControl.pitch = pitchSlider.value;
            pitchSlider.isEnabled = true
            pitchLabel.isEnabled = true
            audioPlayBtn?.isEnabled = true
            audioPlayBtn?.alpha = 1.0;
            //pauseButton?.isEnabled = true
            //pauseButton?.alpha = 1.0;
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
                
                let path = URL(string: fileArray[indexPath.row])
                let fileManager = FileManager.default
                
                do {
                    //delete the file from the user's device
                    try fileManager.removeItem(at: path!)
                    //reduce the number of existing records
                    
                    fileArray.remove(at: indexPath.row)
                    //delete the row from the table
                    recordingTableView.deleteRows(at: [indexPath], with: .automatic)
                    //update the table
                    
                }
                catch{
                   displayAlert(title: "OOPS", message: "Delete failed")
                }
                
            }
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
