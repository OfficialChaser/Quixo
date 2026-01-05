class_name MoveOption
extends Node2D

signal selected(dir: Vector2i)

var direction: Vector2i

# Only using one part of the Vector2i (Other part is -1)
var lineup_pos : Vector2i

var enabled := false

func _ready():
	adjust_rotation()

func _process(_delta):
	visible = enabled

func adjust_rotation():
	rotation = Vector2(direction).angle() + deg_to_rad(90)

func _on_mouse_entered():
	scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	scale = Vector2(1, 1)

func _on_option_pressed():
	selected.emit(direction)
