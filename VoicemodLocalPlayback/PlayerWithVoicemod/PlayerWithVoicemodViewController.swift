import SwitchboardUI
import UIKit
import AVFoundation


class PlayerWithVoicemodViewController: VStackViewController {
    let example = PlayerWithVoicemodExample()
    let audioFiles: [URL] = [
        Bundle.main.url(forResource: "stereo-voice", withExtension: "wav")!,
        Bundle.main.url(forResource: "Female-Vocal", withExtension: "wav")!,
    ]

    override var views: [UIView] {
        let defaultAudioFile = Bundle.main.url(forResource: "Female-Vocal", withExtension: "wav")!
        example.load(url: defaultAudioFile.absoluteString)

        let exportButton = ButtonView(title: "Export Processed File") { [weak self] _ in
            guard let self = self else { return }
            guard let fileURL = URL(string: self.example.recordingFilePath) else {
                return
            }
            let activityItems: [URL] = [fileURL]
            let activityViewController = UIActivityViewController(activityItems: activityItems,
                                                                  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        exportButton.button.isEnabled = false

        let recordingButton = ButtonView(title: "Start Recording") { [weak self] buttonView in
            guard let self = self else { return }
            if self.example.isRecording {
                self.example.stopRecording()
                buttonView.button.setTitle("Start Recording", for: .normal)
                exportButton.button.isEnabled = true
            } else {
                self.example.startRecording()
                buttonView.button.setTitle("Stop Recording", for: .normal)
            }
        }

        return [
            AudioFileView(
                delegate: self,
                title: "Audio File",
                initialValue: defaultAudioFile,
                audioFiles: audioFiles,
                valueChangedHandler: { [weak self] fileURL in
                    self?.example.load(url: fileURL.absoluteString)
                    self?.example.startPlayer()
                }
            ),
            PickerView(viewController: self, title: "Voice", initialValue: "baby", items: voices, valueChangedHandler: { [weak self] newValue in
                self?.example.voicemodNode.loadVoice(newValue)
            }),
            SwitchView(title: "Bypass", initialValue: example.voicemodNode.bypassEnabled) { [weak self] value in
                self?.example.voicemodNode.bypassEnabled = value
            },
            SwitchView(title: "Mute", initialValue: example.voicemodNode.muteEnabled) { [weak self] value in
                self?.example.voicemodNode.muteEnabled = value
            },
//            SwitchView(title: "Background sound", initialValue: example.voicemodNode.backgroundSoundsEnabled) { [weak self] value in
//                self?.example.voicemodNode.backgroundSoundsEnabled = value
//            },
            ButtonView(title: "Start") { [weak self] buttonView in
                if (self!.example.isPlaying) {
                    self?.example.stopPlayer()
                    buttonView.button.setTitle("Start", for: .normal)
                } else {
                    self?.example.startPlayer()
                    buttonView.button.setTitle("Stop", for: .normal)
                }
            },
            recordingButton,
            exportButton,
        ]
    }

    deinit {
        example.stopEngine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        example.startEngine()
    }
}
