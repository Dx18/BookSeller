extends Node

# Global state used for transferring data between scenes

## `BookSelectionScene` -> `GameScene`

# Array of selected books
var selected_books: Array

## `GameScene` -> `GameResultScene`

# Number of books not sold
var books_left: int
