import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTaskViewModel
    let onSave: () -> Void
    
    init(taskRepository: TaskRepository, onSave: @escaping () -> Void) {
        _viewModel = State(wrappedValue: AddTaskViewModel(taskRepository: taskRepository))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $viewModel.title)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Toggle("Set Due Date", isOn: $viewModel.hasDueDate.animation())
                    
                    if viewModel.hasDueDate {
                        DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(!viewModel.validateTitle())
                }
            }
            .alert(item: alertIdentifier) { identifier in
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveTask() {
        Task {
            if await viewModel.saveTask() {
                await MainActor.run {
                    onSave()
                    dismiss()
                }
            }
        }
    }
    
    private var alertIdentifier: Binding<String?> {
        Binding<String?>(
            get: { viewModel.errorMessage != nil ? "error" : nil },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}
