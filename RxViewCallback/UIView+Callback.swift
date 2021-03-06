//
//  UIView+Callback.swift
//  ADJAddress
//
//  Created by 张伟 on 2018/11/5.
//  Copyright © 2018 zevwings. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit

public typealias Parameters = (source: Any?, object: Any?, userInfo: [AnyHashable: Any]?)

extension Reactive where Base: UIView {
    
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<UIView, RxViewCallbackDelegate> {
        return RxViewCallbackDelegateProxy.proxy(for: base)
    }
    
    public var callback: ControlEvent<Parameters> {
        
        let source = delegate.methodInvoked(#selector(RxViewCallbackDelegate.callback(with:object:userInfo:)))
            .map { params -> Parameters in
                
                let source = params[0]
                let object = params[1]
                let userInfo = params[2] as? [AnyHashable: Any]
                return (source: source, object: object, userInfo: userInfo)
        }
        return ControlEvent(events: source)
    }
    
    public func callback<T>(_ itemType: T.Type) -> ControlEvent<CallbackData<T>> {
        
        let source: Observable<CallbackData<T>> = callback.flatMap {
            params -> Observable<CallbackData<T>> in
            
            var data = CallbackData<T>()
            data.object = params.object
            data.userInfo = params.userInfo
            data.item = params.object as? T
            return Observable.just(data)
        }
        
        return ControlEvent(events: source)
    }
    
    public func setCallbackDelegate(_ delegate: RxViewCallbackDelegate) -> Disposable {
        return RxViewCallbackDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

#endif

