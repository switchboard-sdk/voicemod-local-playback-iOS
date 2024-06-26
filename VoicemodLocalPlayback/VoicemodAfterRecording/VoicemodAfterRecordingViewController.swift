

import SwitchboardUI
import UIKit
import AVFoundation

class VoicemodAfterRecordingViewController : VStackViewController {
    let example = VoicemodAfterRecordingAudioEngine()

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
        }
                
        self.example.voicemodNode.loadVoice("baby")

        return [
            PickerView(viewController: self, title: "Voice", initialValue: "baby", items: voices, valueChangedHandler: { [weak self] newValue in
                self?.example.voicemodNode.loadVoice(newValue)
            }),
            SwitchView(title: "Bypass", initialValue: example.voicemodNode.bypassEnabled) { [weak self] value in
                self?.example.voicemodNode.bypassEnabled = value
            },
            SwitchView(title: "Mute", initialValue: example.voicemodNode.muteEnabled) { [weak self] value in
                self?.example.voicemodNode.muteEnabled = value
            },
            SwitchView(title: "Background sound", initialValue: example.voicemodNode.backgroundSoundsEnabled) { [weak self] value in
                self?.example.voicemodNode.backgroundSoundsEnabled = value
            },
            ButtonView(title: "Start Recording") {[weak self] buttonView in
                    self!.example.record()
            },
            ButtonView(title: "Stop Recording") { [weak self] buttonView in
                    self!.example.stopRecord()
            },
            ButtonView(title: "Start Playback") { [weak self] buttonView in
                self!.example.play()
            },
            ButtonView(title: "Stop Playback") { [weak self] buttonView in
                self!.example.stopPlayer()
            },
            exportButton,
        ]
    }

    deinit {
        example.stopAudioEngine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        example.startAudioEngine()
    }
}
