build:
	swift build -Xcc -I/usr/local/opt/libxml2/include/libxml2

test:
	swift test -Xcc -I/usr/local/opt/libxml2/include/libxml2 -Xlinker -lxml2

xcode:
	swift package generate-xcodeproj --xcconfig-overrides swiftsax.xcconfig