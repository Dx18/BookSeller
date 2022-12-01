extends Node2D

## Preloads

# Queue
const Queue = preload("res://scripts/util/Queue.gd")
# 2D array
const Array2D = preload("res://scripts/util/Array2D.gd")
# Random utils
const RandomUtils = preload("res://scripts/util/RandomUtils.gd")

# Result of map traversal
class TraversalResult:
	## Preloads
	
	# 2D Array
	const Array2D = preload("res://scripts/util/Array2D.gd")
	
	## Constants
	
	# Possible transitions
	const DELTAS = [
		Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)
	]
	
	# Start point
	var start: Vector2
	# Reached points
	var used: Array2D
	# Transition used to reach current point
	var prev: Array2D
	
	func _init(start: Vector2, used: Array2D, prev: Array2D):
		self.start = start
		self.used = used
		self.prev = prev
	
	# Builds from start point to given end. Checks if given end point is
	# reachable
	func build_path(end: Vector2) -> Array:
		assert(self.used.get_item(end.y, end.x), "End is not reachable!")
		
		var positions = []
		var curr: Vector2 = end
		while curr != self.start:
			positions.append(curr)
			curr -= DELTAS[prev.get_item(curr.y, curr.x) - 1]
		
		positions.append(self.start)
		positions.invert()
		
		return positions

## Parameters

# Number of citizens
export var citizen_count: int
# Min speed of citizen
export var citizen_min_speed: float
# Max speed of citizen
export var citizen_max_speed: float

## Scenes

# Citizens
export var citizen_scenes: Array

## Paths to objects

# Path to tile map
export var map_: NodePath

## Objects

# Tile map
onready var map: TileMap = get_node(map_)

## Read-only state

# Road tile ID
onready var road_tile = map.tile_set.find_tile_by_name("road")
# Map bounds
onready var map_bounds = map.get_used_rect()
# Size of tile
onready var tile_size = map.cell_size

## State

# Random
onready var random: RandomNumberGenerator = RandomNumberGenerator.new()
# Positions of tiles where citizens can spawn
var side_positions: Array = []

func _ready():
	random.randomize()
	
	_init_side_positions()
	
	for i in range(citizen_count):
		_spawn_citizen()

# Initializes positions where citizens can spawn
func _init_side_positions():
	for x in range(map_bounds.position.x, map_bounds.end.x):
		for y in [map_bounds.position.y, map_bounds.end.y - 1]:
			if map.get_cell(x, y) == road_tile:
				side_positions.append(Vector2(x, y) - map_bounds.position)
	for y in range(map_bounds.position.y + 1, map_bounds.end.y - 1):
		for x in [map_bounds.position.x, map_bounds.end.x - 1]:
			if map.get_cell(x, y) == road_tile:
				side_positions.append(Vector2(x, y) - map_bounds.position)

# Spawns citizen
func _spawn_citizen():
	# Random entry point
	var entry_index = random.randi_range(0, len(side_positions) - 1)
	var entry = side_positions[entry_index]
	
	# Making traversal
	var traversal = _make_traversal(entry)
	
	# Finding all reached side positions
	var reachable_side_positions = []
	for position in side_positions:
		if traversal.used.get_item(position.y, position.x):
			reachable_side_positions.append(position)
	
	# Excluding entry position
	reachable_side_positions.erase(entry)
	
	# Random exit point
	var exit_index = random.randi_range(0, len(reachable_side_positions) - 1)
	var exit = reachable_side_positions[exit_index]
	
	# Building path
	var path = traversal.build_path(exit)
	
	# Converting path to points in world space
	var positions = []
	for point in path:
		positions.append(
			(point + map_bounds.position + Vector2(0.5, 0.5)) * tile_size
		)
	
	# Instantiating citizen
	var citizen = RandomUtils.choose_one(citizen_scenes, random).instance()
	citizen.position = positions[0]
	citizen.move_speed = random.randf_range(
		citizen_min_speed, citizen_max_speed
	)
	citizen.init(positions, DefaultCitizenDialogs.new(
		random.randf(),
		RandomUtils.choose_unique_ordered(
			GameData.book_genres,
			random.randi_range(1, len(GameData.book_genres) / 3),
			random
		)
	))
	add_child(citizen)
	
	citizen.connect("left_map", self, "_spawn_citizen")

# Returns whether tile at given position is walkable for citizens. Tile is
# considered to be walkable for citizens if it is road tile and either this tile
# is located on the map's edge or all four surrounding tiles are road tiles.
# This is used to prevent citizens from walking on the edges of the road since
# it looks weird
func _is_walkable(position: Vector2) -> bool:
	var tile = map.get_cellv(position)
	if tile != road_tile:
		return false
	
	var at_top = position.y == map_bounds.position.y
	var at_bottom = position.y == map_bounds.end.y - 1
	var at_left = position.x == map_bounds.position.x
	var at_right = position.x == map_bounds.end.x - 1
	if at_top or at_bottom or at_left or at_right:
		return true
	
	var top_is_road = map.get_cellv(position + Vector2(0, -1)) == road_tile
	var bottom_is_road = map.get_cellv(position + Vector2(0, 1)) == road_tile
	var left_is_road = map.get_cellv(position + Vector2(-1, 0)) == road_tile
	var right_is_road = map.get_cellv(position + Vector2(1, 0)) == road_tile
	
	return top_is_road and bottom_is_road and left_is_road and right_is_road

func _make_traversal(entry: Vector2) -> TraversalResult:
	# Whether the cell was used
	var used = Array2D.new(map_bounds.size.y, map_bounds.size.x, false)
	# Index of transition delta used to reach the cell. 0 if undefined
	var prev = Array2D.new(map_bounds.size.y, map_bounds.size.x, 0)
	
	# BFS queue
	var queue: Queue = Queue.new()
	used.set_item(entry.y, entry.x, true)
	queue.push(entry)
	while not queue.empty():
		var curr: Vector2 = queue.pop()
		
		var delta_index = 0
		for delta in TraversalResult.DELTAS:
			var next: Vector2 = curr + delta
			
			var in_bounds = used.index_in_bounds(next.y, next.x)
			if in_bounds:
				var is_walkable = _is_walkable(next + map_bounds.position)
				if is_walkable and not used.get_item(next.y, next.x):
					used.set_item(next.y, next.x, true)
					prev.set_item(next.y, next.x, delta_index + 1)
					queue.push(next)
			
			delta_index += 1
	
	return TraversalResult.new(entry, used, prev)
