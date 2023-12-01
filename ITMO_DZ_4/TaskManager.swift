import Foundation

protocol Task {
    var priority: Int { get }
    var dependencies: [Task] { get set }
    func addDependency(_ task: Task)
    func run()
}

class MyTask: Task{
    var name: String
    var priority: Int
    var dependencies: [Task] = []

    init(name: String, priority: Int) {
        self.name = name
        self.priority = priority
    }

    func addDependency(_ task: Task) {
        dependencies.append(task)
    }

    func run() {
        print(name)
    }
}

class TaskManager {
    private var tasks: [Task] = []
    private let conQueue = DispatchQueue(label: "vk.itmo.hw4.task_manager_queue", attributes: .concurrent)
    
    func add(_ task: Task) -> Void {
        conQueue.async(flags: .barrier) {
            self.tasks.append(task)
        }
        self.tasks.sort { task1, task2 in
            return task1.priority > task2.priority
        }
    }
    
    func run() {
        while (!tasks.isEmpty) {
            var remove: [Task] = []
            var group = DispatchGroup()
            var haveCycle = true
            let freeTasks = tasks.filter { task in
                task.dependencies.allSatisfy {
                    dependency in !tasks.contains { ($0 as? MyTask) === dependency as? MyTask}
                }
            }
            for task in freeTasks {
                haveCycle = false
                group.enter()
                DispatchQueue.global().async {
                    task.run()
                    remove.append(task)
                    group.leave()
                }
            }
            group.wait()
            
            if !haveCycle {
                conQueue.sync(flags: .barrier) {
                    self.tasks.removeAll { task in
                        return remove.contains { ($0 as? MyTask) === task as? MyTask}
                    }
                }
            } /*else {
                print("It looks like there is some cycle of dependencies")
                break
            } */
        }
    }
}
