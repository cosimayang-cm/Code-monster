//
//  UserDefaultsPopupStateRepository.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// UserDefaults-backed implementation of PopupStateRepository for persistent storage
public class UserDefaultsPopupStateRepository: PopupStateRepository {
    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "com.popupchain.userdefaults", attributes: .concurrent)
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - PopupStateRepository
    
    public func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
        var result: PopupState?
        
        queue.sync {
            let key = makeKey(memberId: memberId, type: type)
            if let data = defaults.data(forKey: key) {
                do {
                    result = try JSONDecoder().decode(PopupState.self, from: data)
                } catch {
                    // If decode fails, return default state
                    result = nil
                }
            }
        }
        
        if let state = result {
            // Check for daily reset
            if shouldReset(state: state) {
                let resetState = PopupState(type: type)
                _ = updateState(resetState, memberId: memberId)
                return .success(resetState)
            }
            return .success(state)
        }
        
        // Return default state if not found
        return .success(PopupState(type: type))
    }
    
    public func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let key = self.makeKey(memberId: memberId, type: state.type)
            
            do {
                let data = try JSONEncoder().encode(state)
                self.defaults.set(data, forKey: key)
            } catch {
                // Encoding failed, but we don't propagate the error in async context
            }
        }
        
        return .success(())
    }
    
    public func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
        let getResult = getState(for: type, memberId: memberId)
        
        guard case .success(let currentState) = getResult else {
            return .failure(.repositoryReadFailed(type))
        }
        
        let newState = PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: currentState.showCount + 1
        )
        
        return updateState(newState, memberId: memberId)
    }
    
    public func resetUser(memberId: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Remove all keys for this user
            let allTypes: [PopupType] = [.tutorial, .interstitialAd, .newFeature, .dailyCheckIn, .predictionResult]
            for type in allTypes {
                let key = self.makeKey(memberId: memberId, type: type)
                self.defaults.removeObject(forKey: key)
            }
        }
    }
    
    public func resetAll() {
        // This is a nuclear option - should only be used in tests
        // In production, we don't have a list of all memberIds
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Get all keys with our prefix
            let allKeys = Array(self.defaults.dictionaryRepresentation().keys)
            for key in allKeys where key.hasPrefix("popup_") {
                self.defaults.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// Creates a unique key for UserDefaults storage
    /// Format: popup_{memberId}_{popupType}
    private func makeKey(memberId: String, type: PopupType) -> String {
        return "popup_\(memberId)_\(type.rawValue)"
    }
    
    /// Checks if a state should be reset based on its reset policy
    private func shouldReset(state: PopupState) -> Bool {
        switch state.type.resetPolicy {
        case .permanent:
            return false
        case .daily:
            return !isToday(state.lastShownDate)
        case .onNewResult:
            // This is handled by the handler itself
            return false
        }
    }
    
    /// Checks if a date is today
    private func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
