import Foundation

protocol TaskRepository {
    func fetchTasks() async throws -> [TaskModel]
    func addTask(_ task: TaskModel) async throws
    func updateTask(_ task: TaskModel) async throws
    func deleteTask(withId id: UUID) async throws
    func toggleTaskCompletion(withId id: UUID) async throws
}
