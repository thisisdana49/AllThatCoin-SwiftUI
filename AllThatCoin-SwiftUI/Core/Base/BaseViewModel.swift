import Foundation
import Combine

protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    
    func dispatch(_ action: Action)
} 