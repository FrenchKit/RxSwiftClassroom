## RxSwift Classroom

### FrenchKit 2017

---
## Agenda

* Setup
* Taming `flatMap()`
* Learning to `share()`
* Introducing `RxFeedback`

---
## Prepare for the class

* Clone `https://github.com/FrenchKit/RxSwiftClassroom`
* Open `Playground/Playground.xcworkspace`
* Build `RxSwift-macOS` scheme

---
## Taming flatMap

---
### Taming flatMap

Use `flatMap` whenever `map`ing to a single value is not enough

Most crucial and useful operator to know inside out

---
### 1. Regular flatMap

Turn input into a network request

---
### 2. Errors

Beware errors emitted by inner sequences

---
### 3. Errors, the right way

Catching errors _inside_ `flatMap` prevents breaking the overall sequence

---
### 4. Using flatMapLatest

When you only want to see the freshest results

---
## Learning to share

---
### Expensive observables

* Computation (i.e. preparing thuumbnails)
* Network requests
* Side effects

---
### Forms of share

* `share()`
* `shareReplay(_:)`
* `shareReplayLatestWhileConnected()`
* `share(replay:scope:)`

---
### Standard `share()`

* Subscribes to inner observable with first observer
* Unsubscribes when no more observers
* ⚠️ Side effect: zero observers = next observer restarts inner subscription

---
### `shareReplay`

* Replays the last N emitted elements
* Event if # subscribers fell to zero
* Experiment with the playground!

---
### `shareReplayLatestWhileConnected`

* Replays the last emitted element
* Clears buffer when no more subscribers

---
### `share(replay:scope:)`

* Most flexible variant
* Control whether buffering 'sticks' when subscribers drop to zero

---
## Introducing RxFeedback

---
