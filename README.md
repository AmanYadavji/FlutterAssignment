# Velocity Flutter

A Flutter app demonstrating smooth paddle motion using interpolation, `CustomPainter` rendering, touch input tracking, and real-time frame updates using `Ticker`. The app includes boundary handling and an FPS counter for performance visualization.

---

## How to Run

Make sure Flutter SDK is installed:  
https://docs.flutter.dev/get-started/install

Then run the following commands:

flutter pub get
flutter run

# How interpolation works:
Interpolation is used so the paddle don't move instantly to where the finger is. Instead, every frame it moves just a small part toward the target position. This makes the movement look smooth and not jumpy. If the smoothing value is small, the paddle moves slower and softer. If it’s bigger, it follows faster. This makes the motion feel more natural, kinda like it has momentum.

# How FPS was calculated:
To get the FPS, the app just counts how many frames got drawn in one second. Each time a frame updates, the counter go up by one. After one second passes, that number is shown as the FPS and then the counter resets. This repeats over and over, so the FPS updates every second and shows how good the performance is running.

