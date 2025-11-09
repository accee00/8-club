# 🌟 eightclub: Interactive Onboarding & Question Experience

## ✨ Features

### 🎯 **Experience Type Selection Screen**

The initial screen provides an intuitive interface for users to select their preferred experience types.

#### **Video Link**
 - IOS = https://drive.google.com/file/d/1Trms9u_q_Fg22UYUap8K8Qk15lB70TOJ/view?usp=drive_link
 - ANDROID = https://drive.google.com/file/d/188HOfj3pfF6YaIcrtYFn8wbO1gI72Z2x/view?usp=drive_link

#### **Core Functionality**
- ✅ **Interactive Card Selection** - Tap to select/deselect experience cards with smooth animations
- ✅ **Visual Feedback**
  - Selected cards display in full color with distinctive styling
  - Unselected cards automatically convert to **grayscale** for clear visual distinction
  - Selected card **smoothly animates to the first position** ⭐
- ✅ **Multiple Selection Support** - Choose one or more experience types simultaneously
- ✅ **Rich Text Input** - Multi-line text field with **250-character limit**
- ✅ **Smart State Management** - Selected IDs and text input persist across navigation
- ✅ **Seamless Navigation** - Console logging of state before transitioning to next screen

---

### 📝 **Onboarding Question Screen**

An advanced screen designed to capture diverse user responses through multiple input methods.

#### **Input Capabilities**
- ✅ **Flexible Text Input** - Multi-line text field supporting up to **600 characters**
- ✅ **Media Recording**
  - 🎙️ Audio recording with **real-time waveform visualization** ⭐
  - 🎥 Video recording with preview
  - Dynamic UI that **removes record buttons** after successful capture
  
#### **Recording Controls**
- ✅ **Start, pause, and cancel** recording mid-session
- ✅ **Delete recorded assets** with confirmation ⭐
- ✅ **Visual feedback** during recording process
- ✅ **Animated Transitions** - Smooth width animation of Next button ⭐

---

## 🎨 Design Principles

### **UI/UX Excellence**

- 🎯 **Pixel-Perfect Implementation** - Strict adherence to Figma design specifications
- 📱 **Fully Responsive** - Seamless adaptation to all screen sizes and orientations
- 🎨 **Consistent Aesthetics** - Uniform spacing, typography, and color schemes
- ⌨️ **Smart Keyboard Handling** - Prevents layout issues during viewport changes ⭐

---

## ⚙️ Technical Implementation

### **Architecture**
```
lib/
├── core/
│   ├── constants/
│   ├── di/                    # Dependency Injection
│   ├── dio/                   # Network configuration
│   ├── error/                 # Error handling
│   ├── extensions/            # Dart extensions
│   ├── logger/                # Logging utilities
│   └── widgets/               # Reusable core widgets
├── features/
│   ├── experience_selection/
│   │   ├── models/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── view/
│   │           └── selection.dart
│   └── onboard/
│       └── presentation/
├── service/
│   └── get_experience_service.dart
└── main.dart
```

### **Installation**

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/eightclub.git
cd eightclub
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```



## ⭐ Brownie Points Implemented

| Feature | Status | Description |
|---------|--------|-------------|
| 🎬 Card Selection Animation | ✅ | Selected card animates to first position |
| 📊 BLoC Implementation | ✅ | For state management |
| ↔️ Button Width Animation | ✅ | Smooth Next button transition |
| 🗑️ Dio | ✅ | Use Dio to call API. |
| ⌨️ Keyboard Handling | ✅ | Responsive viewport adjustments |

## ⭐ Extra Feature

| Feature | Status | Description |
|---------|--------|-------------|
| Custom Logger |  ✅ | Logger to print error, success, and info.|
| ↔️ Added LoggerInterceptor on Dio | ✅ | To log each req, error, response of API. |
| ↔️ Functional Programming | ✅ | To get custom failure or success on each api call |





---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Web | 🚧 |
| Desktop | 🚧 |

---
