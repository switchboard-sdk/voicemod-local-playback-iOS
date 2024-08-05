import Foundation
import SwitchboardSDK
import SwitchboardVoicemod

class VoicemodAfterRecordingAudioEngine {
    let audioGraph = SBAudioGraph()
    let audioPlayerNode = SBAudioPlayerNode()
    let recorderNode = SBRecorderNode()
    let voicemodNode = SBVoicemodNode()
    let audioEngine = SBAudioEngine()
    
    var audioFileFormat: SBCodec = .mp3
    var rawRecordingFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "test_recording"
    }
    
    private var mixedFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "message_with_voicemod.mp3"  }
    
    var isRecording: Bool {
        return recorderNode.isRecording
    }

    var isPlaying: Bool {
        return audioPlayerNode.isPlaying
    }
    
    init() {
        audioGraph.addNode(audioPlayerNode)
        audioGraph.addNode(recorderNode)
        audioGraph.addNode(voicemodNode)
        
        audioGraph.connect(audioGraph.inputNode, to: recorderNode)
        audioGraph.connect(audioPlayerNode, to: voicemodNode)
        audioGraph.connect(voicemodNode, to: audioGraph.outputNode)
    }
    
    func record() {
        audioEngine.stop()
        audioEngine.microphoneEnabled = true
        audioEngine.start(audioGraph)
        stopPlayer()
        recorderNode.start()
    }
    
    func stopRecord() {
        recorderNode.stop(rawRecordingFilePath, withFormat: audioFileFormat)
        audioPlayerNode.load(rawRecordingFilePath, withFormat: audioFileFormat)
        audioEngine.stop()
        audioEngine.microphoneEnabled = false
        audioEngine.start(audioGraph)
    }
    
    func play() {
        if isRecording {
            stopRecord()
        }
        audioPlayerNode.stop()
        audioPlayerNode.play()
    }
    
    func pause() {
        audioPlayerNode.pause()
    }
    
    func stopPlayer() {
        audioPlayerNode.stop()
    }
    
    func stopAudioEngine() {
        audioEngine.stop()
    }
    
    func startAudioEngine() {
        audioEngine.start(audioGraph)
    }
    
    func loadVoiceFilter(voiceFilter: String) {
        voicemodNode.loadVoice(voiceFilter)
    }
    
    func renderMix() -> String {
        let audioGraphToRender = SBAudioGraph()
        audioGraphToRender.addNode(audioPlayerNode)
        audioGraphToRender.addNode(voicemodNode)
        
        audioGraphToRender.connect(audioPlayerNode, to: voicemodNode)
        audioGraphToRender.connect(voicemodNode, to: audioGraphToRender.outputNode)
        
        let sampleRate = audioPlayerNode.sourceSampleRate
        audioPlayerNode.stop()
        audioPlayerNode.play()
        let offlineGraphRenderer = SBOfflineGraphRenderer()
        offlineGraphRenderer.sampleRate =  sampleRate
        // The duration of additional silence (in seconds) added to the end of the audio playback.
        // This padding ensures that the tail of any applied audio effects has sufficient time to decay naturally,
        // preventing abrupt cutoffs and ensuring a smooth and natural fade-out of the effects.
        let effectTailPaddingSeconds = 1.0
        offlineGraphRenderer.maxNumberOfSecondsToRender = audioPlayerNode.duration() + effectTailPaddingSeconds
        voicemodNode.offlineModeEnabled = true
        voicemodNode.loadVoice(voicemodNode.getCurrentVoice())
        offlineGraphRenderer.processGraph(audioGraphToRender, withOutputFile: mixedFilePath, withOutputFileCodec: audioFileFormat)
        voicemodNode.offlineModeEnabled = false
        audioPlayerNode.stop()
        
        return mixedFilePath
    }
}
