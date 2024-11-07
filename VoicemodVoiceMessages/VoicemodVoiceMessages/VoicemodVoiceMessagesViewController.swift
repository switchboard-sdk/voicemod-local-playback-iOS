import SwitchboardUI
import UIKit
import AVFoundation
import SwitchboardVoicemod


class VoicemodVoiceMessagesViewController : VStackViewController {
    let example = VoicemodVoiceMessagesAudioEngine()
    var toggleRecordingButton: ButtonView!
    var togglePlaybackButton: ButtonView!
    var exportButton: ButtonView!
    var loadingIndicator: UIActivityIndicatorView!

    var timer: Timer?


    override var views: [UIView] {
        
        exportButton = ButtonView(title: "Share voice message") { [weak self] _ in
            guard let self = self else { return }
                        
            runExportOnBackgroundThread()
        }
        
        exportButton.button.setButtonStyle(.active)
        exportButton.button.isEnabled = false
                
        self.example.voicemodNode.loadVoice("baby")
        
        toggleRecordingButton = ButtonView(title: "Record voice message") {[weak self] buttonView in
            if (!self!.example.isRecording) {
                self!.example.record()
                buttonView.button.setTitle("Stop recording", for: .normal)
                self!.togglePlaybackButton.button.isEnabled = false
                self!.exportButton.button.isEnabled = false

            } else {
                self!.example.stopRecord()
                buttonView.button.setTitle("Record voice message", for: .normal)
                self!.togglePlaybackButton.button.isEnabled = true
                self!.exportButton.button.isEnabled = true
            }
        }
        
        toggleRecordingButton.button.setButtonStyle(.active)
        
        togglePlaybackButton = ButtonView(title: "Playback voice message") { [weak self] buttonView in
            if (!self!.example.isPlaying) {
                self!.example.play()
                self!.startTimer()
                buttonView.button.setTitle("Stop Playback", for: .normal)
                self!.toggleRecordingButton.button.isEnabled = false
            } else {
                self!.stopPlayback()
            }
        }
        
        togglePlaybackButton.button.setButtonStyle(.active)
        togglePlaybackButton.button.isEnabled = false


        return [
            PickerView(viewController: self, title: "Voice", initialValue: "baby", items: SBVoicemodExtension.listVoices(), valueChangedHandler: { [weak self] newValue in
                self?.example.voicemodNode.loadVoice(newValue)
            }),
            SwitchView(title: "Background sound (if available)", initialValue: example.voicemodNode.backgroundSoundsEnabled) { [weak self] value in
                self?.example.voicemodNode.backgroundSoundsEnabled = value
            },
            SwitchView(title: "Bypass effect", initialValue: example.voicemodNode.bypassEnabled) { [weak self] value in
                self?.example.voicemodNode.bypassEnabled = value
            },
            SwitchView(title: "Noise filter", initialValue: example.noiseFilterEnabled) { [weak self] value in
                self?.example.noiseFilterEnabled = value
            },
            toggleRecordingButton,
            togglePlaybackButton,
            TextLabelView(text: ""), // empty line placeholder
            exportButton
        ]
    }

    deinit {
        example.stopAudioEngine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        example.startAudioEngine()
        
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateIsPlayingUI), userInfo: nil, repeats: true)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateIsPlayingUI() {
        if (!example.isPlaying) {
            stopPlayback()
        }
    }
    
    func stopPlayback() {
        example.stopPlayer()
        stopTimer()
        togglePlaybackButton.button.setTitle("Playback voice message", for: .normal)
        toggleRecordingButton.button.isEnabled = true
    }
    
    // faster
    func runExportOnUIThread() {
        
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
    }
    
    // slower
    func runExportOnBackgroundThread() {
        
        self.example.stopAudioEngine()
        self.loadingIndicator.startAnimating()

        DispatchQueue.global(qos: .background).async {
            let renderedMix = self.example.renderMix()
            guard let fileURL = URL(string: renderedMix) else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.example.startAudioEngine()
                }
                return
            }
            DispatchQueue.main.async {
                let activityItems: [URL] = [fileURL]
                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
                self.example.startAudioEngine()
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}
