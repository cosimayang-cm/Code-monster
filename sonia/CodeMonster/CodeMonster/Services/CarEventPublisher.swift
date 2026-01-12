//
//  CarEventPublisher.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 專門負責 Car 事件發布與觀察者管理 (SRP)
class CarEventPublisher {
    
    /// 觀察者列表（使用 weak reference 避免循環引用）
    private var observers: [WeakObserver] = []
    
    // MARK: - Observer Management
    
    /// 加入觀察者
    func addObserver(_ observer: CarEventObserver) {
        // 清理已釋放的觀察者
        observers.removeAll { $0.observer == nil }
        
        // 避免重複加入
        if !observers.contains(where: { $0.observer === observer }) {
            observers.append(WeakObserver(observer))
        }
    }
    
    /// 移除觀察者
    func removeObserver(_ observer: CarEventObserver) {
        observers.removeAll { $0.observer === observer || $0.observer == nil }
    }
    
    /// 發布事件給所有觀察者
    func publish(_ event: CarEvent) {
        // 清理已釋放的觀察者
        observers.removeAll { $0.observer == nil }
        
        // 通知所有觀察者
        observers.forEach { $0.observer?.carDidChangeState(event) }
    }
    
    // MARK: - Helper
    
    /// 取得當前觀察者數量（用於測試）
    func observerCount() -> Int {
        observers.removeAll { $0.observer == nil }
        return observers.count
    }
}

// MARK: - WeakObserver Wrapper

/// Weak reference wrapper for observers (避免循環引用)
private class WeakObserver {
    weak var observer: CarEventObserver?
    
    init(_ observer: CarEventObserver) {
        self.observer = observer
    }
}
