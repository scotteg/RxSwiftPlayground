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
  Observable<Int>.empty().subscribe { print($0) }.dispose()
}

exampleOf("never") {
  Observable<Int>.never().subscribe { print($0) }.dispose()
}

exampleOf("just") {
  Observable.just(32).subscribe { print($0) }.dispose()
}

exampleOf("of") {
  Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9).subscribe { print($0) }.dispose()
}

exampleOf("toObservable") {
  [1, 2, 3].toObservable().subscribe { print($0) }.dispose()
}

exampleOf("create") {
  let myJust: Int -> Observable<Int> = { element in
    return Observable.create {
      $0.onNext(element)
      $0.on(.Completed)
      return NopDisposable.instance
    }
  }
  
  myJust(5).subscribe { print($0) }.dispose()
}

exampleOf("generate") {
  Observable.generate(
    initialState: 0,
    condition: { $0 < 3 },
    iterate: { $0 + 1 }
    ).subscribe { print($0) }
    .dispose()
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
  
  deferredSequence.subscribe { print($0) }.dispose()
  deferredSequence.subscribe { print($0) }.dispose()
}

// TODO: rx_observe, rx_tap, rx_notification

extension ObservableType {
  
  func addPrintSubscription(name: String) -> Disposable {
    return subscribe { print("Subscription:", name, "\nEvent:", $0) }
  }
  
}

