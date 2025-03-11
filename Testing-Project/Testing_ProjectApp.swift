import SwiftUI

@main
struct Testing_ProjectApp: App {
    private let taskRepository: TaskRepository
    
    init() {
        let persistenceManager = UserDefaultsPersistenceManager()
        self.taskRepository = LocalTaskRepository(persistenceManager: persistenceManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(taskRepository: taskRepository)
        }
    }
}
