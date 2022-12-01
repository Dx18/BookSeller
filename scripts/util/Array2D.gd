var _data: Array = []
var _height: int
var _width: int

func _init(height: int, width: int, init):
	for i in range(height * width):
		self._data.append(init)
	
	self._height = height
	self._width = width

func index_in_bounds(i: int, j: int) -> bool:
	return i >= 0 && i < self._height && j >= 0 && j < self._width

func get_item(i: int, j: int):
	return self._data[self._get_index(i, j)]

func set_item(i: int, j: int, value):
	self._data[self._get_index(i, j)] = value

func get_height() -> int:
	return self._height

func get_width() -> int:
	return self._width

func _get_index(i: int, j: int):
	assert(index_in_bounds(i, j), "Array2D index is out of bounds")
	
	return i * self._width + j
