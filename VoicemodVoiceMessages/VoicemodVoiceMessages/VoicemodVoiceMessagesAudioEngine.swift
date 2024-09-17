import Foundation
import SwitchboardSDK
import SwitchboardVoicemod
import SwitchboardRNNoise

class VoicemodVoiceMessagesAudioEngine {
    let audioGraph = SBAudioGraph()
    let audioPlayerNode = SBAudioPlayerNode()
    let recorderNode = SBRecorderNode()
    let voicemodNode = SBVoicemodNode()
    let channelSplitterNode = SBChannelSplitterNode()
    let noiseFilterNode = SBRNNoiseFilterNode()
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()
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
    
    var noiseFilterEnabled: Bool {
        get {
            return noiseFilterNode.isEnabled
        }
        set {
            noiseFilterNode.isEnabled = newValue
        }
    }
    
    init() {
        audioGraph.addNode(audioPlayerNode)
        audioGraph.addNode(recorderNode)
        audioGraph.addNode(voicemodNode)
        audioGraph.addNode(channelSplitterNode)
        audioGraph.addNode(noiseFilterNode)
        audioGraph.addNode(monoToMultiChannelNode)
        
        audioGraph.connect(audioGraph.inputNode, to: recorderNode)
        audioGraph.connect(audioPlayerNode, to: channelSplitterNode)
        audioGraph.connect(channelSplitterNode, to: noiseFilterNode)
        audioGraph.connect(noiseFilterNode, to: voicemodNode)
        audioGraph.connect(voicemodNode, to: monoToMultiChannelNode)
        audioGraph.connect(monoToMultiChannelNode, to: audioGraph.outputNode)

        noiseFilterNode.isEnabled = false
        
        // Even when the audioPlayerNode is not started or has been stopped, silent audio frames are still flowing through the system. The voicemodNode continues to output
        // background sounds for voice changers that have such effects, which is undesirable when the audioPlayerNode is not actively playing. Therefore, we only unmute
        // the voicemodNode when the audioPlayerNode is started or when we are exporting the final file.
        voicemodNode.muteEnabled = true
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
        voicemodNode.muteEnabled = false
        if isRecording {
            stopRecord()
        }
        audioPlayerNode.stop()
        audioPlayerNode.play()
    }
    
    
    func stopPlayer() {
        audioPlayerNode.stop()
        voicemodNode.muteEnabled = true
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
        audioGraphToRender.addNode(channelSplitterNode)
        audioGraphToRender.addNode(noiseFilterNode)
        audioGraphToRender.addNode(monoToMultiChannelNode)
        audioGraphToRender.connect(audioPlayerNode, to: channelSplitterNode)
        audioGraphToRender.connect(channelSplitterNode, to: noiseFilterNode)
        audioGraphToRender.connect(noiseFilterNode, to: voicemodNode)
        audioGraphToRender.connect(voicemodNode, to: monoToMultiChannelNode)
        audioGraphToRender.connect(monoToMultiChannelNode, to: audioGraphToRender.outputNode)
        
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
        voicemodNode.muteEnabled = false
        voicemodNode.offlineModeEnabled = true
        voicemodNode.loadVoice(voicemodNode.getCurrentVoice())
        offlineGraphRenderer.processGraph(audioGraphToRender, withOutputFile: mixedFilePath, withOutputFileCodec: audioFileFormat)
        voicemodNode.offlineModeEnabled = false
        voicemodNode.muteEnabled = true
        audioPlayerNode.stop()
        
        return mixedFilePath
    }
}
