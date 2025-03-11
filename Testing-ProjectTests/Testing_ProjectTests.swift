import Foundation
import Testing
@testable import Testing_Project

struct TaskModelTests {
    @Test
    func testTaskEquality() async throws {
        let id = UUID()
        let task1 = TaskModel(id: id, title: "Test Task", description: "Description", isCompleted: false)
        let task2 = TaskModel(id: id, title: "Test Task", description: "Description", isCompleted: false)
        let task3 = TaskModel(id: UUID(), title: "Test Task", description: "Description", isCompleted: false)
        
        #expect(task1 == task2, "Tasks with same properties should be equal")
        #expect(task1 != task3, "Tasks with different IDs should not be equal")
    }
    
    @Test
    func testTaskInitialization() async throws {
        let title = "Test Task"
        let description = "Description"
        let dueDate = Date()
        
        let task = TaskModel(title: title, description: description, dueDate: dueDate)
        
        #expect(task.title == title)
        #expect(task.description == description)
        #expect(task.dueDate == dueDate)
        #expect(task.isCompleted == false)
    }
}

struct TaskRepositoryTests {
    @Test
    func testFetchEmptyTasks() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        
        let tasks = try await repository.fetchTasks()
        
        #expect(tasks.isEmpty)
    }
    
    @Test
    func testAddTask() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task")
        
        try await repository.addTask(task)
        let tasks = try await repository.fetchTasks()
        
        #expect(tasks.count == 1)
        #expect(tasks[0].title == "Test Task")
        #expect(mockPersistence.savedTasks.count == 1)
    }
    
    @Test
    func testUpdateTask() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task")
        try await repository.addTask(task)
        
        var tasks = try await repository.fetchTasks()
        var updatedTask = tasks[0]
        updatedTask.title = "Updated Task"
        
        try await repository.updateTask(updatedTask)
        tasks = try await repository.fetchTasks()
        
        #expect(tasks.count == 1)
        #expect(tasks[0].title == "Updated Task")
    }
    
    @Test
    func testDeleteTask() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task")
        try await repository.addTask(task)
        
        let tasks = try await repository.fetchTasks()
        let taskId = tasks[0].id
        
        try await repository.deleteTask(withId: taskId)
        let updatedTasks = try await repository.fetchTasks()
        
        #expect(updatedTasks.isEmpty)
    }
    
    @Test
    func testToggleTaskCompletion() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task", isCompleted: false)
        try await repository.addTask(task)
        
        var tasks = try await repository.fetchTasks()
        let taskId = tasks[0].id
        
        try await repository.toggleTaskCompletion(withId: taskId)
        tasks = try await repository.fetchTasks()
        
        #expect(tasks[0].isCompleted == true)
        
        try await repository.toggleTaskCompletion(withId: taskId)
        tasks = try await repository.fetchTasks()
        
        #expect(tasks[0].isCompleted == false)
    }
    
    @Test
    func testFailedSavingThrowsError() async throws {
        let mockPersistence = MockPersistenceManager()
        mockPersistence.shouldFailOnSave = true
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task")
        
        do {
            try await repository.addTask(task)
            #expect(false, "Should have thrown an error")
        } catch {
            #expect(error is TaskError)
            if let taskError = error as? TaskError {
                #expect(taskError == TaskError.saveFailed)
            }
        }
    }
}

struct TaskListViewModelTests {
    @Test
    func testInitialState() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        
        let viewModel = TaskListViewModel(taskRepository: repository)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(viewModel.tasks.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testLoadTasks() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let task = TaskModel(title: "Test Task")
        try await repository.addTask(task)
        
        let viewModel = TaskListViewModel(taskRepository: repository)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.tasks[0].title == "Test Task")
    }
    
    @Test
    func testAddTaskFunctionality() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let viewModel = TaskListViewModel(taskRepository: repository)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        viewModel.addTask(title: "New Task", description: "Test Description", dueDate: nil)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.tasks[0].title == "New Task")
        #expect(viewModel.tasks[0].description == "Test Description")
    }
}

struct AddTaskViewModelTests {
    @Test
    func testValidation() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let viewModel = AddTaskViewModel(taskRepository: repository)
        
        viewModel.title = ""
        #expect(viewModel.validateTitle() == false)
        
        viewModel.title = "Test Task"
        #expect(viewModel.validateTitle() == true)
    }
    
    @Test
    func testSaveTask() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let viewModel = AddTaskViewModel(taskRepository: repository)
        
        viewModel.title = "Test Task"
        viewModel.description = "Test Description"
        viewModel.hasDueDate = true
        viewModel.dueDate = Date()
        
        let success = await viewModel.saveTask()
        
        #expect(success == true)
        #expect(mockPersistence.savedTasks.count == 1)
        #expect(mockPersistence.savedTasks[0].title == "Test Task")
    }
    
    @Test
    func testSaveTaskFailsWithEmptyTitle() async throws {
        let mockPersistence = MockPersistenceManager()
        let repository = LocalTaskRepository(persistenceManager: mockPersistence)
        let viewModel = AddTaskViewModel(taskRepository: repository)
        
        viewModel.title = ""
        viewModel.description = "Test Description"
        
        let success = await viewModel.saveTask()
        
        #expect(success == false)
        #expect(viewModel.errorMessage == "Title cannot be empty")
        #expect(mockPersistence.savedTasks.isEmpty)
    }
}
