//
//  CarEventObserver.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// Car 事件類型
enum CarEvent: Equatable {
    /// 中控電腦開啟
    case centralComputerTurnedOn
    /// 中控電腦關閉
    case centralComputerTurnedOff
    /// 引擎啟動
    case engineStarted
    /// 引擎停止
    case engineStopped
    /// 功能啟用
    case featureEnabled(Feature)
    /// 功能停用
    case featureDisabled(Feature)
    /// 連鎖停用（多個功能同時停用）
    case featuresCascadeDisabled([Feature])
}

/// Car 事件觀察者協定 (Observer Pattern)
protocol CarEventObserver: AnyObject {
    /// 當 Car 狀態改變時被呼叫
    func carDidChangeState(_ event: CarEvent)
}
