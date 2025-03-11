import Foundation

class MockPersistenceManager: PersistenceManager {
    var savedTasks: [TaskModel] = []
    var shouldFailOnSave = false
    var shouldFailOnLoad = false
    
    func save(_ tasks: [TaskModel]) async throws {
        if shouldFailOnSave {
            throw TaskError.saveFailed
        }
        savedTasks = tasks
    }
    
    func load() throws -> [TaskModel]? {
        if shouldFailOnLoad {
            throw TaskError.loadFailed
        }
        return savedTasks
    }
}
