# 🎬 Act 2

Act 2 (or `ActTwo`) is a simple game engine for making text-based adventure games using JSON. This project is named after and fully backwards compatible with Dimitri Wayland's original [Act game engine](https://github.com/tonytins/act).

## 📦 Installation

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/tonytins/act2.git", branch: "main"),
    ],
    targets: [
        .executableTarget(name: "<your-game>", dependencies: [
            // other dependencies
            .product(name: "ActTwo", package: "act2"),
        ]),
        // other targets
    ]
)
```

Or in Xcode: File -> Add Package Dependencies, then paste the repo URL.

#### 🚀 Usage

```swift
let world = try JSONDecoder().decode(GameWorld.self, from: Data(jsonFile.utf8))
guard var engine = GameEngine(world: world, startRoomName: "start") else {
    print("Couldn't load Act 2")
    return
}

print(engine.currentRoom.scene)
```

### ✅ Supported Versions

| act2    | Minimum Swift Version |
| ------- | --------------------- |
| ``main`` | 6.0                   |

## ⚖️  License

I hereby waive this project's copyright and place it the public domain - see [UNLICENSE](LICENSE) for details.
