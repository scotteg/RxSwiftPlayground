//: Please build the scheme 'RxSwiftPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import RxSwift

func exampleOf(description: String, @noescape action: Void -> Void) {
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
      $0.onCompleted()
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
  Observable<Int>.error(Error.A)
    .subscribe { print($0) }
    .dispose()
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

extension ObservableType {
  
  func addPrintSubscription(name: String) -> Disposable {
    return subscribe { print("Subscription:", name, "Event:", $0) }
  }
  
}

exampleOf("PublishSubject") {
  let disposeBag = DisposeBag()
  let string$ = PublishSubject<String>()
  string$.addPrintSubscription("1").addDisposableTo(disposeBag)
  string$.onNext("a")
  string$.onNext("b")
  string$.addPrintSubscription("2").addDisposableTo(disposeBag)
  string$.onNext("c")
  string$.onNext("d")
}

exampleOf("ReplaySubject") {
  let disposeBag = DisposeBag()
  let string$ = ReplaySubject<String>.create(bufferSize: 1)
  string$.addPrintSubscription("1").addDisposableTo(disposeBag)
  string$.onNext("a")
  string$.onNext("b")
  string$.addPrintSubscription("2").addDisposableTo(disposeBag)
  string$.onNext("c")
  string$.onNext("d")
}

exampleOf("BehaviorSubject") {
  let disposeBag = DisposeBag()
  let string$ = BehaviorSubject(value: "z")
  string$.addPrintSubscription("1").addDisposableTo(disposeBag)
  string$.onNext("a")
  string$.onNext("b")
  string$.addPrintSubscription("2").addDisposableTo(disposeBag)
  string$.onNext("c")
  string$.onNext("d")
  string$.onCompleted()
}

exampleOf("Variable") {
  let disposeBag = DisposeBag()
  let string$ = Variable("z")
  string$.asObservable().addPrintSubscription("1").addDisposableTo(disposeBag)
  string$.value = "a"
  string$.value = "b"
  string$.asObservable().addPrintSubscription("2").addDisposableTo(disposeBag)
  string$.value = "c"
  string$.value = "d"
}

exampleOf("map") {
  Observable.of(1, 2, 3).map { $0 * 2 }.subscribe { print($0) }.dispose()
}

exampleOf("flatMap") {
  let string$ = Observable.of("A", "B", "C", "D", "E", "F", "--")
  
  Observable.of(1, 2, 3)
    .flatMap { i -> Observable<String> in
      print("Sequence:", i)
      return string$
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
  Observable.of([0, 1, 2, 3, 4, 5])
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
  let integer$ = PublishSubject<Int>()
  let string$ = PublishSubject<String>()
  
  Observable.combineLatest(integer$, string$) {
    "\($0) \($1)"
    }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  string$.onNext("A")
  
  integer$.onNext(2)
  string$.onNext("B")
  
  string$.onNext("C")
  integer$.onNext(3)
}

exampleOf("combineLatest2") {
  let integerA$ = Observable.just(2)
  let integerB$ = Observable.of(0, 1, 2, 3)
  
  Observable.combineLatest(integerA$, integerB$) {
    $0 * $1
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest3") {
  let integerA$ = Observable.just(2)
  let integerB$ = Observable.of(0, 1, 2, 3)
  let integerC$ = Observable.of(0, 1, 2, 3, 4)
  
  Observable.combineLatest(integerA$, integerB$, integerC$) {
//    print($0, $1, $2) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    ($0 + $1) * $2
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest4") {
  let integer$ = Observable.just(2)
  let string$ = Observable.just("a")
  
  Observable.combineLatest(integer$, string$) {
    String($0) + $1
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("combineLatest5") {
  let integerA$ = Observable.just(2)
  let integerB$ = Observable.of(0, 1, 2, 3)
  let integerC$ = Observable.of(0, 1, 2, 3, 4)
  
  [integerA$, integerB$, integerC$].combineLatest {
//    print($0[0], $0[1], $0[2]) // TODO: Why?: 2, 3, 0; 2, 3, 1; 2, 3, 2; 2, 3, 3; 2, 3, 4
    Int(($0[0] + $0[1]) * $0[2])
    }
    .subscribe { print($0) }
    .dispose()
}

exampleOf("zip") {
  let disposeBag = DisposeBag()
  let string$ = PublishSubject<String>()
  let integer$ = PublishSubject<Int>()
  
  Observable.zip(string$, integer$) {
    "\($0) \($1)"
    }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  string$.onNext("A")
  integer$.onNext(1)
  string$.onNext("B")
  string$.onNext("C")
  integer$.onNext(2)
  integer$.onNext(3)
}

exampleOf("merge1") {
  let disposeBag = DisposeBag()
  let integerA$ = PublishSubject<Int>()
  let integerB$ = PublishSubject<Int>()
  
  Observable.of(integerA$, integerB$)
    .merge()
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integerA$.onNext(20)
  integerA$.onNext(40)
  integerA$.onNext(60)
  integerB$.onNext(1)
  integerA$.onNext(80)
  integerA$.onNext(100)
  integerB$.onNext(2)
}

exampleOf("merge2") {
  let disposeBag = DisposeBag()
  let integerA$ = PublishSubject<Int>()
  let integerB$ = PublishSubject<Int>()
  let integerC$ = PublishSubject<Int>()
  
  Observable.of(integerA$, integerB$, integerC$)
    .merge(maxConcurrent: 2)
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integerA$.onNext(20)
  integerA$.onNext(40)
  integerB$.onNext(2)
  integerA$.onNext(60)
  integerC$.onNext(3)
  integerA$.onNext(80)
  integerA$.onNext(100)
  integerB$.onNext(2)
}

exampleOf("switchLatest") {
  let disposeBag = DisposeBag()
  let integerA$ = Variable(0)
  let integerB$ = Variable(200)
  let integerC$ = Variable(integerA$.asObservable()) // Observable<Observable<Int>>
  
  integerC$.asObservable()
    .switchLatest()
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  integerA$.value = 1
  integerA$.value = 2
  integerA$.value = 3
  
  integerC$.value = integerB$.asObservable()
  integerB$.value = 201
  
  integerA$.value = 4
}

exampleOf("catchError1") {
  let disposeBag = DisposeBag()
  let failing$ = PublishSubject<Int>()
  let recovery$ = Observable.of(100, 200, 300)
  
  failing$
    .catchError { _ in return recovery$ }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  failing$.onNext(1)
  failing$.onNext(2)
  failing$.onError(Error.A)
}

exampleOf("catchError2") {
  let disposeBag = DisposeBag()
  let failing$ = PublishSubject<Int>()
  
  failing$
    .catchErrorJustReturn(100)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  failing$.onNext(1)
  failing$.onNext(2)
  failing$.onError(Error.A)
}

exampleOf("retry") {
  var count = 0
  let integer$ = Observable<Int>.create {
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
  
  integer$
    .retry()
    .subscribe { print($0) }
    .dispose()
}

exampleOf("subscribe") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onCompleted()
}

exampleOf("subscribeNext") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onCompleted()
}

exampleOf("subscribeCompleted") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .subscribeCompleted { print("Done!") }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onCompleted()
}

exampleOf("subscribeError") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .subscribeError { print("Error:", $0) }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onError(Error.A)
}

exampleOf("doOn/doOnNext") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .doOnNext { print("Intercepted event:", $0) }
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integer$
    .subscribeCompleted { print("Done!") }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onCompleted()
}

exampleOf("takeUntil") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  let string$ = PublishSubject<String>()
  
  integer$
    .takeUntil(string$)
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)

  string$
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
//  haltSequence.onNext("Hello")
  integer$.onNext(1)
  integer$.onNext(2)
  string$.onNext("World")
  integer$.onNext(3)
}

