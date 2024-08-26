import SwitchboardUI
import UIKit
import AVFoundation

class VoicemodVoiceMessagesViewController : VStackViewController {
    let example = VoicemodVoiceMessagesAudioEngine()
    var toggleRecordingButton: ButtonView!
    var togglePlaybackButton: ButtonView!
    var timer: Timer?


    override var views: [UIView] {
        
        let exportButton = ButtonView(title: "Export Processed File") { [weak self] _ in
            guard let self = self else { return }
            self.example.stopAudioEngine()
            
            guard let fileURL = URL(string: self.example.renderMix()) else {
                return
            }
            let activityItems: [URL] = [fileURL]
            let activityViewController = UIActivityViewController(activityItems: activityItems,
                                                                    applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
            self.example.startAudioEngine()

            // NOTE: use this code to run the render on a background thread. Running it on the background thread will be slower by a
            // a factor of ~3
//            DispatchQueue.global(qos: .background).async {
//                let renderedMix = self.example.renderMix()
//                guard let fileURL = URL(string: renderedMix) else {
//                    DispatchQueue.main.async {
//                        self.example.startAudioEngine()
//                    }
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    let activityItems: [URL] = [fileURL]
//                    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//                    activityViewController.popoverPresentationController?.sourceView = self.view
//                    self.present(activityViewController, animated: true, completion: nil)
//                    self.example.startAudioEngine()
//                }
//            }
        }
                
        self.example.voicemodNode.loadVoice("baby")
        
        toggleRecordingButton = ButtonView(title: "Start Recording") {[weak self] buttonView in
            if (!self!.example.isRecording) {
                self!.example.record()
                buttonView.button.setTitle("Stop Recording", for: .normal)
                self!.togglePlaybackButton.button.isEnabled = false
            } else {
                self!.example.stopRecord()
                buttonView.button.setTitle("Start Recording", for: .normal)
                self!.togglePlaybackButton.button.isEnabled = true
            }
        }
        
        toggleRecordingButton.button.setButtonStyle(.active)
        
        togglePlaybackButton = ButtonView(title: "Start Playback") { [weak self] buttonView in
            if (!self!.example.isPlaying) {
                self!.example.play()
                self!.startTimer()
                buttonView.button.setTitle("Stop Playback", for: .normal)
                self!.toggleRecordingButton.button.isEnabled = false
            } else {
                self!.example.stopPlayer()
                self!.stopTimer()
                buttonView.button.setTitle("Start Playback", for: .normal)
                self!.toggleRecordingButton.button.isEnabled = true
            }
        }
        
        togglePlaybackButton.button.setButtonStyle(.active)

        return [
            PickerView(viewController: self, title: "Voice", initialValue: "baby", items: voices, valueChangedHandler: { [weak self] newValue in
                self?.example.voicemodNode.loadVoice(newValue)
            }),
            SwitchView(title: "Bypass effect", initialValue: example.voicemodNode.bypassEnabled) { [weak self] value in
                self?.example.voicemodNode.bypassEnabled = value
            },
            SwitchView(title: "Background sound (if available)", initialValue: example.voicemodNode.backgroundSoundsEnabled) { [weak self] value in
                self?.example.voicemodNode.backgroundSoundsEnabled = value
            },
            toggleRecordingButton,
            togglePlaybackButton,
            exportButton,
            TextLabelView(text: "Exporting may take a few seconds...")
            
        ]
    }

    deinit {
        example.stopAudioEngine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        example.startAudioEngine()
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateIsPlayingUI), userInfo: nil, repeats: true)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateIsPlayingUI() {
        if (!example.isPlaying) {
            togglePlaybackButton.button.setTitle("Start Playback", for: .normal)
            toggleRecordingButton.button.isEnabled = true
        }
    }
}
