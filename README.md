# EchoRead

EchoRead is a smart bookshelf app that lets you seamlessly read eBooks and listen to audiobooks anytime, anywhere. Your personal library is always at your fingertips, offering a convenient and immersive reading and listening experience.

---

## Features

* **Read eBooks:** Enjoy your favorite books with a customizable reading experience.
* **Listen to Audiobooks:** Switch to audio and listen to your books on the go.
* **Smart Bookshelf:** Organize and manage your entire collection with ease.
* **Anytime, Anywhere Access:** Your library is accessible across devices, ensuring you can pick up where you left off.

---

## Getting Started

To get EchoRead up and running, you'll need to set up your environment variables for Cloudinary and Firebase.

### Environment Variables

Create a **`.env`** file in the root of your project and populate it with your credentials:

```.env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
FIREBASE_DATABASE_URL=your_firebase_database_url
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_firebase_messaging_sender_id
FIREBASE_APP_ID=your_firebase_app_id
```

**Replace the placeholder values** with your actual Cloudinary and Firebase API keys and other configurations.

---

## Technologies Used

* **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
* **Cloudinary:** For cloud-based image and video management, likely used for book cover images and potentially audiobook files.
* **Firebase:** Provides a robust backend for user authentication, real-time database capabilities (for managing user libraries and book data), and cloud storage.

---

## Installation

To get EchoRead running on your local machine, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/aung-khantkyaw/echoread
    cd echoread
    ```
2.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```
    This command will launch the app on your connected device or emulator.

---

## Contributing

EchoRead is proudly developed through a collaboration between "Mobile Flutter Online Class" by **Techal Florance**, **Polytechnic University (Maubin) Faculty of Computing**, and **University of Computer Studies (Taunggyi)**.
