//
//  PopupEventPublisher.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Manages observers and publishes popup lifecycle events.
/// Uses weak references to prevent retain cycles.
public class PopupEventPublisher {
    
    /// Weak observer wrapper to prevent retain cycles
    private class WeakObserver {
        weak var observer: PopupEventObserver?
        
        init(_ observer: PopupEventObserver) {
            self.observer = observer
        }
    }
    
    private var observers: [WeakObserver] = []
    private let queue = DispatchQueue(label: "com.codemonster.popupevent", attributes: .concurrent)
    
    public init() {}
    
    // MARK: - Observer Management
    
    /// Add an observer to receive popup events.
    /// Uses weak reference - observer will be automatically removed when deallocated.
    /// - Parameter observer: The observer to add
    public func addObserver(_ observer: PopupEventObserver) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Remove deallocated observers
            self.observers = self.observers.filter { $0.observer != nil }
            
            // Don't add if already exists
            if !self.observers.contains(where: { $0.observer === observer }) {
                self.observers.append(WeakObserver(observer))
            }
        }
    }
    
    /// Remove an observer.
    /// - Parameter observer: The observer to remove
    public func removeObserver(_ observer: PopupEventObserver) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.observers.removeAll { $0.observer === observer || $0.observer == nil }
        }
    }
    
    /// Remove all observers and clean up deallocated ones.
    public func removeAllObservers() {
        queue.async(flags: .barrier) { [weak self] in
            self?.observers.removeAll()
        }
    }
    
    // MARK: - Event Publishing
    
    /// Publish an event to all observers.
    /// Automatically cleans up deallocated observers.
    /// - Parameter event: The event to publish
    public func publish(_ event: PopupEvent) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Clean up deallocated observers
            let activeObservers = self.observers.compactMap { $0.observer }
            
            // Notify on main thread
            DispatchQueue.main.async {
                activeObservers.forEach { observer in
                    observer.popupChain(didPublish: event)
                }
            }
            
            // Clean up deallocated references
            self.queue.async(flags: .barrier) { [weak self] in
                self?.observers = self?.observers.filter { $0.observer != nil } ?? []
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Publish willShow event
    public func publishWillShow(_ type: PopupType) {
        publish(.popupWillShow(type))
    }
    
    /// Publish didShow event
    public func publishDidShow(_ type: PopupType) {
        publish(.popupDidShow(type))
    }
    
    /// Publish willDismiss event
    public func publishWillDismiss(_ type: PopupType) {
        publish(.popupWillDismiss(type))
    }
    
    /// Publish didDismiss event
    public func publishDidDismiss(_ type: PopupType) {
        publish(.popupDidDismiss(type))
    }
    
    /// Publish chainCompleted event
    public func publishChainCompleted() {
        publish(.chainCompleted)
    }
}
