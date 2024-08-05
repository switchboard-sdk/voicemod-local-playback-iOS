import SwitchboardUI
import UIKit
import AVFoundation

class VoicemodVoiceMessagesViewController : VStackViewController {
    let example = VoicemodVoiceMessagesAudioEngine()

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

        return [
            PickerView(viewController: self, title: "Voice", initialValue: "baby", items: voices, valueChangedHandler: { [weak self] newValue in
                self?.example.voicemodNode.loadVoice(newValue)
            }),
            SwitchView(title: "Bypass effect", initialValue: example.voicemodNode.bypassEnabled) { [weak self] value in
                self?.example.voicemodNode.bypassEnabled = value
            },
            SwitchView(title: "Mute", initialValue: example.voicemodNode.muteEnabled) { [weak self] value in
                self?.example.voicemodNode.muteEnabled = value
            },
            SwitchView(title: "Background sound (if available)", initialValue: example.voicemodNode.backgroundSoundsEnabled) { [weak self] value in
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
}
