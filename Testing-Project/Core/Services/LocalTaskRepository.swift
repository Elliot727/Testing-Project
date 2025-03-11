import Foundation

class LocalTaskRepository: TaskRepository {
    private var tasks: [TaskModel] = []
    private let persistenceManager: PersistenceManager
    
    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        do {
            self.tasks = try persistenceManager.load() ?? []
        } catch {
            print("Failed to load tasks: \(error)")
            self.tasks = []
        }
    }
    
    func fetchTasks() async throws -> [TaskModel] {
        return tasks
    }
    
    func addTask(_ task: TaskModel) async throws {
        tasks.append(task)
        try await persistenceManager.save(tasks)
    }
    
    func updateTask(_ task: TaskModel) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            try await persistenceManager.save(tasks)
        } else {
            throw TaskError.taskNotFound
        }
    }
    
    func deleteTask(withId id: UUID) async throws {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            try await persistenceManager.save(tasks)
        } else {
            throw TaskError.taskNotFound
        }
    }
    
    func toggleTaskCompletion(withId id: UUID) async throws {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
            try await persistenceManager.save(tasks)
        } else {
            throw TaskError.taskNotFound
        }
    }
}
