import SwiftUI

struct ContentView: View {
    @State private var viewModel: TaskListViewModel
    @State private var showingAddTask = false
    
    init(taskRepository: TaskRepository) {
        _viewModel = State(wrappedValue: TaskListViewModel(taskRepository: taskRepository))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskRow(task: task) {
                            viewModel.toggleTaskCompletion(id: task.id)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTask(id: viewModel.tasks[index].id)
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                if viewModel.tasks.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView {
                        Label("No Tasks", systemImage: "checklist")
                    } description: {
                        Text("Add tasks using the + button")
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.loadTasks()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskRepository: viewModel.taskRepository) {
                    viewModel.loadTasks()
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
    
    private var alertIdentifier: Binding<String?> {
        Binding<String?>(
            get: { viewModel.errorMessage != nil ? "error" : nil },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}
