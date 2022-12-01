extends Camera2D

# Camera following given target

## Parameters

# Height of view in tiles
export var view_height: float
# Visible tile map margin (in tiles)
export var margin: int

## Paths to objects

# Tile map
export var map_: NodePath
# Target to follow
export var target_: NodePath

## References to objects

# Target to follow
var target: Node2D

## State

# Width of tile (used for proper scaling)
var tile_size: Vector2
# Position bounds
var bounds: Rect2

func _ready():
	var map: TileMap = get_node(map_)
	tile_size = map.cell_size
	
	target = get_node_or_null(target_)
	
	bounds = map.get_used_rect()
	bounds.position *= tile_size
	bounds.size *= tile_size

func _process(_delta):
	# Determining camera's zoom
	var size = get_viewport_rect().size
	
	zoom = view_height * tile_size / size.y

	var view_width = view_height * size.x / size.y
	
	var margin_vertical = (view_height / 2 + margin) * tile_size.y
	var margin_horizontal = (view_width / 2 + margin) * tile_size.x
	
	# Following the target
	if target != null:
		position = target.position
		position.x = clamp(
			position.x,
			bounds.position.x + margin_horizontal,
			bounds.end.x - margin_horizontal
		)
		position.y = clamp(
			position.y,
			bounds.position.y + margin_vertical,
			bounds.end.y - margin_vertical
		)
