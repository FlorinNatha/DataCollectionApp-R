# Bell Pepper Data Collection App

A specialized Flutter application designed for Final Year Research Projects (FYP) in smart agriculture. 

## 🌟 Features
- **Multimodal Data Collection**: Capture leaf images and manually enter 7-in-1 NPK sensor data.
- **Offline Storage**: Uses SQLite to save all records locally—no internet required in the field.
- **Structured Dataset**: Specific classes for Bell Pepper diseases (Bacterial Spot, Anthracnose, etc.).
- **Dataset Export**: One-tap export of all data as a CSV file and a ZIP folder containing all images.

## 🛠️ How to Run
1. Install Flutter (https://docs.flutter.dev/get-started/install)
2. Open this folder in VS Code or Android Studio.
3. Run `flutter pub get` to install dependencies.
4. Connect your phone or start an emulator.
5. Run `flutter run`.

## 📂 Project Structure
- `lib/models/`: Data structure for plant samples.
- `lib/services/`: Database (SQLite) and Export (CSV/ZIP) logic.
- `lib/screens/`: UI screens for Home, Adding Samples, and Viewing Records.

## 📄 License
This project is created for academic research purposes.
