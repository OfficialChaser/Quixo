class_name BoardManager
extends Node2D

# Board stats
@export var grid_size := 5
@export var cell_size := 18 # pixels above 16 = spacing
var grid_pixel_size : Vector2
var origin_offset : Vector2

# References
@export var block_scene: PackedScene
@export var move_option_scene: PackedScene
@export var play_state_manager: PlayStateManager
var win_manager := WinManager.new()

# Board data
var blocks : Array[Block]
var move_options : Array[MoveOption]
var active_block : Block

func _ready():
	# Place center of board at point
	position.x = int(Util.project_viewport_w / 2)
	position.y = int(Util.project_viewport_h / 1.75)
	
	# Determine grid statistics
	grid_pixel_size = Vector2(
		grid_size * cell_size,
		grid_size * cell_size
	)
	
	origin_offset = round(grid_pixel_size / 2 - Vector2(cell_size, cell_size) / 2)
	
	spawn_board()
	spawn_move_options()

func spawn_board():
	for y in range(grid_size):
		for x in range(grid_size):
			var block = block_scene.instantiate()
			
			block.grid_pos = Vector2i(x, y)
			block.position = grid_to_world(block.grid_pos)
			
			block.invalid_dirs = get_invalid_dirs(block.grid_pos)
			block.play_state_manager = play_state_manager
			blocks.append(block)
			
			add_child(block)
			
			block.selected.connect(_on_block_selected)
			block.deselected.connect(_on_block_deselected)

func spawn_move_options():
	# Top & bottom
	for x in range(grid_size):
		# Top → push down
		var top = move_option_scene.instantiate()
		top.direction = Directions.DOWN
		top.position = grid_to_world(Vector2i(x, 0)) + Vector2(0, -cell_size)
		top.lineup_pos = Vector2i(x, -1)
		move_options.append(top)
		add_child(top)
		
		top.selected.connect(_on_move_option_selected)
		
		# Bottom → push up
		var bottom = move_option_scene.instantiate()
		bottom.direction = Directions.UP
		bottom.position = grid_to_world(Vector2i(x, grid_size - 1)) + Vector2(0, cell_size)
		bottom.lineup_pos = Vector2i(x, -1)
		move_options.append(bottom)
		add_child(bottom)
		
		bottom.selected.connect(_on_move_option_selected)

	# Left & right
	for y in range(grid_size):
		# Left → push right
		var left = move_option_scene.instantiate()
		left.direction = Directions.RIGHT
		left.position = grid_to_world(Vector2i(0, y)) + Vector2(-cell_size, 0)
		left.lineup_pos = Vector2i(-1, y)
		move_options.append(left)
		add_child(left)
		
		left.selected.connect(_on_move_option_selected)

		# Right → push left
		var right = move_option_scene.instantiate()
		right.direction = Directions.LEFT
		right.position = grid_to_world(Vector2i(grid_size - 1, y)) + Vector2(cell_size, 0)
		right.lineup_pos = Vector2i(-1, y)
		move_options.append(right)
		add_child(right)
		
		right.selected.connect(_on_move_option_selected)

## Get Movement options

# Called only when block is selected, data isn't saved
func possible_move_options(block: Block) -> Array[MoveOption]:
	var options: Array[MoveOption]
	
	for move_option in move_options:
		# Lines up with x or y
		var lines_up := block.grid_pos.x == move_option.lineup_pos.x \
			or block.grid_pos.y == move_option.lineup_pos.y
			
		if not lines_up:
			continue
		
		# Make sure the direction hasn't been flagged
		if move_option.direction in block.invalid_dirs:
			continue
			
		options.append(move_option)
		
	return options

# Runs whenever block is initialized or moves
# Returns a list of directions, that's it
func get_invalid_dirs(grid_pos: Vector2i) -> Array[Vector2i]:
	var dirs : Array[Vector2i]

	if grid_pos.x == 0:
		dirs.append(Directions.RIGHT)
	if grid_pos.x == grid_size - 1:
		dirs.append(Directions.LEFT)
	if grid_pos.y == 0:
		dirs.append(Directions.DOWN)
	if grid_pos.y == grid_size - 1:
		dirs.append(Directions.UP)

	return dirs

## Core Movement logic
func apply_move(dir: Vector2i):
	var line: Array[Block]
	
	var is_horizontal := dir.x != 0
	
	# 1. Collect affected blocks
	for block in blocks:
		if is_horizontal and block.grid_pos.y == active_block.grid_pos.y:
			line.append(block)
		elif not is_horizontal and block.grid_pos.x == active_block.grid_pos.x:
			line.append(block)
			

	# 1.5 Sort the line properly
	if is_horizontal:
		line.sort_custom(sort_by_x)
	else:
		line.sort_custom(sort_by_y)
	
	# 2. Remove active block from the line
	var active_index = line.find(active_block)
	line.erase(active_block)
	
	# 3. Shift blocks
	for i in range(len(line)):
		if is_horizontal:
			# L/R
			if dir.x < 0 and i >= active_index or dir.x > 0 and i < active_index:
				line[i].grid_pos += dir
				
		else:
			# U/D
			if dir.y < 0 and i >= active_index or dir.y > 0 and i < active_index:
				line[i].grid_pos += dir

	# 4. Insert active block at the far end
	var insert_pos := active_block.grid_pos

	if is_horizontal:
		insert_pos.x = grid_size - 1 if dir.x == -1 else 0
	else:
		insert_pos.y = grid_size - 1 if dir.y == -1 else 0

	active_block.grid_pos = insert_pos

	# 5. Update visuals + rules
	for block in blocks:
		# Update/reset active block
		if block == active_block:
			if play_state_manager.player1s_turn():
				block.set_type("x")
			else:
				block.set_type("o")
			
			
			var winner := win_manager.check_win(
				grid_size,
				Callable(self, "get_type_at")
			)
			if winner != Block.Type.EMPTY:
				print("Winner:", "Player 1 (X)" if winner == Block.Type.X else "Player 2 (O)")
				play_state_manager.set_board_locked(true)
				
			play_state_manager.change_turn()
			block.reset_block_attributes()
		
		block.position = grid_to_world(block.grid_pos)
		block.invalid_dirs = get_invalid_dirs(block.grid_pos)
		block.update_button_status()
		

## Helper functions
func grid_to_world(pos: Vector2i) -> Vector2:
	return Vector2(pos) * cell_size - origin_offset

func get_type_at(pos: Vector2i) -> int:
	for block in blocks:
		if block.grid_pos == pos:
			return block.type
	return Block.Type.EMPTY

func sort_by_x(a, b):
	return a.grid_pos.x < b.grid_pos.x

func sort_by_y(a, b):
	return a.grid_pos.y < b.grid_pos.y

## Callbacks
func _on_block_selected(selected_block: Block):
	# Update active block
	active_block = selected_block
	
	# Deactivate other blocks
	for block in blocks:
		if block.grid_pos != selected_block.grid_pos:
			block.selectable = false
			block.update_button_status(true)
		
	for move_option in possible_move_options(selected_block):
		move_option.enabled = true

func _on_block_deselected():
	# Reset active block
	active_block = null
	
	# Reactivate other blocks (if they're an edge)
	for block in blocks:
		if block.is_edge:
			block.selectable = true
			block.update_button_status()
	for move_option in move_options:
		move_option.enabled = false
		
func _on_move_option_selected(dir: Vector2i):
	# Move blocks
	apply_move(dir)
	
	# Reactivate blocks
	for block in blocks:
		block.update_button_status()
	
	# Disable move options
	for move_option in move_options:
		move_option.enabled = false
