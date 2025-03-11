import Foundation

class UserDefaultsPersistenceManager: PersistenceManager {
    private let key = "savedTasks"
    
    func save(_ tasks: [TaskModel]) async throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            throw TaskError.saveFailed
        }
    }
    
    func load() throws -> [TaskModel]? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([TaskModel].self, from: data)
        } catch {
            throw TaskError.loadFailed
        }
    }
}
