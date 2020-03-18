# SwiftSax

Sax parser based on libxml2

## Example usage

```swift
// let data = ...

let parser = try Parser(data: data)
let result = try parser.find(path: "//div[@class='some']")
```

## Build

```bash
make build
```

## Test

```bash
make test
```

## Generate Xcode project

```bash
make xcode
```

## Format code

```bash
make format
```
