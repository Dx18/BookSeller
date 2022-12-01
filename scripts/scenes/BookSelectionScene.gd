extends CanvasLayer

# Scene where player selects books to sell

## Preloads

# Random utils
const RandomUtils = preload("res://scripts/util/RandomUtils.gd")

# Book
const Book = preload("res://scripts/Book.gd")

## Parameters

# Number of books to sell
export var books_to_select: int

## Paths to controls

# Path to book info label
export var book_info_label_: NodePath
# Path to book selection progress label
export var progress_label_: NodePath

## References to controls

# Book info label (displays title and genre)
onready var book_info_label: Label = get_node(book_info_label_)
# Book selection progresss label (displays number of selected books and number
# of books required for selection)
onready var progress_label: Label = get_node(progress_label_)

## State

# Currently displayed book
var current_book: Book
# Selected books
var selected_books = []

# Random
var random: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	random.randomize()
	
	_generate_new_book()

func _process(delta):
	if Input.is_action_just_pressed("accept"):
		selected_books.append(current_book)
		if len(selected_books) == books_to_select:
			SceneDataTransfer.selected_books = selected_books
			get_tree().change_scene("res://scenes/screens/GameScene.tscn")
		else:
			_generate_new_book()
	
	if Input.is_action_just_pressed("reject"):
		_generate_new_book()

# Generates new book
func _generate_new_book():
	current_book = Book.new(
		RandomUtils.choose_one(GameData.book_titles, random),
		RandomUtils.choose_one(GameData.book_genres, random)
	)
	_update_book_info_label()
	_update_selection_progress_label()

## UI controlling

# Updates book info label
func _update_book_info_label():
	var format = "Title: %s\nGenre: %s"
	book_info_label.text = format % [current_book.title, current_book.genre]

# Updates book selection progress label
func _update_selection_progress_label():
	var format = "%d/%d"
	progress_label.text = format % [len(selected_books), books_to_select]
