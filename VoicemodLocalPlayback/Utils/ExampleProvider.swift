//
//  ExampleProvider.swift
//  SwitchboardPlayground
//
//  Created by Iván Nádor on 2023. 07. 11..
//


import SwitchboardSDK
import SwitchboardVoicemod
import UIKit

enum ExampleProvider {
    static func initialize() {
        SBSwitchboardSDK.initialize(withClientID: switchboardClientID, clientSecret: switchboardClientSecret)
        SBVoicemodExtension.initialize(withClientKey: voicemodClientKey)
    }

    static var examples: [Example]?

    static var exampleGroups: [ExampleGroup]? = [
        ExampleGroup(title: "Voicemod + Switchboard SDK", examples: [
            Example(title: "Record, Voicemod, Playback, Export", viewController: VoicemodAfterRecordingViewController.self),
            Example(title: "Local audio file, Voicemod", viewController: PlayerWithVoicemodViewController.self),
        ])
    ]
}
