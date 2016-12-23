//
//  ComputedVariable.swift
//  BA3
//
//  Created by Dung Vu on 12/23/16.
//  Copyright © 2016 Zinio LLC. All rights reserved.
//

import Foundation
import RxSwift

/// Using simliar variable in RXSwift but it can custom behavior
public class ComputedVariable<Element> {
    
    public typealias E = Element
    
    private let _getter: () -> Element
    private let _setter: (Element) -> Void
    
    private let _subject: BehaviorSubject<Element>
    private var _lock = NSRecursiveLock()
    
    public var value: Element {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _getter()
        }
        set(newValue) {
            _lock.lock()
            _setter(newValue)
            _lock.unlock()
            _subject.on(.next(newValue))
        }
    }
    
    public init(getter: @escaping () -> E, setter: @escaping (E) -> Void) {
        _getter = getter
        _setter = setter
        _subject = BehaviorSubject(value: getter())
    }
    
    public func asObservable() -> Observable<E> {
        return _subject
    }
    
    deinit {
        _subject.on(.completed)
    }
}
