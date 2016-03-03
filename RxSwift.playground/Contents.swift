//: Please build the scheme 'RxSwiftPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import RxSwift

func exampleOf(description: String, action: Void -> Void) {
  printExampleOf(description)
  action()
}

func printExampleOf(description: String) {
  print("\n--- Example of:", description, "---")
}

enum Error: ErrorType { case A }

exampleOf("empty") {
  _ = Observable<Int>.empty().subscribe { print($0) }
}

exampleOf("never") {
  _ = Observable<Int>.never().subscribe { print($0) }
}

exampleOf("just") {
  _ = Observable.just(32).subscribe { print($0) }
}

exampleOf("of") {
  _ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9).subscribe { print($0) }
}

exampleOf("toObservable") {
  _ = [1, 2, 3].toObservable().subscribe { print($0) }
}

exampleOf("create") {
  let myJust: Int -> Observable<Int> = { element in
    return Observable.create {
      $0.onNext(element)
      $0.on(.Completed)
      return NopDisposable.instance
    }
  }
  
  _ = myJust(5).subscribe { print($0) }
}

exampleOf("generate") {
  _ = Observable.generate(
    initialState: 0,
    condition: { $0 < 3 },
    iterate: { $0 + 1 }
    ).subscribe { print($0) }
}

exampleOf("error") {
  _ = Observable<Int>.error(Error.A).subscribe { print($0) }
}

exampleOf("deferred") {
  let deferredSequence: Observable<Int> = Observable.deferred {
    print("Creating...")
    return Observable.create {
      print("Emitting...")
      $0.onNext(0)
      $0.onNext(1)
      $0.onNext(2)
      return NopDisposable.instance
    }
  }
  
  _ = deferredSequence.subscribe { print($0) }
  _ = deferredSequence.subscribe { print($0) }
}

// TODO: rx_observe, rx_tap, rx_notification

func addSubscriptionToSubject<O: ObservableType>(subject: O, withSequenceName sequenceName: String) -> Disposable {
  return subject.subscribe { print("Sequence:", sequenceName, "\nEvent:", $0) }
}

