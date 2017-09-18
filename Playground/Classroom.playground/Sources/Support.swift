import Foundation

public func example(of description: String, action: () -> Void) {
	print("\n--- Example of:", description, "---")
	action()
}

public func example(of description: String, run: Bool, action: () -> Void) {
	if run {
		print("\n--- Example of:", description, "---")
		action()
	}
}
