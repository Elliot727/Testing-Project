import Foundation

@Observable
class AddTaskViewModel {
     var title: String = ""
     var description: String = ""
     var dueDate: Date = Date()
     var hasDueDate: Bool = false
     var errorMessage: String?
    
    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    func saveTask() async -> Bool {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty"
            return false
        }
        
        let task = TaskModel(
            title: title,
            description: description,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        do {
            try await taskRepository.addTask(task)
            return true
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
            return false
        }
    }
    
    func validateTitle() -> Bool {
        return !title.isEmpty
    }
}
