import XCTest
@testable import DI


final class SimpleTest: XCTestCase {
    
    func testSimple() {
        let assembly = TestAssembly()
        let cImpl = try? assembly.resolve(C.self)
        XCTAssertNotNil(cImpl)
        XCTAssertEqual(cImpl?.a.number, 555)
        XCTAssertEqual(cImpl?.b.mock, "555")
    }
    
    func testAdvanced() {
        let assembly = RootAssembly()
        let dImpl = try? assembly.resolve(D.self)
        XCTAssertNotNil(dImpl)
        XCTAssertEqual(dImpl?.c.a.number, 555)
        XCTAssertEqual(dImpl?.c.b.mock, "555")
    }
    
    func testError() {
        let assembly = ErrorAssembly()
        do {
            let _ = try assembly.resolve(B.self)
        } catch {
            guard let failure = error as? Container.Failure else {
                XCTFail()
                return
            }
            XCTAssertEqual(failure, .serviceNotFound)
        }
    }
}

internal protocol A {
    var number: Int { get }
}
internal protocol B {
    var mock: String { get }
}
internal protocol C {
    var a: A { get }
    var b: B { get }
}
internal protocol D {
    var c: C { get }
}
internal class AImpl: A {
    var number: Int = 555
}
internal class BImpl: B {
    var mock: String = "555"
}
internal class CImpl: C {
    var a: A
    var b: B
    
    init(a: A, b: B) {
        self.a = a
        self.b = b
    }
}
internal class DImpl: D {
    var c: C
    
    init(c: C) {
        self.c = c
    }
}
internal class TestAssembly: Assembly {
    override func configure(_ container: Container) {
        container.register(A.self, service: AImpl())
        container.register(B.self, service: BImpl())
        container.register(C.self) { resolver in
            let a = try resolver.resolve(A.self)
            let b = try resolver.resolve(B.self)
            return CImpl(a: a, b: b)
        }
    }
}
internal class RootAssembly: Assembly {
    override func configure(_ container: Container) {
        let testAssembly = TestAssembly()
        testAssembly.configure(container)
        container.register(D.self) { resolver in
            let c = try resolver.resolve(C.self)
            return DImpl(c: c)
        }
    }
}
internal class ErrorAssembly: Assembly {
    override func configure(_ container: Container) {}
}
