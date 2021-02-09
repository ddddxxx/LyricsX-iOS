import Foundation
import ComposableArchitecture

public struct UISchedularEnvironment {
    public let uiSchedular: DispatchQueue
    
    public init(uiSchedular: DispatchQueue = .main) {
        self.uiSchedular = uiSchedular
    }
    
    public static let `default` = UISchedularEnvironment()
}
