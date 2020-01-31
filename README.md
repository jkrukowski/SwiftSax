# SwiftSax

## Build

```bash
swift build -Xcc -I/usr/local/opt/libxml2/include/libxml2
```

## Test

```bash
swift test -Xcc -I/usr/local/opt/libxml2/include/libxml2 -Xlinker -lxml2
```

## Generate Xcode project

```bash
swift package generate-xcodeproj  --enable-code-coverage --xcconfig-overrides swiftsax.xcconfig
```

## Source

* https://blog.mro.name/2019/07/swift-libxml2-html/
* http://blog.raymccrae.scot/2018/09/wrapping-c-function-callbacks-to-swift.html
