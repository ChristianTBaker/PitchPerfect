//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Christian Baker on 12/6/20.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var hasPermission: Bool = false

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission{ granted in
            if granted{
                self.hasPermission = true
            }
            else {
                self.hasPermission = false
            }
        }
    }
    
    func manageRecording(_ startRecording: Bool) {
        let session = AVAudioSession.sharedInstance()
        recordButton.isEnabled = !startRecording
        stopRecordingButton.isEnabled = startRecording
        recordingLabel.text = startRecording ? "Recording in Progress" : "Tap To Record"
        
        if startRecording && hasPermission {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let recordingName = "recordedVoice.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = URL(string: pathArray.joined(separator: "/"))
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } else if startRecording && !hasPermission {
            print("You did not give permission")
        } else {
            audioRecorder.stop()
            try! session.setActive(false)
        }
    }

    @IBAction func recordAudio(_ sender: Any) {
        manageRecording(true)
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        manageRecording(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioUrl = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioUrl
        }
    }
    
}

