class_name PlayStateManager
extends Node

# Signals
signal board_lock_status_changed(status: bool)

# Turn
enum Turn { P1, P2 }
var turn := Turn.P1

# State
enum State { 
	IntroAnimation, 
	BlockSelection, 
	MoveSelection, 
	MoveAnimation, 
	GameOver 
}
var state := State.BlockSelection

# Board conditions
var board_locked := false

## Helper functions
func change_turn():
	turn = Turn.P2 if turn == Turn.P1 else Turn.P1

func set_board_locked(is_locked: bool):
	board_locked = is_locked
	board_lock_status_changed.emit(is_locked)

func player1s_turn() -> bool: return turn == Turn.P1
