import SwiftUI

struct TaskRow: View {
    let task: TaskModel
    let toggleCompletion: () -> Void
    
    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let dueDate = task.dueDate {
                    Text("Due: \(formattedDate(dueDate))")
                        .font(.footnote)
                        .foregroundColor(isPastDue(dueDate) && !task.isCompleted ? .red : .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func isPastDue(_ date: Date) -> Bool {
        return date < Date()
    }
}
