import UIKit

protocol ModelConverting<M> {
    associatedtype M: Identifiable<UUID>
    func toModel() -> M
}
