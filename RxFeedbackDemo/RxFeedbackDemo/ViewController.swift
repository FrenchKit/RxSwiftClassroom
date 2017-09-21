//
//  ViewController.swift
//  RxFeedbackDemo
//
//  Created by Florent Pillet on 18/09/2017.
//  Copyright © 2017 FrenchKit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

class ViewController: UIViewController {

	@IBOutlet weak var playbackView: UIImageView!
	@IBOutlet weak var playStopButton: UIButton!
	@IBOutlet weak var pauseResumeButton: UIButton!

	let disposeBag = DisposeBag()
	let playbackState = ReplaySubject<PlaybackState>.create(bufferSize: 1)

	let playlist: [(String,Double)] = [
		("lorempixel.jpg", 7.0),
		("lorempixel-1.jpg", 3.0),
		("lorempixel-2.jpg", 5.0),
		("lorempixel-3.jpg", 10.0)
	]

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		startWatchingPlayback()
		startRunningPlayback()
	}

	func startWatchingPlayback() {
		playbackState.subscribe(onNext: { [weak self] state in
			guard let this = self else { return }
			switch state {
			case .stopped:
				this.playbackView.image = nil

			case .playing(let mediaIndex, _):
				this.playbackView.alpha = 1.0
				this.playbackView.image = UIImage(named: this.playlist[mediaIndex].0)

			case .paused:
				this.playbackView.alpha = 0.5
			}
		})
			.disposed(by: disposeBag)

	}
	
	func startRunningPlayback() {
		let bindUI: (ObservableSchedulerContext<PlaybackState>) -> Observable<PlaybackCommand> =
			UI.bind(self) { this, state -> UI.Bindings<PlaybackCommand> in
				// subscriptions are observers of state which modify the UI
				let observers: [Disposable] = [
					state.map { $0.isStarted ? "Stop" : "Play" }
						.bind(to: this.playStopButton.rx.title()),
					state.map { $0.isPaused ? "Resume" : "Pause" }
						.bind(to: this.pauseResumeButton.rx.title()),
					state.map { $0.isStarted }
						.bind(to: this.pauseResumeButton.rx.isEnabled)
				]

				// events are observers of UI which provide new commands
				let emitters: [Observable<PlaybackCommand>] = [
					this.playStopButton.rx.tap.withLatestFrom(state)
						.map { $0.isStarted ? .stop : .play(0) },

					this.pauseResumeButton.rx.tap.withLatestFrom(state)
						.map { state in
							if case .playing(_,_) = state {
								return .pause
							}
							return .resume
					}
				]
				return UI.Bindings(subscriptions: observers, events: emitters)
		}

		Observable.system(
			// the initial state of our state machine
			initialState: PlaybackState.stopped,

			// reduce each command to a new state
			reduce: reducePlaybackStateFromCommand,

			// run state machin on main scheduler
			scheduler: MainScheduler.instance,

			// list of feedbacks (command generators)
			scheduledFeedback: [
				// UI bindings responding to user taps
				bindUI,

				// Playback command generator that runs playback and loops on playlists
				generateCommandsFromPlaybackStates
			]
			)
			.distinctUntilChanged()
			.bind(to: playbackState)
			.disposed(by: disposeBag)
	}

	func reducePlaybackStateFromCommand(state: PlaybackState, command: PlaybackCommand) -> PlaybackState {
		switch command {
		case .play(let index):
			return .playing(index, Date(timeIntervalSinceNow: TimeInterval(playlist[index].1)))

		case .pause:
			if case .playing(let index, let endDate) = state {
				return .paused(index, endDate.timeIntervalSinceNow)
			}
			return state

		case .resume:
			if case .paused(let index, let remaining) = state {
				return .playing(index, Date(timeIntervalSinceNow: remaining))
			}
			return state

		case .stop:
			return .stopped
		}
	}

	func generateCommandsFromPlaybackStates(states: ObservableSchedulerContext<PlaybackState>) -> Observable<PlaybackCommand> {
		return states.source.flatMapLatest {
			[weak self] (state: PlaybackState) -> Observable<PlaybackCommand> in
			
			guard let this = self else { return .empty() }

			switch state {

			case .playing(let index, let endDate):
				// every time we switch to a new "playing" state, start a timer
				// towards the end of the media to play the next media,
				// otherwise cancel previous timer.
				let nextIndex = (index + 1) % this.playlist.count
				let remaining = endDate.timeIntervalSinceNow
				return Observable<Int>
					.timer(remaining, scheduler: MainScheduler.instance)
					.map { _ -> PlaybackCommand in
						.play(nextIndex)
				}

			default:
				return .empty()
			}
		}
	}
}


