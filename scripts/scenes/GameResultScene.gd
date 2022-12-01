extends CanvasLayer

# Scene which is opened when player ends game session

## Parameters

# Time to wait before continuing
export var waiting_time: float

## Paths to controls

# Path to title label
export var title_label_: NodePath
# Path to prompt label
export var prompt_label_: NodePath

## References to controls

# Title label (displays result)
onready var title_label: Label = get_node(title_label_)
# Prompt label (displays prompt to continue)
onready var prompt_label: Label = get_node(prompt_label_)

## State

# Whether player can continue
var can_continue: bool = false

func _ready():
	var books_left = SceneDataTransfer.books_left
	
	if books_left == 0:
		title_label.text = "Congratulations! You have sold all the books!"
	else:
		var format = "What a pity! You haven't sold %d book(s)!"
		title_label.text = format % books_left
	
	prompt_label.visible = false
	
	yield(get_tree().create_timer(waiting_time), "timeout")
	
	prompt_label.visible = true
	can_continue = true

func _process(delta):
	# Pressing an accept key after some waiting will return player to main menu
	if can_continue and Input.is_action_just_pressed("accept"):
		get_tree().change_scene("res://scenes/screens/MainMenu.tscn")
