//
//  PlaybackState.swift
//  RxFeedbackDemo
//
//  Created by Florent Pillet on 18/09/2017.
//  Copyright © 2017 FrenchKit. All rights reserved.
//

import Foundation

//
// PlaybackState: the possible states of our player state machine
//
enum PlaybackState {
	case stopped
	case playing(Int,Date)		// media index, end date
	case paused(Int,Double)		// media index, remaining seconds
}

extension PlaybackState: Equatable {
	var isPaused: Bool {
		if case .paused(_,_) = self { return true }
		return false
	}

	var isStarted: Bool {
		if case .stopped = self { return false }
		return true
	}

	// Implement `Equatable` for `distinctUntilChanged()` to work
	static func ==(lhs: PlaybackState, rhs: PlaybackState) -> Bool {
		switch (lhs,rhs) {
		case (.stopped, .stopped):
			return true
		case (.playing(let lindex, let ldate), .playing(let rindex, let rdate)):
			return lindex == rindex && ldate == rdate
		case (.paused(let lindex, let lremaining), .paused(let rindex, let rremaining)):
			return lindex == rindex && lremaining == rremaining
		default:
			return false
		}
	}
}
