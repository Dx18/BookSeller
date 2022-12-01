extends Control

# Dialog UI controller

## Preloads

# Dialog state
const DialogState = preload("res://scripts/dialogs/DialogState.gd")
# Dialog
const Dialog = preload("res://scripts/dialogs/Dialog.gd")

## Paths to controls

# Path to dialog question label
export var question_label_: NodePath
# Path to dialog answers' parent
export var answer_labels_parent_: NodePath

## Controls

# Dialog question label
var question_label: Label
# Dialog answers' parent
var answer_labels_parent: Control

## State

# Current dialog
var current_dialog: Dialog
# Currently pointed answer
var current_pointer: int
# Number of answers
var answer_count: int

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		current_dialog.submit_answer(current_pointer)
		return
	
	if Input.is_action_just_pressed("move_down"):
		current_pointer = (current_pointer + 1) % answer_count
		_update_highlighted_answer_label()
	
	if Input.is_action_just_pressed("move_up"):
		current_pointer = (answer_count + current_pointer - 1) % answer_count
		_update_highlighted_answer_label()

# Initializes dialog UI with given dialog
func init(dialog: Dialog):
	question_label = get_node(question_label_)
	answer_labels_parent = get_node(answer_labels_parent_)
	
	current_dialog = dialog
	
	update_state()

# Updates dialog UI. Called when dialog state is changed
func update_state():
	var state: DialogState = current_dialog.state
	
	question_label.text = state.question
	
	current_pointer = 0
	answer_count = len(state.answers)
	
	while answer_labels_parent.get_child_count() < answer_count:
		var label = Label.new()
		label.theme = theme
		label.align = Label.ALIGN_CENTER
		label.autowrap = true
		answer_labels_parent.add_child(label)
	
	for i in range(answer_count, answer_labels_parent.get_child_count()):
		answer_labels_parent.get_child(i).queue_free()
	
	for i in range(answer_count):
		answer_labels_parent.get_child(i).text = state.answers[i]
	
	_update_highlighted_answer_label()

# Updates currently highlighted answer label
func _update_highlighted_answer_label():
	var answers = current_dialog.state.answers
	
	for i in range(len(answers)):
		var label: Label = answer_labels_parent.get_child(i)
		if i == current_pointer:
			label.text = "> %s" % answers[i]
			label.theme_type_variation = "SelectedLabel"
		else:
			label.text = answers[i]
			label.theme_type_variation = ""
