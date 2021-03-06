//
//  UICollectionView+EventResponseChain.swift
//  ADJAddress
//
//  Created by 张伟 on 2018/11/2.
//  Copyright © 2018 zevwings. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit

// MARK: - Rx

extension Reactive where Base: UICollectionReusableView {

    public func callback<T>(_ itemType: T.Type) -> ControlEvent<CallbackData<T>> {

        let source: Observable<CallbackData<T>> = callback.flatMap {
            [weak view = self.base as UICollectionReusableView] params -> Observable<CallbackData<T>> in

            var data = CallbackData<T>()
            data.source = params.source
            data.object = params.object
            
            if let view = view,
                let superview = view.superview as? UICollectionView,
                let ip = view.indexPath {
                
                var userInfo = params.userInfo ?? [:]
                userInfo[CallbackUserInfoKey.indexPath] = ip
                data.userInfo = userInfo
                data.item = try superview.rx.model(at: ip)
            }
            
            return Observable.just(data)
        }

        return ControlEvent(events: source)
    }
}

// MARK: - Ex

extension UICollectionReusableView {
    
    private struct _StorageKey {
        static var indexPath = "com.zevwings.eventHandler.indexPath"
    }
    
    public var indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &_StorageKey.indexPath) as? IndexPath
        }
        set {
            objc_setAssociatedObject(self, &_StorageKey.indexPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

#endif
