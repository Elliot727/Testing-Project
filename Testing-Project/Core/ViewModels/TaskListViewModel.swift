import Foundation
import Combine

@Observable
class TaskListViewModel {
     var tasks: [TaskModel] = []
     var isLoading: Bool = false
     var errorMessage: String?
    
     let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        loadTasks()
    }
    
    func loadTasks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedTasks = try await taskRepository.fetchTasks()
                await MainActor.run {
                    self.tasks = fetchedTasks
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func addTask(title: String, description: String, dueDate: Date?) {
        let newTask = TaskModel(title: title, description: description, dueDate: dueDate)
        
        Task {
            do {
                try await taskRepository.addTask(newTask)
                loadTasks()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func toggleTaskCompletion(id: UUID) {
        Task {
            do {
                try await taskRepository.toggleTaskCompletion(withId: id)
                loadTasks()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update task: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteTask(id: UUID) {
        Task {
            do {
                try await taskRepository.deleteTask(withId: id)
                loadTasks()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete task: \(error.localizedDescription)"
                }
            }
        }
    }
}