exampleOf("PublishSubject") {
  let disposeBag = DisposeBag()
  let subject = PublishSubject<String>()
  addSubscriptionToSubject(subject, withSequenceName: "1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  addSubscriptionToSubject(subject, withSequenceName: "2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
}

exampleOf("ReplaySubject") {
  let disposeBag = DisposeBag()
  let subject = ReplaySubject<String>.create(bufferSize: 1)
  addSubscriptionToSubject(subject, withSequenceName: "1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  addSubscriptionToSubject(subject, withSequenceName: "2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
}

exampleOf("BehaviorSubject") {
  let disposeBag = DisposeBag()
  let subject = BehaviorSubject(value: "z")
  addSubscriptionToSubject(subject, withSequenceName: "1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  addSubscriptionToSubject(subject, withSequenceName: "2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
  subject.on(.Completed)
}

exampleOf("Variable") {
  let disposeBag = DisposeBag()
  let variable = Variable("z")
  addSubscriptionToSubject(variable.asObservable(), withSequenceName: "1").addDisposableTo(disposeBag)
  variable.value = "a"
  variable.value = "b"
  addSubscriptionToSubject(variable.asObservable(), withSequenceName: "2").addDisposableTo(disposeBag)
  variable.value = "c"
  variable.value = "d"
}

exampleOf("map") {
  _ = Observable.of(1, 2, 3).map { $0 * 2 }.subscribe { print($0) }
}

exampleOf("flatMap") {
  let sequenceString = Observable.of("A", "B", "C", "D", "E", "F", "--")
  
  _ = Observable.of(1, 2, 3)
    .flatMap { i -> Observable<String> in
      print("Sequence:", i)
      return sequenceString
    }
    .subscribe { print($0) }
}

exampleOf("scan") {
  _ = Observable.of(0, 1, 2, 3, 4, 5)
    .scan(0) {
      $0 + $1
    }
    .subscribe { print($0) }
}

exampleOf("filter") {
  _ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    .filter { $0 % 2 == 0 }
    .subscribe { print($0) }
}

exampleOf("distinctUntilChanged") {
  _ = Observable.of(1, 2, 2, 3, 3, 3, 1)
    .distinctUntilChanged()
    .subscribe { print($0) }
}

exampleOf("take") {
  _ = Observable.of(0, 1, 2, 3, 4, 5)
    .take(3)
    .subscribe { print($0) }
}

exampleOf("startWith") {
  _ = Observable.of(4, 5, 6)
    .startWith(3)
    .startWith(1, 2)
    .subscribe { print($0) }
}

exampleOf("combineLatest1") {
  let integerSubject = PublishSubject<Int>()
  let stringSubject = PublishSubject<String>()
  
  _ = Observable.combineLatest(integerSubject, stringSubject) {
    "\($0) \($1)"
    }.subscribe { print($0) }
  
  integerSubject.onNext(1)
  stringSubject.onNext("A")
  
  integerSubject.onNext(2)
  stringSubject.onNext("B")
  
  stringSubject.onNext("C")
  integerSubject.onNext(3)
}

exampleOf("combineLatest2") {
  let integerObservableA = Observable.just(2)
  let integerObservableB = Observable.of(0, 1, 2, 3)
  
  _ = Observable.combineLatest(integerObservableA, integerObservableB) {
    $0 * $1
    }.subscribe { print($0) }
}

exampleOf("combineLatest3") {
  let integerObservableA = Observable.just(2)
  let integerObservableB = Observable.of(0, 1, 2, 3)
  let integerObservableC = Observable.of(0, 1, 2, 3, 4)
  
  _ = Observable.combineLatest(integerObservableA, integerObservableB, integerObservableC) {
//    print($0, $1, $2) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    ($0 + $1) * $2
    }.subscribe { print($0) }
}

exampleOf("combineLatest4") {
  let integerObservable = Observable.just(2)
  let stringObservable = Observable.just("a")
  
  _ = Observable.combineLatest(integerObservable, stringObservable) {
    String($0) + $1
    }.subscribe { print($0) }
}

exampleOf("combineLatest5") {
  let integerObservableA = Observable.just(2)
  let integerObservableB = Observable.of(0, 1, 2, 3)
  let integerObservableC = Observable.of(0, 1, 2, 3, 4)
  
  _ = [integerObservableA, integerObservableB, integerObservableC].combineLatest {
//    print($0[0], $0[1], $0[2]) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    Int(($0[0] + $0[1]) * $0[2])
    }.subscribe { print($0) }
}

exampleOf("zip") {
  let stringSubject = PublishSubject<String>()
  let integerSubject = PublishSubject<Int>()
  
  _ = Observable.zip(stringSubject, integerSubject) {
    "\($0) \($1)"
    }.subscribe { print($0) }
  
  stringSubject.onNext("A")
  integerSubject.onNext(1)
  stringSubject.onNext("B")
  stringSubject.onNext("C")
  integerSubject.onNext(2)
  integerSubject.onNext(3)
}

exampleOf("merge1") {
  let integerSubject1 = PublishSubject<Int>()
  let integerSubject2 = PublishSubject<Int>()
  
  _ = Observable.of(integerSubject1, integerSubject2)
    .merge()
    .subscribeNext { print($0) }
  
  integerSubject1.onNext(20)
  integerSubject1.onNext(40)
  integerSubject1.onNext(60)
  integerSubject2.onNext(1)
  integerSubject1.onNext(80)
  integerSubject1.onNext(100)
  integerSubject2.onNext(2)
}

exampleOf("merge2") {
  let integerSubject1 = PublishSubject<Int>()
  let integerSubject2 = PublishSubject<Int>()
  let integerSubject3 = PublishSubject<Int>()
  
  _ = Observable.of(integerSubject1, integerSubject2, integerSubject3)
    .merge(maxConcurrent: 2)
    .subscribeNext { print($0) }
  
  integerSubject1.onNext(20)
  integerSubject1.onNext(40)
  integerSubject2.onNext(2)
  integerSubject1.onNext(60)
  integerSubject3.onNext(3)
  integerSubject1.onNext(80)
  integerSubject1.onNext(100)
  integerSubject2.onNext(2)
}

exampleOf("switchLatest") {
  let variable1 = Variable(0)
  let variable2 = Variable(200)
  let variable3 = Variable(variable1.asObservable()) // Observable<Observable<Int>>
  
  _ = variable3
    .asObservable()
    .switchLatest()
    .subscribe { print($0) }
  
  variable1.value = 1
  variable1.value = 2
  variable1.value = 3
  
  variable3.value = variable2.asObservable()
  variable2.value = 201
  
  variable1.value = 4
}

exampleOf("catchError1") {
  let sequenceThatFails = PublishSubject<Int>()
  let recoverySequence = Observable.of(100, 200, 300)
  
  _ = sequenceThatFails
    .catchError { _ in return recoverySequence }
    .subscribe { print($0) }
  
  sequenceThatFails.onNext(1)
  sequenceThatFails.onNext(2)
  sequenceThatFails.onError(Error.A)
}

exampleOf("catchError2") {
  let sequenceThatFails = PublishSubject<Int>()
  _ = sequenceThatFails
    .catchErrorJustReturn(100)
    .subscribe { print($0) }
  
  sequenceThatFails.onNext(1)
  sequenceThatFails.onNext(2)
  sequenceThatFails.onError(Error.A)
}

exampleOf("retry") {
  var count = 0
  let sequence = Observable<Int>.create {
    $0.onNext(0)
    $0.onNext(1)
    $0.onNext(2)
    
    if count < 2 {
      print(count)
      $0.onError(Error.A)
      count += 1
    }
    
    $0.onNext(3)
    $0.onNext(4)
    $0.onCompleted()
    
    return NopDisposable.instance
  }
  
  _ = sequence.retry().subscribe { print($0) }
}

exampleOf("subscribe") {
  let sequence = PublishSubject<Int>()
  _ = sequence.subscribe { print($0) }
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeNext") {
  let sequence = PublishSubject<Int>()
  _ = sequence.subscribeNext { print($0) }
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeCompleted") {
  let sequence = PublishSubject<Int>()
  
//  _ = sequence.subscribeNext { print($0) }
  _ = sequence.subscribeCompleted { print("Done!") }
  
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeError") {
  let sequence = PublishSubject<Int>()
  _ = sequence.subscribeError { print("Error:", $0) }
  sequence.onNext(1)
  sequence.onError(Error.A)
}

exampleOf("doOn/doOnNext") {
  let sequence = PublishSubject<Int>()
  
  _ = sequence
    .doOnNext { print("Intercepted event:", $0) }
    .subscribeNext { print($0) }
  
  _ = sequence.subscribeCompleted { print("Done!") }
  
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("takeUntil") {
  let sequence = PublishSubject<Int>()
  let haltSequence = PublishSubject<String>()
  
  _ = sequence
    .takeUntil(haltSequence)
    .subscribeNext { print($0) }
  
  _ = haltSequence.subscribeNext { print($0) }
  
//  haltSequence.onNext("Hello")
  sequence.onNext(1)
  sequence.onNext(2)
  haltSequence.onNext("World")
  sequence.onNext(3)
}

exampleOf("takeWhile") {
  let sequence = PublishSubject<Int>()
  
  _ = sequence
    .takeWhile { $0 < 3 }
    .subscribeNext { print($0) }
  
  sequence.onNext(1)
  sequence.onNext(2)
  sequence.onNext(3)
  sequence.onNext(0)
}

exampleOf("concat") {
  let subject1 = BehaviorSubject(value: 0)
  let subject2 = BehaviorSubject(value: 200)
  let subject3 = BehaviorSubject(value: subject1) // Observable<Observable<Int>>
  
  _ = subject3
    .concat()
    .subscribe { print($0) }
  
  subject1.onNext(1)
  subject1.onNext(2)
  
  subject3.onNext(subject2)
  
  subject2.onNext(200)
  
  subject1.onNext(3)
  subject1.onCompleted()
  
  subject2.onNext(201)
  subject2.onNext(202)
}

exampleOf("reduce") {
  _ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    .reduce(0, accumulator: +)
    .subscribeNext { print($0) }
}

func delay(delay: UInt64, closure: Void -> Void) {
  dispatch_after(
    dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSEC_PER_SEC)),
    dispatch_get_main_queue(),
    closure
  )
}

func sampleWithoutConnectableOperators() {
  printExampleOf(__FUNCTION__)
  let observable = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
  _ = observable.subscribe { print("First subscription:", $0) }
  
  delay(5) {
    _ = observable.subscribe { print("Second subscription:", $0) }
  }
}

//sampleWithoutConnectableOperators()

func sampleWithMulticast() {
  printExampleOf(__FUNCTION__)
  let subject = PublishSubject<Int64>()
  _ = subject.subscribeNext { print("Subject:", $0) }
  
  let observable = Observable<Int64>
    .interval(1.0, scheduler: MainScheduler.instance)
    .multicast(subject)
  _ = observable.subscribeNext { print("First subscription:", $0) }
  
  delay(2) { observable.connect() }
  delay(4) { _ = observable.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = observable.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithMulticast()

func sampleWithReplayBuffer(buffer: Int? = nil) {
  let bufferString = buffer != nil ? String(buffer!) : "all"
  printExampleOf("\(__FUNCTION__): \(bufferString)")
  let observable: ConnectableObservable<Int>
  
  if let buffer = buffer {
  observable = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .replay(buffer)
  } else {
    observable = Observable<Int>
      .interval(1.0, scheduler: MainScheduler.instance)
      .replayAll()
  }
  
  _ = observable.subscribeNext { print("First subscription:", $0) }
  
  delay(2) { observable.connect() }
  delay(4) { _ = observable.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = observable.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithReplayBuffer()

func sampleWithPublish() {
  printExampleOf(__FUNCTION__)
  let observable = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .publish()
  
  _ = observable.subscribeNext { print("First subscription:", $0) }
  delay(2) { observable.connect() }
  delay(4) { _ = observable.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = observable.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithPublish()