exampleOf("takeWhile") {
  let disposeBag = DisposeBag()
  let integer$ = PublishSubject<Int>()
  
  integer$
    .takeWhile { $0 < 3 }
    .subscribeNext { print($0) }
    .addDisposableTo(disposeBag)
  
  integer$.onNext(1)
  integer$.onNext(2)
  integer$.onNext(3)
  integer$.onNext(0)
}

exampleOf("concat") {
  let integerA$ = BehaviorSubject(value: 0)
  let integerB$ = BehaviorSubject(value: 200)
  let integerC$ = BehaviorSubject(value: integerA$) // Observable<Observable<Int>>
  
  integerC$
    .concat()
    .subscribe { print($0) }
    .dispose()
  
  integerA$.onNext(1)
  integerA$.onNext(2)
  
  integerC$.onNext(integerB$)
  
  integerB$.onNext(200)
  
  integerA$.onNext(3)
  integerA$.onCompleted()
  
  integerB$.onNext(201)
  integerB$.onNext(202)
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
  printExampleOf(#function)
  let observable = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
  _ = observable.subscribe { print("First subscription:", $0) }
  
  delay(5) {
    _ = observable.subscribe { print("Second subscription:", $0) }
  }
}

//sampleWithoutConnectableOperators()

func sampleWithMulticast() {
  printExampleOf(#function)
  let integerA$ = PublishSubject<Int64>()
  _ = integerA$.subscribeNext { print("Subject:", $0) }
  
  let integerB$ = Observable<Int64>
    .interval(1.0, scheduler: MainScheduler.instance)
    .multicast(integerA$)
  _ = integerB$.subscribeNext { print("First subscription:", $0) }
  
  delay(2) { integerB$.connect() }
  delay(4) { _ = integerB$.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = integerB$.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithMulticast()

func sampleWithReplayBuffer(buffer: Int? = nil) {
  let bufferString = buffer != nil ? String(buffer!) : "all"
  printExampleOf("\(#function): \(bufferString)")
  let integer$: ConnectableObservable<Int>
  
  if let buffer = buffer {
    integer$ = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .replay(buffer)
  } else {
    integer$ = Observable<Int>
      .interval(1.0, scheduler: MainScheduler.instance)
      .replayAll()
  }
  
  _ = integer$.subscribeNext { print("First subscription:", $0) }
  
  delay(2) { integer$.connect() }
  delay(4) { _ = integer$.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = integer$.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithReplayBuffer()

func sampleWithPublish() {
  printExampleOf(#function)
  let integer$ = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .publish()
  
  _ = integer$.subscribeNext { print("First subscription:", $0) }
  delay(2) { integer$.connect() }
  delay(4) { _ = integer$.subscribeNext { print("Second subscription:", $0) } }
  delay(8) { _ = integer$.subscribeNext { print("Third subscription:", $0) } }
}

//sampleWithPublish()

exampleOf("flatMapLatest with stream that contains streams") {
  let disposeBag = DisposeBag()
  
  struct SomeStruct {
    var stringValue$: Variable<String>
  }
  
  let someStruct1 = SomeStruct(stringValue$: Variable("One"))
  let someStruct2 = SomeStruct(stringValue$: Variable("Two"))
  let someStruct3 = SomeStruct(stringValue$: Variable("Three"))
  
  let someStruct$ = Variable(someStruct1)
  
  someStruct$
    .asObservable()
    .flatMapLatest {
      $0.stringValue$.asObservable()
    }
    .subscribeNext {
      print($0)
    }.addDisposableTo(disposeBag)
  
  someStruct$.value = someStruct2
  someStruct$.value = someStruct3
  someStruct1.stringValue$.value = "Should I see this?" // No, if using flatMapLatest, but yes if using flatMap
  someStruct3.stringValue$.value = "Changed"
}

exampleOf("Observing observables of observables within an array of observables") {
  class Thing {
    var setting$: Variable<String>
    
    init(_ setting: String) {
      setting$ = Variable<String>(setting)
    }
  }
  
  let thing1 = Thing("Foo")
  let thing2 = Thing("Bar")
  let thing3 = Thing("Baz")
  
  var things$ = Variable<[Thing]> ([thing1, thing2, thing3])
  var disposeBag = DisposeBag()
  
  things$.asObservable().subscribeNext {
    disposeBag = DisposeBag()
    
    $0.map {
      $0.setting$.asObservable()
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
    }
    }.addDisposableTo(disposeBag)
  
//  things$.asObservable().flatMap {
//    $0.map { $0.setting$.asObservable() }.combineLatest { $0 }
//    }.subscribeNext { print($0) }
//    .addDisposableTo(disposeBag)
  
  things$.value[0].setting$.value = "Woot"
  things$.value[1].setting$.value = "What"
  things$.value.append(Thing("Whiz"))
}

exampleOf("Combining two Variables") {
  let center = Variable<CGPoint>(CGPoint.zero)
  let size = Variable<CGSize>(CGSize.zero)
  
  var color: Observable<UIColor> {
    return Observable.combineLatest(
      center.asObservable(),
      size.asObservable()
    ) { center, size in
      let color: UIColor
      switch (center, size) {
      case (CGPoint(x: 1, y: 1), CGSize(width: 1, height: 1)):
        color = UIColor.blackColor()
      default:
        color = UIColor.whiteColor()
      }
      
      return color
    }
  }
  
  color.distinctUntilChanged().subscribe { print($0) }
  center.value = CGPoint(x: 1, y: 1)
  size.value = CGSize(width: 1, height: 1)
}
