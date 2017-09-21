// RxSwift classroom @ FrenchKit 2017
//
// Before using this playground, build the `RxSwift-macOS` scheme
//
// Change the `run` flag of each `example()` to `true` to run it in the playground
//
import RxSwift
import PlaygroundSupport

// ------------------------------------------------------------------------------------
// 1. simple share()
// ------------------------------------------------------------------------------------
example(of: "share()", run: false) {
	let observable = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
		.share()

	_ = observable.take(10).subscribe(onNext: {
		print("Subscription 1 gets \($0)")
	})

	_ = MainScheduler.instance.scheduleRelative(0, dueTime: 2.5) { _ in
		observable.take(2).subscribe(onNext: {
			print("👀 Subscription 2 gets \($0)")
		})
	}
}

// ------------------------------------------------------------------------------------
// 2. shareReplay(_:)
// ------------------------------------------------------------------------------------
example(of: "shareReplay(_:)", run: false) {
	let observable = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
		.shareReplay(2)

	_ = observable.take(10).subscribe(onNext: {
		print("Subscription 1 gets \($0)")
	})

	_ = MainScheduler.instance.scheduleRelative(0, dueTime: 2.5) { _ in
		observable.take(3).subscribe(onNext: {
			print("👀 Subscription 2 gets \($0)")
		})
	}

	// try it: change the number of items the second subscription takes
	// THEN change the number of items the first subscription takes
}

// ------------------------------------------------------------------------------------
// 3. shareReplayLatestWhileConnected()
// ------------------------------------------------------------------------------------
example(of: "shareReplayLatestWhileConnected()", run: false) {
	let observable = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
		.shareReplayLatestWhileConnected()

	_ = observable.take(5).subscribe(onNext: {
		print("Subscription 1 gets \($0)")
	})

	_ = MainScheduler.instance.scheduleRelative(0, dueTime: 2.5) { _ in
		observable.take(2).subscribe(onNext: {
			print("👀 Subscription 2 gets \($0)")
		})
	}

	// try it: change the number of elements taken by first subscription to 3,
	// then delay more the second subscription
}

// ------------------------------------------------------------------------------------
// 4. share(replay:scope:)
// ------------------------------------------------------------------------------------
example(of: "share(replay:scope:)", run: true) {
	let observable = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
		.share(replay: 3, scope: .whileConnected)

	_ = observable.take(5).subscribe(onNext: {
		print("Subscription 1 gets \($0)")
	})

	_ = MainScheduler.instance.scheduleRelative(0, dueTime: 6) { _ in
		observable.take(5).subscribe(onNext: {
			print("👀 Subscription 2 gets \($0)")
		})
	}

	// try it: change the share scope to `.forever` and observer the
	// results of the second subscription
}


// ------------------------------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------------------------------
func fakeNetworkQuery(maxDelay: Double) -> Observable<String> {
	return Observable
		.just(capitals[capitals.randomIndex])
		.delay(RxTimeInterval(randomDelay(maxDelay)), scheduler: MainScheduler.instance)
}

func fakeNetworkQueryWithError(maxDelay delay: Double) -> Observable<String> {
	if rand(4) == 0 {
		return Observable<String>
			.error(SomeError.failed)
			.delay(RxTimeInterval(randomDelay(delay)), scheduler: MainScheduler.instance)
	}
	return fakeNetworkQuery(maxDelay: delay)
}

PlaygroundPage.current.needsIndefiniteExecution = true
