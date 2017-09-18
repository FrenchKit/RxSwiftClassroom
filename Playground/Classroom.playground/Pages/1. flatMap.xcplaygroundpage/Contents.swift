// RxSwift classroom @ FrenchKit 2017
//
// Before using this playground, build the `RxSwift-macOS` scheme
//
// Change the `run` flag of each `example()` to `true` to run it in the playground
//
import RxSwift
import PlaygroundSupport

// ------------------------------------------------------------------------------------
// 1. regular flatMap
// ------------------------------------------------------------------------------------
example(of: "regular flatMap", run: true) {

	_ = sequenceOfInts(count: 5)
		.flatMap { counter in
			fakeNetworkQuery(maxDelay: 0)
				.map { "\(counter): \($0)" }
		}
		.subscribe(onNext: { string in
			print("Fake network query completed: \(string)")
		})
}

// ------------------------------------------------------------------------------------
// 2. Handling errors
// ------------------------------------------------------------------------------------
example(of: "flatMap with random errors", run: false) {

	_ = sequenceOfInts(count: 5)
		.flatMap { counter in
			fakeNetworkQueryWithError(maxDelay: 0)
				.map { "\(counter): \($0)" }
		}
		.subscribe(onNext: { string in
			print("Fake network query completed: \(string)")
		}, onError: { error in
			print("Sequence interrupted with: \(error)")
		})
}

// ------------------------------------------------------------------------------------
// 3. Proper way of handling errors
// ------------------------------------------------------------------------------------
example(of: "flatMap with random errors correctly handled", run: false) {
	_ = sequenceOfInts(count: 5)
		.flatMap { counter in
			fakeNetworkQueryWithError(maxDelay: 0)
				.map { "\(counter): \($0)" }
				.catchError() { _ in .empty() }
		}
		.subscribe(onNext: { string in
			print("Fake network query completed: \(string)")
		}, onError: { error in
			print("Sequence interrupted with: \(error)")
		})
}

// ------------------------------------------------------------------------------------
// 4. Using flatMapLatest
// ------------------------------------------------------------------------------------
example(of: "flatMapLatest", run: false) {
	_ = sequenceOfRandomlyDelayedInts(count: 5, maxDelay: 3.0)
		.flatMapLatest { counter -> Observable<String> in
			print("Starting network request \(counter)")
			return fakeNetworkQuery(maxDelay: 2.0)
				.map { "\(counter): \($0)" }
		}
		.subscribe(onNext: { string in
			print("Fake network query completed: \(string)")
		}, onError: { error in
			print("Sequence interrupted with: \(error)")
		}, onCompleted: {
			print("Sequence compelted")
		})
}

// ------------------------------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------------------------------
func sequenceOfRandomlyDelayedInts(count: Int, maxDelay: Double) -> Observable<Int> {
	let observables = (1 ..< count+1).map {
		Observable.just($0).withRandomDelay(maxDelay)
	}
	return Observable.merge(observables)
}

extension Observable {
	func withRandomDelay(_ maxDelay: Double) -> Observable<E> {
		let delay = randomDelay(maxDelay)
		return self.delay(RxTimeInterval(delay), scheduler: MainScheduler.instance)
	}
}

func sequenceOfInts(count: Int) -> Observable<Int> {
	return Observable<Int>
		.timer(0, period: 0.5, scheduler: MainScheduler.instance)
		.take(count)
}

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

