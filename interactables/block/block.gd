class_name Block
extends Node2D

# Signals
signal selected
signal deselected

# References
@onready var button = $Button
@onready var animated_sprite_2d = $AnimatedSprite2D
var play_state_manager: PlayStateManager

# Type
enum Type { EMPTY, X, O }
var type = Type.EMPTY
var TYPE_MAP = {
	"empty": Type.EMPTY,
	"x": Type.X,
	"o": Type.O
}

# Location
var grid_pos : Vector2i

# Interactable booleans
var is_edge := false
var selectable := false
var is_selected := false

# Direction array
var invalid_dirs : Array[Vector2i]

# Used to prevent the toggle callback from running
# when block attributes reset
var no_toggle := false

func _ready():
	name = str(grid_pos)
	update_button_status()

func _process(_delta):
	match type:
		Type.EMPTY:
			animated_sprite_2d.play("empty")
		Type.X:
			animated_sprite_2d.play("x")
		Type.O:
			animated_sprite_2d.play("o")

# Called after initialization or movement, or selection
func update_button_status(selection := false):
	if not selection:
		update_selectability()
	
	if selectable:
		is_edge = true
		button.mouse_filter = button.MOUSE_FILTER_STOP
	else:
		button.mouse_filter = button.MOUSE_FILTER_IGNORE

## Setters
func set_invalid_dirs(dirs: Array[Vector2i]) -> void:
	invalid_dirs = dirs.duplicate()

func set_type(new_type: String):
	new_type = new_type.to_lower()
	if TYPE_MAP.has(new_type):
		type = TYPE_MAP[new_type]
	else:
		push_warning("Unknown type: %s" % new_type)

## Other functions
func update_selectability():
	is_selected = false
	
	var size = invalid_dirs.size()
	if size > 0 and size < 4 and given_player_can_select():
		selectable = true
	else:
		selectable = false

func reset_block_attributes():
	scale = Vector2(1, 1)
	
	# Placed no_toggle before b/c toggling button will
	# result in the callback function running, and then
	# whatever comes underneath the toggle change
	no_toggle = true
	button.button_pressed = false

## Helper functions
func given_player_can_select() -> bool:
	if play_state_manager.player1s_turn():
		return type != Type.O
	else:
		return type != Type.X

## Callbacks
func _on_mouse_entered():
	if is_selected:
		return
	scale = Vector2(1.1, 1.1)
	

func _on_mouse_exited():
	if is_selected:
		return
	scale = Vector2(1, 1)

func _on_block_toggled(toggled_on):
	if no_toggle:
		no_toggle = false
		return
		
	if toggled_on:
		selected.emit(self)
		scale = Vector2(1.2, 1.2)
	else:
		deselected.emit()
		scale = Vector2(1.1, 1.1)
	is_selected = toggled_on
