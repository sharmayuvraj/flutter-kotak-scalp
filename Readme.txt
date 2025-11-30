# Run on macOS

# Create project
flutter create neoscalp_pro
cd neoscalp_pro


# Enable macOS
flutter config --enable-macos-desktop
flutter pub get

# Run
flutter run -d macos




git clone https://github.com/sharmayuvraj/flutter-kotak-scalp.git
cd neoscalp-macos
flutter build macos --release
open build/macos/Build/Products/Release/NeoScalp\ Pro.app
