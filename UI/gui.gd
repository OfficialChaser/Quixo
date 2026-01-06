extends Control

# References
@onready var turn_label = $TurnLabel
@onready var turn_animation_player = $TurnLabel/AnimationPlayer
@onready var blur_animation_player = $BlurRect/AnimationPlayer

@export var play_state_manager : PlayStateManager

func _ready():
	play_state_manager.board_lock_status_changed.connect(_on_board_lock_status_changed)

func _process(_delta):
	# Sloppy Logic, I'll fix it with a signal eventually
	if turn_animation_player.is_playing(): return
	
	turn_label.text = "Player 1's (X) turn"
	if not play_state_manager.player1s_turn():
		turn_label.text = "Player 2's (O) turn"

func _on_board_lock_status_changed(locked: bool):
	if turn_animation_player.is_playing(): return
	
	if locked:
		turn_animation_player.play("fade_out")
