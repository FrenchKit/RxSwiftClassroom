//
//  PlaybackCommand.swift
//  RxFeedbackDemo
//
//  Created by Florent Pillet on 18/09/2017.
//  Copyright © 2017 FrenchKit. All rights reserved.
//

import Foundation

//
// PlaybackCommand: the commands that trigger new PlaybackState
//
enum PlaybackCommand {
	case play(Int)
	case pause
	case resume
	case stop
}
