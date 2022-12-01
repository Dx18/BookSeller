extends StaticBody2D

# Tree

## Parameters

# Transparency of tree sprite when player is behind it
export var hide_transparency: float

## Paths to objects

# Path to tree sprite
export var sprite_: NodePath

## References to objects

# Tree sprite
onready var sprite: Sprite = get_node(sprite_)

func _on_body_entered(body):
	if body.is_in_group("player"):
		sprite.modulate.a = hide_transparency

func _on_body_exited(body):
	if body.is_in_group("player"):
		sprite.modulate.a = 1
