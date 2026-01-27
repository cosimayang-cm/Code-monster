//
//  CompositeCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// CompositeCommand - 複合命令，將多個命令組合為一個原子操作
/// FR-020: Support command grouping with sequential execute and reverse undo
final class CompositeCommand: Command {

    // MARK: - Properties

    private var commands: [Command] = []
    private let groupDescription: String

    // MARK: - Command Protocol

    var description: String {
        return groupDescription
    }

    // MARK: - Initialization

    /// 建立複合命令
    /// - Parameter description: 命令群組的描述
    init(description: String) {
        self.groupDescription = description
    }

    /// 使用命令陣列建立複合命令
    /// - Parameters:
    ///   - commands: 要組合的命令陣列
    ///   - description: 命令群組的描述
    init(commands: [Command], description: String) {
        self.commands = commands
        self.groupDescription = description
    }

    // MARK: - Public Methods

    /// 加入子命令
    /// - Parameter command: 要加入的命令
    func add(_ command: Command) {
        commands.append(command)
    }

    /// 取得子命令數量
    var count: Int {
        return commands.count
    }

    // MARK: - Execute & Undo

    /// 依序執行所有子命令
    func execute() {
        for command in commands {
            command.execute()
        }
    }

    /// 反序撤銷所有子命令
    func undo() {
        for command in commands.reversed() {
            command.undo()
        }
    }
}
