# Data exposed to all dialog states

## State

# Array of available books
var books: Array
# User data
var user_data

func _init(books: Array, user_data):
	self.books = books
	self.user_data = user_data
