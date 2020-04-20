//
//  ViewController.swift
//  SimpleDAW
//
//  Created by Betrand Nnamdi on 31/03/2020.
//  Copyright © 2020 Betrand Nnamdi. All rights reserved.
//
import UIKit
import AudioKit

class PItchViewController: UIViewController {

    var tracker : AKFrequencyTracker!

    
    @IBOutlet weak var sharpLabel: UILabel!
    @IBOutlet weak var frequency: UILabel!
    @IBOutlet weak var noteSharp: UILabel!
    @IBOutlet weak var noteFlat: UILabel!
    @IBOutlet weak var amplitude: UILabel!
    
    
    @IBOutlet weak var pitchButton: UIButton!
    
    var detecting = false
    @IBAction func backBtn(_ sender: Any) {
//        do {
//         try AudioKit.stop()
//            
//        } catch  {
//
//        }
    }
    var timer = Timer()
    
    @IBAction func pitchButtonTapped(_ sender: UIButton)
    {
        if(pitchButton.titleLabel?.text == "Detect Pitch")
        {
            pitchButton.setTitle("Detecting..", for: .normal)
            sharpLabel.pulsate()

            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
            //detecting = false
        }
        else
        {
            pitchButton.setTitle("Detect Pitch", for: .normal)
            timer.invalidate()
        }
    }
    
    @objc  func donotupdate() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        frequency.text = "0"

        amplitude.text = "0"

        noteSharp.text = "C4"

        noteFlat.text = "F4"
   
        //AKSettings.setSession()
        //print(AKSettings.sampleRate)
        let mic = AKMicrophone()
        
        //AKSettings.sampleRate = session.sampleRate

        // attach the microphone input to the frequency tracker
        tracker = AKFrequencyTracker.init(mic)
        let silence = AKBooster(tracker, gain:0)
        AudioKit.output = silence

        do {
                try AudioKit.start()
            
        } catch  {

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @objc  func updateUI() {
        
        let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
        let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
        let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
        
        if tracker.amplitude > 0.1 {
            frequency.text = String(format: "%0.1f", tracker.frequency)
        
            var frequency = Float(tracker.frequency)
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])){
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            var minDistance : Float = 10000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if (distance < minDistance) {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteSharp.text = "\(noteNamesWithSharps[index])\(octave)"
            sharpLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteFlat.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        
        amplitude.text = String(format: "%0.2f", tracker.amplitude)
    }

}
