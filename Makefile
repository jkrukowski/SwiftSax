format:
	cd BuildTools && swift run -c release swiftformat ../

build:
	swift build

test:
	swift test --enable-test-discovery

xcode:
	swift package generate-xcodeproj --enable-code-coverage
