# SwiftUI Scratch-Off Implementation

This project implements a digital scratch-off ticket experience similar to lottery scratch cards using SwiftUI. The implementation provides a realistic scratching mechanism with fade effects and control options.

## Core Components

### State Management
```swift
@State private var fadePoints: [FadePoint] = [] // Store scratch locations
@State private var resetScratch: Bool = false   // Control reset animation
@State private var fadingTimerActive: Bool = true // Control fading effect
@State private var fadingTime: Timer?          // Timer for fade animation
```

### Configuration Constants
```swift
let fadeDuration: TimeInterval = 0.25 // Duration of scratch mark visibility
let radius: CGFloat = 35              // Size of scratch marks
```

## Key Features

### 1. Layer Structure
The view uses a ZStack to create the scratch-off effect:
- Top Layer: Black gradient simulating scratch-off material
- Bottom Layer: Hidden image that's revealed when scratched

### 2. Scratch Mechanism
Uses SwiftUI Canvas to create realistic scratch marks:
```swift
Canvas { (context, size) in
    for (ix, point) in fadePoints.enumerated() {
        // Creates radial gradient-based scratch marks
        // Each mark reveals the underlying image
    }
}
```

### 3. Interactive Features

#### Gesture Recognition
```swift
DragGesture(minimumDistance: 0)
    .onChanged({ value in
        fadePoints.append(FadePoint(location: value.location, timestamp: Date()))
    })
```
- Tracks finger/mouse movement
- Creates scratch points in real-time
- Zero minimum distance for immediate response

#### Control Buttons
- Reset Button: Clears all scratch marks with animation
- Timer Toggle: Controls automatic fade-out of scratch marks

### 4. Special Effects

#### Fading Timer
```swift
func startFadingTimer() {
    fadingTime = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
        let currTime: Date = Date()
        fadePoints.removeAll { point in
            currTime.timeIntervalSince(point.timestamp) > fadeDuration
        }
    }
}
```
- Checks every millisecond for expired scratch marks
- Removes marks older than fadeDuration
- Creates smooth fade-out effect

#### Reset Animation
```swift
func removeFadePoints() {
    Task {
        isResetting = true
        let points = fadePoints
        
        for (ix, point) in points.enumerated() {
            try? await Task.sleep(for: .milliseconds(7.5))
            
            await MainActor.run {
                withAnimation(.default) {
                    fadePoints.removeAll { $0.id == point.id }
                }
            }
        }
        isResetting = false
    }
}
```
- Uses modern async/await pattern
- Sequentially removes scratch marks
- Creates animated reset effect

## Data Model

### FadePoint Structure
```swift
struct FadePoint: Identifiable {
    let id = UUID()
    var location: CGPoint
    var timestamp: Date
}
```
Represents each scratch mark with:
- Unique identifier
- Position coordinates
- Creation timestamp

## Technical Considerations

### GeometryReader Usage
The implementation uses GeometryReader to:
- Ensure proper sizing of scratch area
- Maintain responsive layout
- Guarantee precise alignment of mask and image

### Animation and Timing
- Uses SwiftUI's native animation system
- Implements custom timing for fade effects
- Provides smooth transitions for all user interactions

## User Experience Features

- Realistic scratching behavior
- Smooth fade-out effects
- Responsive controls
- Reset capability
- Toggle for persistent/fading scratch marks

## Implementation Benefits

1. **Performance**: Efficient canvas-based rendering
2. **Maintainability**: Modern SwiftUI patterns
3. **Flexibility**: Customizable parameters
4. **User Experience**: Smooth, realistic interactions
5. **Responsiveness**: Adapts to different screen sizes

## Future Enhancements

Potential areas for improvement:
- Customizable scratch patterns
- Sound effects
- Haptic feedback
- Multiple scratch layers
- Progress tracking
- Win condition detection

## Requirements

- iOS 15.0+
- SwiftUI
- Xcode 13.0+
