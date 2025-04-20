import SwiftUI

protocol BaseView: View {
    associatedtype ViewModel: BaseViewModel
    
    var viewModel: ViewModel { get }
}

extension BaseView {
    func makeView() -> some View {
        self
    }
} 