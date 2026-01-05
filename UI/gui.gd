extends Control

@onready var turn_label = $TurnLabel
@export var play_state_manager : PlayStateManager

func _process(_delta):
	turn_label.text = "Player 1's (X) turn"
	if not play_state_manager.player1s_turn():
		turn_label.text = "Player 2's (O) turn"
