var _add: Array = []
var _delete: Array = []

func push(value):
	_add.append(value)

func pop():
	if _delete.empty():
		while not _add.empty():
			_delete.push_back(_add.pop_back())
	return _delete.pop_back()

func size() -> int:
	return len(_add) + len(_delete)

func empty() -> bool:
	return size() == 0
