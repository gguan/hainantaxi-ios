//
//  DisposeQueue.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift

extension Disposable {
    func addDisposableTo(_ bag: DisposeQueue, key: String) {
        bag.addDisposable(self, key: key)
    }
}

class DisposeQueue {
    
    fileprivate var _lock = NSRecursiveLock()
    
    fileprivate var _disposables = [String: Disposable]()
    fileprivate var _disposed = false
    
    
    deinit {
        dispose()
    }
    
    func addDisposable(_ disposable: Disposable, key: String) {
        _addDisposable(disposable, key: key)?.dispose()
    }
    
    fileprivate func _addDisposable(_ disposable: Disposable, key: String) -> Disposable? {
        _lock.lock();
        defer {
            _lock.unlock()
        }
        if _disposed {
            return disposable
        }
        _disposables[key]?.dispose()
        _disposables[key] = disposable
        
        return nil
    }
    
    func dispose() {
        let oldDisposables = _dispose()
        for disposable in oldDisposables {
            disposable.dispose()
        }
    }
    
    func dispose(_ key: String) {
        _lock.lock();
        defer {
            _lock.unlock()
        }
        guard let disposable = _disposables[key] else {
            return
        }
        _disposables.removeValue(forKey: key)
        disposable.dispose()
    }
    
    fileprivate func _dispose() -> [Disposable] {
        _lock.lock();
        defer {
            _lock.unlock()
        }
        let disposables = _disposables
        _disposables.removeAll(keepingCapacity: false)
        _disposed = true
        return disposables.map {
            $1
        }
    }
    
    func containerDispose(key: String) -> Bool {
        _lock.lock();
        defer {
            _lock.unlock()
        }
        return _disposables.keys.contains(key)
    }
    
}


