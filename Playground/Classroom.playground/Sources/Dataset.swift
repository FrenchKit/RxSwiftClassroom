import Foundation

public func rand(_ maxValue: Int) -> Int {
	return Int(arc4random_uniform(UInt32(maxValue)))
}

public func randomDelay(_ maxDelay: Double) -> Double {
	return Double(arc4random_uniform(UInt32(maxDelay * 100))) / 100.0
}

public func randomString() -> String {
	return capitals[rand(capitals.count)]
}

public enum SomeError: Error {
	case failed
}

public extension Array {
	public var randomIndex: Array.Index {
		return rand(self.count)
	}
}

public let capitals = ["Tirana",
                "Andorra la Vella",
                "Yerevan",
                "Vienna",
                "Baku",
                "Minsk",
                "Brussels",
                "Sarajevo",
                "Sofia",
                "Zagreb",
                "Nicosia",
                "Prague",
                "Copenhagen",
                "Tallinn",
                "Helsinki",
                "Paris",
                "Tbilisi",
                "Berlin",
                "Athens",
                "Budapest",
                "Reykjavik",
                "Dublin",
                "Rome",
                "Astana",
                "Pristina",
                "Riga",
                "Vaduz",
                "Vilnius",
                "Luxembourg",
                "Skopje",
                "Valletta",
                "Chisinau",
                "Monaco",
                "Podgorica",
                "Amsterdam",
                "Oslo",
                "Warsaw",
                "Lisbon",
                "Bucharest",
                "Moscow",
                "San Marino",
                "Belgrade",
                "Bratislava",
                "Ljubljana",
                "Madrid",
                "Stockholm",
                "Bern",
                "Ankara",
                "Kyiv",
                "London",
                "Vatican City"]
