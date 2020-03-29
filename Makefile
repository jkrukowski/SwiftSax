lint:
	mint run swiftformat --lint --config .swiftformat

format:
	mint run swiftformat

build:
	swift build

test:
	swift test --enable-test-discovery

xcode:
	swift package generate-xcodeproj --enable-code-coverage
