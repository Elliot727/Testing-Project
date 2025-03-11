import Foundation

protocol PersistenceManager {
    func save(_ tasks: [TaskModel]) async throws
    func load() throws -> [TaskModel]?
}
