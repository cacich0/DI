import Foundation

open class Assembly {
    
    private var container: Container?
    
    public init() {}
    
    open func configure(_ container: Container) {}
    
    public func resolve<Service>(_ type: Service.Type) throws -> Service {
        if let container {
            return try container.resolve(type)
        } else {
            let container = Container()
            configure(container)
            let service = try container.resolve(type)
            self.container = container
            return service
        }
    }
    
    public func add<Dependency>(_ type: Dependency.Type, dependency: Dependency) {
        if let container {
            container.register(Dependency.self, service: dependency)
        } else {
            let container = Container()
            container.register(Dependency.self, service: dependency)
            configure(container)
            self.container = container
        }
    }
}
public final class Container {
    
    var resolver = Resolver()
    
    @discardableResult
    public func register<Service>(
        _ type: Service.Type,
        service: @autoclosure () -> Service
    ) -> Service {
        let service = service()
        resolver.add(service, for: "\(type)")
        return service
    }
    @discardableResult
    public func register<Service>(
        _ type: Service.Type,
        resolve: (Resolver) throws -> Service
    ) -> Service? {
        guard let service = try? resolve(resolver) else { return nil }
        register(type, service: service)
        return service
    }
    public func resolve<Service>(
        _ type: Service.Type
    ) throws -> Service {
        return try resolver.resolve(type)
    }
}

extension Container {
    
    public final class Resolver {
        var services: [String: Any] = [:]
        
        internal init() {}
        
        internal func add(_ service: Any, for type: String) {
            services[type] = service
        }
        public func resolve<Service>(_ type: Service.Type) throws -> Service  {
            guard let service = services["\(type)"] else { throw Failure.serviceNotFound }
            guard let casted = service as? Service else { throw Failure.notExpectedType }
            return casted
        }
    }
}

extension Container {
    public enum Failure: Error {
        case serviceNotFound
        case notExpectedType
    }
}

