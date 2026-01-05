class_name WinManager
extends RefCounted

func check_win(grid_size: int, get_type_at: Callable) -> int:
	# Rows
	for y in range(grid_size):
		var first = get_type_at.call(Vector2i(0, y))
		if first == Block.Type.EMPTY:
			continue
		
		var win := true
		for x in range(1, grid_size):
			if get_type_at.call(Vector2i(x, y)) != first:
				win = false
				break
		
		if win:
			return first

	# Columns
	for x in range(grid_size):
		var first = get_type_at.call(Vector2i(x, 0))
		if first == Block.Type.EMPTY:
			continue
		
		var win := true
		for y in range(1, grid_size):
			if get_type_at.call(Vector2i(x, y)) != first:
				win = false
				break
		
		if win:
			return first

	# Main diagonal
	var first_diag = get_type_at.call(Vector2i(0, 0))
	if first_diag != Block.Type.EMPTY:
		var win := true
		for i in range(1, grid_size):
			if get_type_at.call(Vector2i(i, i)) != first_diag:
				win = false
				break
		if win:
			return first_diag

	# Anti-diagonal
	var first_anti = get_type_at.call(Vector2i(grid_size - 1, 0))
	if first_anti != Block.Type.EMPTY:
		var win := true
		for i in range(1, grid_size):
			if get_type_at.call(Vector2i(grid_size - 1 - i, i)) != first_anti:
				win = false
				break
		if win:
			return first_anti

	return Block.Type.EMPTY
