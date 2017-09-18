//
//  FeedbackLoops.swift
//  RxFeedback
//
//  Created by Krunoslav Zaher on 5/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control: Equatable, Event>(
        query: @escaping (State) -> Control?,
        effects: @escaping (Control) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 == $1 }
            .flatMapLatest { (results: Control?) -> Observable<Event> in
                guard let results = results else {
                    return Observable<Event>.empty()
                }

                return effects(results)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
var i = 0;
public func react<State, Control: Equatable, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Driver<Event>
) -> (Driver<State>) -> Driver<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 == $1 }
            .flatMapLatest { (results: Control?) -> Driver<Event> in
                guard let results = results else {
                    return Driver<Event>.empty()
                }

                i += 1
                return effects(results)
                    .enqueue()
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Observable<Event>
) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 != nil }
            .flatMapLatest { (results: Control?) -> Observable<Event> in
                guard let results = results else {
                    return Observable<Event>.empty()
                }

                return effects(results)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Driver<Event>
) -> (Driver<State>) -> Driver<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 != nil }
            .flatMapLatest { (results: Control?) -> Driver<Event> in
                guard let results = results else {
                    return Driver<Event>.empty()
                }

                return effects(results)
                    .enqueue()
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control: Hashable, Event>(
    query: @escaping (State) -> Set<Control>,
    effects: @escaping (Control) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        let query = state.map(query)

        let newQueries = Observable.zip(query, query.startWith(Set())) { $0.subtracting($1) }

        return newQueries.flatMap { controls in
            return Observable.merge(controls.map { control -> Observable<Event> in
                return query.filter { !$0.contains(control) }
                    .map { _ in Observable<Event>.empty() }
                    .startWith(effects(control).enqueue(state.scheduler))
                    .switchLatest()
            })
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs events.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control: Hashable, Event>(
    query: @escaping (State) -> Set<Control>,
    effects: @escaping (Control) -> Driver<Event>
    ) -> (Driver<State>) -> Driver<Event> {
    return { state in
        let query = state.map(query)

        let newQueries = Driver.zip(query, query.startWith(Set())) { $0.subtracting($1) }

        return newQueries.flatMap { controls in
            return Driver.merge(controls.map { control -> Driver<Event> in
                i += 1
                return query.filter { !$0.contains(control) }
                    .map { _ in Driver<Event>.empty() }
                    .startWith(effects(control).enqueue())
                    .switchLatest()
            })
        }
    }
}


extension Observable {
    func enqueue(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return self
            // observe on is here because results should be cancelable
            .observeOn(scheduler)
            // subscribe on is here because side-effects also need to be cancelable
            // (smooths out any glitches caused by start-cancel immediatelly)
            .subscribeOn(scheduler)
    }
}

extension SharedSequence {
    func enqueue() -> SharedSequence<S, Element> {
        return self.asObservable()
            // observe on is here because results should be cancelable
            .observeOn(S.scheduler.async)
            // subscribe on is here because side-effects also need to be cancelable
            // (smooths out any glitches caused by start-cancel immediatelly)
            .subscribeOn(S.scheduler.async)
            .asSharedSequence(onErrorDriveWith: .empty())
    }
}
