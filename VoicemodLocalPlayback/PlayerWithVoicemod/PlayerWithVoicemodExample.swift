//
//  PlayerWithVoicemodExample.swift
//  SwitchboardPinPointSampleApp
//
//  Created by Balázs Kiss on 2022. 11. 24..
//

import SwitchboardSDK
import SwitchboardVoicemod

class PlayerWithVoicemodExample {
    let audioGraph = SBAudioGraph()
    let recorderNode: SBRecorderNode
    let audioPlayerNode = SBAudioPlayerNode()
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()
    let voicemodNode = SBVoicemodNode()
    let splitterNode = SBBusSplitterNode()
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()
    let audioEngine = SBAudioEngine()

    var recordingFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "noise_filter.wav"
    }

    var isRecording: Bool {
        return recorderNode.isRecording
    }
    
    var isPlaying: Bool {
        return audioPlayerNode.isPlaying
    }

    init() {
        recorderNode = SBRecorderNode(
            sampleRate: 48000,
            numberOfChannels: 1
        )
        audioPlayerNode.isLoopingEnabled = true

        voicemodNode.loadVoice("baby")

        audioGraph.addNode(audioPlayerNode)
        audioGraph.addNode(multiChannelToMonoNode)
        audioGraph.addNode(voicemodNode)
        audioGraph.addNode(splitterNode)
        audioGraph.addNode(monoToMultiChannelNode)
        audioGraph.addNode(recorderNode)

        audioGraph.connect(audioPlayerNode, to: multiChannelToMonoNode)
        audioGraph.connect(multiChannelToMonoNode, to: voicemodNode)
        audioGraph.connect(voicemodNode, to: splitterNode)
        audioGraph.connect(splitterNode, to: recorderNode)
        audioGraph.connect(splitterNode, to: monoToMultiChannelNode)
        audioGraph.connect(monoToMultiChannelNode, to: audioGraph.outputNode)
    }

    func startEngine() {
        audioEngine.start(audioGraph)
    }

    func stopEngine() {
        audioPlayerNode.stop()
        audioEngine.stop()
    }

    func load(url: String) {
        audioPlayerNode.load(url)
    }

    func startPlayer() {
        audioPlayerNode.play()
    }
    
    func stopPlayer() {
        audioPlayerNode.stop()
    }

    func startRecording() {
        recorderNode.start()
    }

    func stopRecording() {
        recorderNode.stop(recordingFilePath, withFormat: .wav)
    }
}
