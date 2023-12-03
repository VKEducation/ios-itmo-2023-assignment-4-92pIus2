import Foundation

class ThreadSafeArray<T>  {
    private var array: [T] = []
    private let conQueue = DispatchQueue(label: "vk.itmo.hw4.thread_safe_array_queue", attributes: .concurrent)
    
    var count: Int {
        return conQueue.sync {
            return array.count
        }
    }
    
    var isEmpty: Bool {
        return conQueue.sync {
            return array.count == 0
        }
    }
    
    func append(_ element: T) {
        conQueue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func remove(at index: Int) -> T? {
        var result: T?
        conQueue.sync(flags: .barrier) {
            if index < array.count {
                result = array.remove(at: index)
            }
        }
        return result
    }
    
    func first() -> T? {
        return conQueue.sync {
            return array.first
        }
    }

    func last() -> T? {
        return conQueue.sync {
            return array.last
        }
    }
    
    func insert(_ newElement: T, at index: Int) {
       conQueue.async(flags: .barrier) {
           if index <= self.array.count {
               self.array.insert(newElement, at: index)
           }
       }
    }
    
    func dropFirst(_ k: Int = 1) -> ArraySlice<T> {
        return conQueue.sync {
            return array.dropFirst(k)
        }
    }

    func dropLast(_ k: Int = 1) -> ArraySlice<T> {
        return conQueue.sync {
            return array.dropLast(k)
        }
    }
}

extension ThreadSafeArray: RandomAccessCollection {
    typealias Index = Int
    typealias Element = T

    var startIndex: Index { return conQueue.sync { return array.startIndex } }
    var endIndex: Index { return conQueue.sync { return array.endIndex } }

    subscript(index: Index) -> Element {
        get { return conQueue.sync { return array[index] } }// Мне кажется что возвращать Element, a не Element? не ок, но шаблон не стал менять, просто ошибку кидает, если за границу запрос
        set {
            conQueue.async(flags: .barrier) {
                if index < self.array.count {
                    self.array[index] = newValue
                }
            }
        }
    }

    func index(after i: Index) -> Index {
        return conQueue.sync { return array.index(after: i) }
    }
}
