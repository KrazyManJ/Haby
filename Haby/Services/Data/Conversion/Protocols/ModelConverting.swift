
protocol ModelConverting<M> {
    associatedtype M
    func toModel() -> M
}
