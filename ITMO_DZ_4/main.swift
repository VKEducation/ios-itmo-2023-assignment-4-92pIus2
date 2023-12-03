import Foundation

let ff = ThreadSafeArray<Int>()
ff.append(123)
var dd = [1]
dd.append(1)
ff[0] = 239
let sd = ff[0]
print(sd)

let a = ThreadSafeArray<Int>()
var b = [0]
let group = DispatchGroup()

for index in 0..<500 {
    DispatchQueue.global(qos: .userInitiated).async {
        let newIndex = index * index
        a.append(newIndex)
        //b.append(newIndex)
    }
}

group.notify(queue: DispatchQueue.main) {
    print(a.count)
}

let taskA: MyTask = MyTask(name: "A", priority: 100)
let taskB: MyTask = MyTask(name: "B", priority: 50)
let taskC: MyTask = MyTask(name: "C", priority: 75)

taskA.addDependency(taskB)
let manager: TaskManager = TaskManager()
manager.add(taskA)
manager.add(taskB)
manager.add(taskC)
manager.run()

RunLoop.current.run()
