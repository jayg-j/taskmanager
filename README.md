# Local Task Manager

Flutter app that persists tasks with **sqflite** and a **repository** layer.

## Setup

Install [Flutter](https://docs.flutter.dev/get-started/install), then from this folder:

```bash
flutter create . --project-name local_task_manager
flutter pub get
flutter run
```

If you already have platform folders from `flutter create`, only run `flutter pub get` and `flutter run`.

## Features

- Add tasks (non-empty title required)
- List tasks on launch; list refreshes after add, complete, or delete
- Mark tasks complete / incomplete
- Delete via trash icon or swipe
- Data survives app restarts (SQLite)

See [REFLECTION.md](REFLECTION.md) for design notes.
