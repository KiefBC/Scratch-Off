//
//  ContentView.swift
//  Scratch Off
//
//  Created by Kiefer Hay on 2025-04-09.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    @State private var fadePoints: [FadePoint] = [] // Store the fade points
    @State private var resetScratch: Bool = false // Reset the scratch state
    @State private var fadingTimerActive: Bool = true // Track if the fading timer is active
    @State private var fadingTime: Timer? // Hold the timer reference
    @State private var isResetting: Bool = false // Track if the scratch is resetting
    
    let fadeDuration: TimeInterval = 0.25 // Duration of the fade effect
    let radius: CGFloat = 35 // Radius of the mouse path
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geomtry in
            ZStack {
                // Layer to hold the scratchable area
                LinearGradient(colors: [.black, .black.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                // Hidden Image
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geomtry.size.width, height: geomtry.size.height)
                    .clipped()
                    .mask( // Using a mask to hide the image
                        Canvas { (context, size) in // Using a canvas to draw the image
                            for (ix, point) in fadePoints.enumerated() {
                                let gradient: Gradient = Gradient(stops: [.init(color: .white, location: 0), .init(color: .white.opacity(0), location: 1)]) // Gradient for the mask
                                
                                context.fill( // Fill the path with the gradient
                                    Path(ellipseIn: CGRect(x: point.location.x - radius, y: point.location.y - radius, width: radius * 2, height: radius * 2)), with: .radialGradient(gradient, center: point.location, startRadius: 0, endRadius: radius + CGFloat(ix + 1)))
                            }
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0) // Set the minimum distance to 0 to immedietly activate the Scratch Effect
                            .onChanged({ value in
                                fadePoints.append(FadePoint(location: value.location, timestamp: Date())) // Create a new fade point
                            })
                        )
                    .overlay(alignment: .topTrailing) {
                        HStack {
                            Button {
                                withAnimation(.smooth) {
                                    resetScratch.toggle() // Toggle the reset state
                                }
                                
                                removeFadePoints() // Remove the fade points
                            } label: {
                                Image(systemName: "arrowshape.turn.up.left.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .symbolEffect(.rotate, value: resetScratch)
                            }
                            .frame(width: 32, height: 32)
                            .opacity(!fadingTimerActive ? 1 : 0.3) // Opac the button when the fading timer is active
                            .disabled(fadingTimerActive) // Disable the button when the fading timer is active
                            
                            Button {
                                withAnimation(.smooth) {
                                    fadingTimerActive.toggle()
                                }
                                
                                setFadingTimerState() // Toggle the fading timer state
                            } label: {
                                Image(systemName: fadingTimerActive ? "circle.slash" : "circle")
                                    .font(.system(size: 20, weight: .semibold))
                                    .symbolEffect(.bounce, options: .repeat(2), value: fadingTimerActive)
                                    .symbolEffect(.rotate, value: fadingTimerActive)
                            }
                            .frame(width: 32, height: 32)
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 64)
                        .padding(.horizontal, 32)
                    }
            }
            .onAppear {
                // Start the fading timer when the view appears
                startFadingTimer()
            }
        }
        .preferredColorScheme(.dark) // Set the preferred color scheme to dark
        .ignoresSafeArea() // Ignore safe area to cover the entire screen
    }
    
    // MARK: - Functions
    
    /// Updates and then checks the Points every 0.001s to remove the Expired Points to create a Fade-Out effect
    func startFadingTimer() {
        fadingTime = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { _ in
            let currTime: Date = Date()
            fadePoints.removeAll { point in
                currTime.timeIntervalSince(point.timestamp) > fadeDuration // Remove points that have expired
            }
        })
    }
    
    /// Function to reset the timer
    func setFadingTimerState() {
        if fadingTime == nil { // If the timer is not running, start it
            startFadingTimer()
        } else {
            fadingTime?.invalidate() // Stop the timer and set it to nil
            fadingTime = nil
        }
    }
    
    /// Removes the FadePoints to reset the scratch effect
    func removeFadePoints() {
        Task {
            isResetting = true
            let points = fadePoints
            
            for (ix, point) in points.enumerated() {
                // Still use a small delay between each point removal for the animation effect
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
}

#Preview {
    ContentView()
}
