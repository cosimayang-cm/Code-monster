//
//  FaultyMockRepository.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
@testable import CodeMonster

/// Mock repository that can simulate failures for testing error handling
class FaultyMockRepository: PopupStateRepository {
    var states: [String: [PopupType: PopupState]] = [:]
    
    // Error injection controls
    var shouldFailOnRead = false
    var shouldFailOnWrite = false
    var failureType: PopupType?
    
    func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
        if shouldFailOnRead {
            if let failureType = failureType, failureType == type {
                return .failure(.repositoryReadFailed(type))
            }
            if failureType == nil {
                return .failure(.repositoryReadFailed(type))
            }
        }
        
        if let state = states[memberId]?[type] {
            return .success(state)
        }
        
        return .success(PopupState(type: type))
    }
    
    func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
        if shouldFailOnWrite {
            if let failureType = failureType, failureType == state.type {
                return .failure(.repositoryWriteFailed(state.type))
            }
            if failureType == nil {
                return .failure(.repositoryWriteFailed(state.type))
            }
        }
        
        if states[memberId] == nil {
            states[memberId] = [:]
        }
        states[memberId]?[state.type] = state
        return .success(())
    }
    
    func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
        if shouldFailOnWrite {
            if let failureType = failureType, failureType == type {
                return .failure(.repositoryWriteFailed(type))
            }
            if failureType == nil {
                return .failure(.repositoryWriteFailed(type))
            }
        }
        
        let currentState = states[memberId]?[type] ?? PopupState(type: type)
        let newState = PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: currentState.showCount + 1
        )
        
        if states[memberId] == nil {
            states[memberId] = [:]
        }
        states[memberId]?[type] = newState
        return .success(())
    }
    
    func resetUser(memberId: String) {
        states[memberId] = nil
    }
    
    func resetAll() {
        states.removeAll()
    }
    
    // Helper methods for tests
    func setState(_ state: PopupState, for memberId: String) {
        if states[memberId] == nil {
            states[memberId] = [:]
        }
        states[memberId]?[state.type] = state
    }
    
    func enableReadFailure(for type: PopupType? = nil) {
        shouldFailOnRead = true
        failureType = type
    }
    
    func enableWriteFailure(for type: PopupType? = nil) {
        shouldFailOnWrite = true
        failureType = type
    }
    
    func disableFailures() {
        shouldFailOnRead = false
        shouldFailOnWrite = false
        failureType = nil
    }
}
