extends CanvasLayer

# Main menu scene

## Parameters

# Time to wait before continuing
export var waiting_time: float

## Paths to controls

## Path to prompt label
export var prompt_label_: NodePath

## References to controls

# Prompt label (displays a prompt to start a game)
onready var prompt_label: Label = get_node(prompt_label_)

## State

# Whether player can continue
var can_continue: bool = false

func _ready():
	prompt_label.visible = false
	
	yield(get_tree().create_timer(waiting_time), "timeout")
	
	prompt_label.visible = true
	can_continue = true

func _process(delta):
	# Pressing an accept key after some waiting will start game
	if can_continue and Input.is_action_just_pressed("accept"):
		get_tree().change_scene("res://scenes/screens/BookSelection.tscn")
