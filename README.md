# 🧹 unused_assets_removal

A CLI tool to scan and delete unused asset files in your Flutter project. Optimize your app size and keep your project clean!

---

## 🚀 Features

- ✅ Detect unused image assets in your Flutter project.
- 🗑 Option to delete them automatically.
- 🧠 Supports common asset usage patterns like `AssetImage`, `Image.asset`, etc.
- ⚡ Fast, simple, and easy to use.

---

## 📦 Installation

Clone the repo locally and run it directly using Dart:

```bash
git clone https://github.com/3boodev/unused_assets_removal
cd unused_assets_removal
dart pub get
```
## - OR ADD TO dev_dependencies in pubspec.yaml
```bash
  dev_dependencies:
    unused_assets_removal:
     git:
      url: https://github.com/3boodev/unused_assets_removal
```
## - OR USE It as Globally
```bash
  dart pub global activate unused_assets_removal
```

## 🛠 Usage

1. Detect unused assets

```bash
   dart run unused_assets_removal --dry-run
```
2. Delete unused assets

```bash
   dart run unused_assets_removal --delete
```
3. Change Assets path to your Flutter project

```bash
   dart run unused_assets_removal --assets-path=assets/images
```
4. Set Location of Assets report

```bash
   dart run unused_assets_removal --dry-run --log-path=report.txt
```
## 🧾CLI Options:

Option | Alias | Description
--path | -p | Path to your Flutter project (required)
--delete | -d | Delete unused assets (optional)
--help | -h | Show help menu

## 📁 What It Scans

- Assets: All images defined under flutter/assets in your pubspec.yaml.
  - References: Any asset referenced using:
      AssetImage('assets/image.png')
      Image.asset('assets/image.png')
      ExactAssetImage('assets/image.png')
- JSON or Dart files containing string references to assets.

## ❌ What It Does NOT Support (yet)

Dynamic asset references (e.g., assets loaded by variable names).
Localization-specific assets or platform-specific folders.
Want to help improve it? Contributions are welcome! 🙌

## ✅ Example

```bash
   dart run unused_assets_removal
```

## Output:

Scanning assets...
Found 38 assets
Found 29 used assets
Unused assets:
- assets/images/old_logo.png
- assets/icons/temp_icon.png

## To delete them:

```bash
dart run unused_assets_removal --delete
```
## 📌 Roadmap

- Detect unused fonts and other resource types.
- Integration with CI pipelines.
- Configurable exclusion rules.

## 👨‍💻 Author

- Built with ❤️ by <a href="https://github.com/3boodev">Abdullah Alamary</a>

## 📝 License

- This project is licensed under the MIT License. See the LICENSE file for details.

