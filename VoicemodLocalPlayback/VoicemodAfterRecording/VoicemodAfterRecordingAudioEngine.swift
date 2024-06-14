//
//  VoicemodAfterRecordingAudioEngine.swift
//  VoicemodLocalPlayback
//
//  Created by Banto Balazs on 12/06/2024.
//

import Foundation
import SwitchboardSDK
import SwitchboardVoicemod

class VoicemodAfterRecordingAudioEngine {
    let audioGraph = SBAudioGraph()
    let audioPlayerNode = SBAudioPlayerNode()
    let recorderNode = SBRecorderNode()
    let voicemodNode = SBVoicemodNode()
    let audioEngine = SBAudioEngine()
    let offlineGraphRenderer = SBOfflineGraphRenderer()

    
    var audioFileFormat: SBCodec = .mp3
    var rawRecordingFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "test_recording"
    }
    
    private var mixedFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "mix.mp3"  }
    
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
        
        audioEngine.microphoneEnabled = true

    }
    
    func record() {
        stopPlayer()
        recorderNode.start()
    }
    
    func stopRecord() {
        recorderNode.stop(rawRecordingFilePath, withFormat: .wav)
        audioPlayerNode.load(rawRecordingFilePath)
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
        audioPlayerNode.position = 0
        audioPlayerNode.play()
        offlineGraphRenderer.sampleRate =  sampleRate
        offlineGraphRenderer.maxNumberOfSecondsToRender = audioPlayerNode.duration()
        offlineGraphRenderer.processGraph(audioGraphToRender, withOutputFile: mixedFilePath, withOutputFileCodec: audioFileFormat)
        audioPlayerNode.stop()
        
        return mixedFilePath
    }
}
