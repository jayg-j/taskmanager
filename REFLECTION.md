# Reflection

## Why use a repository instead of calling SQLite from the UI?

The UI (`TaskListScreen`) only talks to `TaskRepository` for loading, inserting, updating, and deleting tasks. `DatabaseHelper` owns connection setup, the file path (`path` + `getDatabasesPath()`), and the `CREATE TABLE` statement. This keeps widgets focused on presentation and validation, makes SQL easier to change in one place, and allows tests to inject a fake repository without opening a real database.

## Why SQLite (sqflite) instead of an in-memory list?

An in-memory list is lost when the process ends. `sqflite` stores rows in a file on the device, so tasks survive app restarts. The schema (`id` auto-increment, `title`, `is_completed`) matches the assignment and maps cleanly to the `Task` model via `fromMap` / `toMap`.

## How does async/await fit in?

Database I/O is asynchronous. Methods such as `getAllTasks`, `insertTask`, and `_loadTasks` return `Future`s and use `await` so the UI does not block while SQLite runs. After each successful write, `_loadTasks` runs again so the list always reflects what is actually in the database.

## How are invalid titles and errors handled?

Before insert, the title is trimmed; empty or whitespace-only input shows a snackbar and never calls the repository. On failure, `catch` blocks show an error snackbar and do not claim success—failed adds do not clear the field as a “success” path, and the list is only refreshed after operations that complete without throwing.

## Design choices in the UI

A single screen provides a text field, Add button, and a list with checkboxes (complete) plus delete (icon and swipe-to-dismiss). A loading indicator appears on first open while tasks are fetched. Completion is shown with strikethrough text for quick visual feedback.
