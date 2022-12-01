extends "res://scripts/GameCharacter.gd"

# Autonomous citizen

## Preloads

# Game scene
const GameScene = preload("res://scripts/scenes/GameScene.gd")
# Dialog shared data
const DialogSharedData = preload("res://scripts/dialogs/DialogSharedData.gd")
# Dialog state
const DialogState = preload("res://scripts/dialogs/DialogState.gd")
# Dialog
const Dialog = preload("res://scripts/dialogs/Dialog.gd")
# Default citizen dialog states
const DefaultCitizenDialogs = preload("res://scripts/dialog_ai/DefaultCitizenDialogs.gd")

## State

# Points of path current citizen following
var points: Array
# Index of next point
var index: int = 0
# Whether citizen is currently moving
var movement_enabled: bool = true
# Citizen dialog states
var dialogs: DefaultCitizenDialogs

## Signals

# Emitted when current citizen leaves map
signal left_map

## References to objects

# Game controller
onready var game_scene: GameScene = get_node("/root/GameScene")

func init(points: Array, dialogs: DefaultCitizenDialogs):
	self.points = points
	self.dialogs = dialogs
	
	update_point_index()

func _process(delta):
	if not movement_enabled:
		move_direction = Vector2.ZERO
		return
	
	update_point_index()

	move_direction = points[index] - position

# Updates current point index if necessary
func update_point_index():
	var target = points[index]
	if position.distance_to(target) < 1:
		if index + 1 < points.size():
			index += 1
			target = position if index == points.size() else points[index]
		else:
			emit_signal("left_map")
			queue_free()

# Invoked when player begins interaction with citizen
func on_interaction_begin():
	movement_enabled = false
	game_scene.begin_dialog(self, dialogs.create_state(), dialogs)

# Invoked when player finishes interaction with citizen
func on_interaction_end():
	movement_enabled = true

# Enables citizen highlighting
func highlight():
	sprite.modulate = Color.yellow

# Disables citizen highlighting
func unhighlight():
	sprite.modulate = Color.white