exampleOf("PublishSubject") {
  let disposeBag = DisposeBag()
  let subject = PublishSubject<String>()
  subject.addPrintSubscription("1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  subject.addPrintSubscription("2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
}

exampleOf("ReplaySubject") {
  let disposeBag = DisposeBag()
  let subject = ReplaySubject<String>.create(bufferSize: 1)
  subject.addPrintSubscription("1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  subject.addPrintSubscription("2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
}

exampleOf("BehaviorSubject") {
  let disposeBag = DisposeBag()
  let subject = BehaviorSubject(value: "z")
  subject.addPrintSubscription("1").addDisposableTo(disposeBag)
  subject.on(.Next("a"))
  subject.on(.Next("b"))
  subject.addPrintSubscription("2").addDisposableTo(disposeBag)
  subject.on(.Next("c"))
  subject.on(.Next("d"))
  subject.on(.Completed)
}

exampleOf("Variable") {
  let disposeBag = DisposeBag()
  let variable = Variable("z")
  variable.asObservable().addPrintSubscription("1").addDisposableTo(disposeBag)
  variable.value = "a"
  variable.value = "b"
  variable.asObservable().addPrintSubscription("2").addDisposableTo(disposeBag)
  variable.value = "c"
  variable.value = "d"
}

exampleOf("map") {
  Observable.of(1, 2, 3).map { $0 * 2 }.subscribe { print($0) }.dispose()
}

exampleOf("flatMap") {
  let sequenceString = Observable.of("A", "B", "C", "D", "E", "F", "--")
  
  Observable.of(1, 2, 3)
    .flatMap { i -> Observable<String> in
      print("Sequence:", i)
      return sequenceString
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("scan") {
  Observable.of(0, 1, 2, 3, 4, 5)
    .scan(0) {
      $0 + $1
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("filter") {
  Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    .filter { $0 % 2 == 0 }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("distinctUntilChanged") {
  Observable.of(1, 2, 2, 3, 3, 3, 1)
    .distinctUntilChanged()
    .subscribe { print($0) }
    .dispose()
}

exampleOf("take") {
  Observable.of(0, 1, 2, 3, 4, 5)
    .take(3)
    .subscribe { print($0) }
    .dispose()
}

exampleOf("startWith") {
  Observable.of(4, 5, 6)
    .startWith(3)
    .startWith(1, 2)
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest1") {
  let disposeBag = DisposeBag()
  let integerSubject = PublishSubject<Int>()
  let stringSubject = PublishSubject<String>()
  
  Observable.combineLatest(integerSubject, stringSubject) {
    "\($0) \($1)"
    }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
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
  
  Observable.combineLatest(integerObservableA, integerObservableB) {
    $0 * $1
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest3") {
  let integerObservableA = Observable.just(2)
  let integerObservableB = Observable.of(0, 1, 2, 3)
  let integerObservableC = Observable.of(0, 1, 2, 3, 4)
  
  Observable.combineLatest(integerObservableA, integerObservableB, integerObservableC) {
//    print($0, $1, $2) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    ($0 + $1) * $2
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest4") {
  let integerObservable = Observable.just(2)
  let stringObservable = Observable.just("a")
  
  Observable.combineLatest(integerObservable, stringObservable) {
    String($0) + $1
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest5") {
  let integerObservableA = Observable.just(2)
  let integerObservableB = Observable.of(0, 1, 2, 3)
  let integerObservableC = Observable.of(0, 1, 2, 3, 4)
  
  [integerObservableA, integerObservableB, integerObservableC].combineLatest {
//    print($0[0], $0[1], $0[2]) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    Int(($0[0] + $0[1]) * $0[2])
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("zip") {
  let disposeBag = DisposeBag()
  let stringSubject = PublishSubject<String>()
  let integerSubject = PublishSubject<Int>()
  
  Observable.zip(stringSubject, integerSubject) {
    "\($0) \($1)"
    }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  stringSubject.onNext("A")
  integerSubject.onNext(1)
  stringSubject.onNext("B")
  stringSubject.onNext("C")
  integerSubject.onNext(2)
  integerSubject.onNext(3)
}

exampleOf("merge1") {
  let disposeBag = DisposeBag()
  let integerSubject1 = PublishSubject<Int>()
  let integerSubject2 = PublishSubject<Int>()
  
  Observable.of(integerSubject1, integerSubject2)
    .merge()
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integerSubject1.onNext(20)
  integerSubject1.onNext(40)
  integerSubject1.onNext(60)
  integerSubject2.onNext(1)
  integerSubject1.onNext(80)
  integerSubject1.onNext(100)
  integerSubject2.onNext(2)
}

exampleOf("merge2") {
  let disposeBag = DisposeBag()
  let integerSubject1 = PublishSubject<Int>()
  let integerSubject2 = PublishSubject<Int>()
  let integerSubject3 = PublishSubject<Int>()
  
  Observable.of(integerSubject1, integerSubject2, integerSubject3)
    .merge(maxConcurrent: 2)
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
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
  let disposeBag = DisposeBag()
  let variable1 = Variable(0)
  let variable2 = Variable(200)
  let variable3 = Variable(variable1.asObservable()) // Observable<Observable<Int>>
  
  variable3
    .asObservable()
    .switchLatest()
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  variable1.value = 1
  variable1.value = 2
  variable1.value = 3
  
  variable3.value = variable2.asObservable()
  variable2.value = 201
  
  variable1.value = 4
}

exampleOf("catchError1") {
  let disposeBag = DisposeBag()
  let sequenceThatFails = PublishSubject<Int>()
  let recoverySequence = Observable.of(100, 200, 300)
  
  sequenceThatFails
    .catchError { _ in return recoverySequence }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  sequenceThatFails.onNext(1)
  sequenceThatFails.onNext(2)
  sequenceThatFails.onError(Error.A)
}

exampleOf("catchError2") {
  let disposeBag = DisposeBag()
  let sequenceThatFails = PublishSubject<Int>()
  sequenceThatFails
    .catchErrorJustReturn(100)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
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
  
  sequence
    .retry()
    .subscribe { print($0) }
    .dispose()
}

exampleOf("subscribe") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  sequence.subscribe { print($0) }.addDisposableTo(disposeBag)
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeNext") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  sequence.subscribeNext { print($0) }.addDisposableTo(disposeBag)
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeCompleted") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  
//  sequence.subscribeNext { print($0) }.addDisposableTo(disposeBag)
  sequence.subscribeCompleted { print("Done!") }.addDisposableTo(disposeBag)
  
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("subscribeError") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  sequence.subscribeError { print("Error:", $0) }.addDisposableTo(disposeBag)
  sequence.onNext(1)
  sequence.onError(Error.A)
}

exampleOf("doOn/doOnNext") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  
  sequence
    .doOnNext { print("Intercepted event:", $0) }
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  sequence
    .subscribeCompleted { print("Done!") }
    .addDisposableTo(disposeBag)
  
  sequence.onNext(1)
  sequence.onCompleted()
}

exampleOf("takeUntil") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  let haltSequence = PublishSubject<String>()
  
  sequence
    .takeUntil(haltSequence)
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)

  haltSequence
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
//  haltSequence.onNext("Hello")
  sequence.onNext(1)
  sequence.onNext(2)
  haltSequence.onNext("World")
  sequence.onNext(3)
}

exampleOf("takeWhile") {
  let disposeBag = DisposeBag()
  let sequence = PublishSubject<Int>()
  
  sequence
    .takeWhile { $0 < 3 }
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  sequence.onNext(1)
  sequence.onNext(2)
  sequence.onNext(3)
  sequence.onNext(0)
}

exampleOf("concat") {
  let subject1 = BehaviorSubject(value: 0)
  let subject2 = BehaviorSubject(value: 200)
  let subject3 = BehaviorSubject(value: subject1) // Observable<Observable<Int>>
  
  subject3
    .concat()
    .subscribe { print($0) }
    .dispose()
  
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
  Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    .reduce(0, accumulator: +)
    .subscribeNext { print($0) }
    .dispose()
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

sampleWithoutConnectableOperators()

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
