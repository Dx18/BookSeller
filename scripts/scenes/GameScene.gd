extends Node

## Preloads

# Array2D
const Array2D = preload("res://scripts/util/Array2D.gd")
# Queue
const Queue = preload("res://scripts/util/Queue.gd")

# Book
const Book = preload("res://scripts/Book.gd")

# Player
const Player = preload("res://scripts/Player.gd")

# Dialog shared data
const DialogSharedData = preload("res://scripts/dialogs/DialogSharedData.gd")
# Dialog state
const DialogState = preload("res://scripts/dialogs/DialogState.gd")
# Dialog
const Dialog = preload("res://scripts/dialogs/Dialog.gd")
# Dialog UI
const DialogUI = preload("res://scripts/dialogs/DialogUI.gd")

## Parameters

# Visible tile map margin (in tiles)
export var margin: int
# How many in-game minutes is passed during one real second
export var time_scale: float
# Initial in-game time (hours)
export var start_time_hours: int
# Initial in-game time (minutes)
export var start_time_minutes: int
# Deadline (hours)
export var end_time_hours: int
# Deadline (minutes)
export var end_time_minutes: int
# Number of minutes until deadline when time label starts to show low level of
# warning
export var low_warning_minutes: int
# Number of minutes until deadline when time label starts to show high level of
# warning
export var high_warning_minutes: int

## Paths to objects

# Path to player
export var player_: NodePath
# Path to tile map
export var map_: NodePath
# Path to canvas
export var canvas_: NodePath
# Path to books label
export var books_label_: NodePath
# Path to time label
export var time_label_: NodePath
# Path to root node for all decorative objects
export var decorations_root_: NodePath
# Root node for map bounds
export var bounds_root_: NodePath

## References to objects

# Player
onready var player: Player = get_node(player_)
# Tile map
onready var map: TileMap = get_node(map_)
# UI canvas
onready var canvas: CanvasLayer = get_node(canvas_)
# Books label (the amount of books left)
onready var books_label: Label = get_node(books_label_)
# Time label (current in-game time)
onready var time_label: Label = get_node(time_label_)
# Root node for all decorative objects
onready var decorations_root: Node2D = get_node(decorations_root_)
# Root node for map bounds
onready var bounds_root: Node2D = get_node(bounds_root_)

## Scenes

# Dialog UI scene to instantiate
export var dialog_ui_scene: PackedScene

## State

# Books left to sell
var books_left: Array
# Current dialog
var current_dialog: Dialog = null
# Currently interacted object
var current_interactable: Object = null
# Current dialog UI
var current_dialog_ui: DialogUI = null
# Current time
var current_time: float = 0
# Deadline
var end_time: float = 0
# Random
var random: RandomNumberGenerator = RandomNumberGenerator.new()

# Begins dialog by disabling player's movement, setting current dialog, showing
# dialog UI and setting currently interacted object. Checks if current dialog is
# `null` and the new dialog is not `null`
func begin_dialog(interactable: Object, state: DialogState, user_data: Object):
	assert(current_dialog == null)
	assert(state != null)
	
	player.control_enabled = false
	
	current_dialog_ui = dialog_ui_scene.instance()
	canvas.add_child(current_dialog_ui)
	
	current_dialog = Dialog.new(
		state, funcref(self, "end_dialog"), funcref(self, "continue_dialog"),
		DialogSharedData.new(books_left, user_data)
	)
	current_dialog_ui.init(current_dialog)
	
	current_interactable = interactable

# Updates dialog UI
func continue_dialog():
	current_dialog_ui.update_state()

# Ends dialog by checking its result, resetting it, removing dialog UI and
# enabling player's movement. Checks if current dialog is not `null`
func end_dialog(book_sold: Book):
	assert(current_dialog != null)
	
	if book_sold != null:
		books_left.erase(book_sold)
		
		_update_books_label()
		
		if books_left.empty():
			SceneDataTransfer.books_left = 0
			
			get_tree().change_scene("res://scenes/screens/GameResult.tscn")
			return
	
	current_dialog = null
		
	current_dialog_ui.queue_free()
	current_dialog_ui = null
	
	player.control_enabled = true
	
	current_interactable.on_interaction_end()
	current_interactable = null

func _ready():
	random.randomize()
	
	books_left = SceneDataTransfer.selected_books
	current_time = start_time_hours * 60 + start_time_minutes
	end_time = end_time_hours * 60 + end_time_minutes
	
	_update_books_label()
	
	_set_collision_bounds()
	_set_z_indices()

func _process(delta):
	current_time += delta * time_scale
	
	if current_time >= end_time:
		SceneDataTransfer.books_left = len(books_left)
			
		get_tree().change_scene("res://scenes/screens/GameResult.tscn")
		return
	
	_update_time_label()

# Initializes map collision bounds
func _set_collision_bounds():
	var tile_size = map.get_cell_size()
	var rect = map.get_used_rect()
	rect.position *= tile_size
	rect.size *= tile_size
	
	# Shape for top and bottom bounds
	var shape_horizontal = RectangleShape2D.new()
	shape_horizontal.extents = Vector2(rect.size.x, 1) / 2
	
	# Top bound
	var collision_top = CollisionShape2D.new()
	collision_top.shape = shape_horizontal
	collision_top.position.x = rect.get_center().x
	collision_top.position.y = rect.position.y + (margin - 0.5) * tile_size.y
	bounds_root.add_child(collision_top)
	
	# Bottom bound
	var collision_bottom = CollisionShape2D.new()
	collision_bottom.shape = shape_horizontal
	collision_bottom.position.x = rect.get_center().x
	collision_bottom.position.y = rect.end.y - (margin - 0.5) * tile_size.y
	bounds_root.add_child(collision_bottom)
	
	# Shape for top and bottom bounds
	var shape_vertical = RectangleShape2D.new()
	shape_vertical.extents = Vector2(1, rect.size.y) / 2
	
	# Left bound
	var collision_left = CollisionShape2D.new()
	collision_left.shape = shape_vertical
	collision_left.position.x = rect.position.x + (margin - 0.5) * tile_size.x
	collision_left.position.y = rect.get_center().y
	bounds_root.add_child(collision_left)
	
	# Right bound
	var collision_right = CollisionShape2D.new()
	collision_right.shape = shape_vertical
	collision_right.position.x = rect.end.x - (margin - 0.5) * tile_size.x
	collision_right.position.y = rect.get_center().y
	bounds_root.add_child(collision_right)

# Sets Z indices for sprites
func _set_z_indices():
	map.z_index = map.get_used_rect().position.y * map.get_cell_size().y
	
	for decoration in decorations_root.get_children():
		decoration.z_index = decoration.position.y

## UI controlling

# Updates books label
func _update_books_label():
	books_label.text = str(len(books_left))

# Updates time label
func _update_time_label():
	var minutes = int(current_time) % 60
	var hours = int(current_time / 60) % 24
	time_label.text = "%02d:%02d" % [hours, minutes]
	
	if end_time - current_time <= high_warning_minutes:
		time_label.theme_type_variation = "HighWarningLabel"
	elif end_time - current_time <= low_warning_minutes:
		time_label.theme_type_variation = "LowWarningLabel"
