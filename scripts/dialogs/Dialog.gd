# Dialog state machine

## Preloads

# Book
const Book = preload("res://scripts/Book.gd")

# Dialog shared data
const DialogSharedData = preload("res://scripts/dialogs/DialogSharedData.gd")
# Dialog state
const DialogState = preload("res://scripts/dialogs/DialogState.gd")

## State

# Current state
var state: DialogState
# Dialog result callback. Called with `null` if no book was sold or with an
# instance of `Book` if a book was sold
var end_callback: FuncRef
# Dialog state transition callback
var transition_callback: FuncRef
# Data exposed to all states
var data: DialogSharedData

func _init(
	state: DialogState, end_callback: FuncRef, transition_callback: FuncRef,
	data: DialogSharedData
):
	self.state = state
	self.end_callback = end_callback
	self.transition_callback = transition_callback
	self.data = data
	
	self.state.init(self.data)

# Submits answer to dialog
func submit_answer(index: int):
	var result = self.state.submit_answer(data, index)
	if result == null:
		state = null
		end_callback.call_func(null)
	elif result is Book:
		state = null
		end_callback.call_func(result)
	else:
		assert(
			result is DialogState,
			"Result must be either `null`, `Book` or `DialogState`"
		)
		state = result
		state.init(data)
		transition_callback.call_func()
