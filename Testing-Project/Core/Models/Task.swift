import Foundation

struct TaskModel: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String = "", isCompleted: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
}
