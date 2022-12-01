extends KinematicBody2D

# Generic physical game character

class_name GameCharacter

# Character orientation
enum Orientation {UP, DOWN, LEFT, RIGHT}

## Physics

# Movement speed
export var move_speed: float
# Movement direction
var move_direction: Vector2 = Vector2(0, 0)

## State

# Current character orientation
var orientation = Orientation.DOWN

## Node references (paths)

# Animated sprite
export var sprite_: NodePath

## Node references

# Character's animated sprite
onready var sprite: AnimatedSprite = get_node(sprite_)

func _process(delta):
	var is_moving = move_direction != Vector2.ZERO
	
	# Orientation changes
	if is_moving:
		if abs(move_direction.y) >= abs(move_direction.x):
			if move_direction.y < 0:
				orientation = Orientation.UP
			else:
				orientation = Orientation.DOWN
		else:
			if move_direction.x < 0:
				orientation = Orientation.LEFT
			else:
				orientation = Orientation.RIGHT
	
	# Animation
	match orientation:
		Orientation.UP:
			sprite.play("running_up" if is_moving else "idle_up")
		Orientation.DOWN:
			sprite.play("running_down" if is_moving else "idle_down")
		Orientation.LEFT:
			sprite.play("running_left" if is_moving else "idle_left")
		Orientation.RIGHT:
			sprite.play("running_right" if is_moving else "idle_right")
	
	sprite.z_index = position.y

func _physics_process(delta):
	# Updating actual position
	move_and_slide(move_direction.normalized() * move_speed)
