extends "res://scripts/GameCharacter.gd"

# Controlable player

## Parameters

# Distance necessary for interaction
export var interaction_distance: float

## State

# Whether it is possible to control player's movement
var control_enabled: bool = true
# Closest available interactable
var current_interactable: Object = null

func _process(delta):
	move_direction = Vector2.ZERO
	
	# Skipping input handling if control is disabled
	if not control_enabled:
		return
	
	# Movement
	if Input.is_action_pressed("move_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		move_direction.y += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	
	# Interacting
	update_closest_interactable()
	if Input.is_action_just_pressed("interact") and current_interactable != null:
		current_interactable.on_interaction_begin()

func update_closest_interactable():
	# Citizen might have left the map
	if not is_instance_valid(current_interactable):
		current_interactable = null
	
	var closest_interactable = null
	var min_distance = INF
	
	for interactable in get_tree().get_nodes_in_group("interactable"):
		var distance = position.distance_squared_to(interactable.position)
		if distance < min_distance:
			closest_interactable = interactable
			min_distance = distance
	
	if min_distance < interaction_distance * interaction_distance:
		if closest_interactable != current_interactable:
			if current_interactable != null:
				current_interactable.unhighlight()
			closest_interactable.highlight()
			current_interactable = closest_interactable
	elif current_interactable != null:
		current_interactable.unhighlight()
		current_interactable = null
