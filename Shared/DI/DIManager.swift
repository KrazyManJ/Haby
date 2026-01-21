import Foundation

final class DIContainer {
    typealias Resolver = () -> Any
    
    private struct Dependency {
        let resolver: Resolver
        let cached: Bool
    }

    private var dependencies = [String: Dependency]()
    private var cache = [String: Any]()

    static let shared = DIContainer()

    init() {
        registerDependencies()
    }

    func register<T, R>(_ type: T.Type, cached: Bool = true, dependencyResolver: @escaping () -> R) {
        let key = String(reflecting: type)
        dependencies[key] = Dependency(resolver: dependencyResolver, cached: cached)
    }

    func resolve<T>() -> T {
        let key = String(reflecting: T.self)

        if let cachedService = cache[key] as? T {
            print("🥣 Resolving cached instance of \(T.self).")
            return cachedService
        }

        guard let config = dependencies[key] else {
            fatalError("🥣 \(key) has not been registered.")
        }

        guard let service = config.resolver() as? T else {
            fatalError("🥣 \(key) could not be cast to \(T.self)")
        }
        
        if config.cached {
            print("🥣 Creating and caching new instance of \(T.self).")
            cache[key] = service
        } else {
            print("🥣 Creating new non-cached instance of \(T.self).")
        }

        return service
    }
}
