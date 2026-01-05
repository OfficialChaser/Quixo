class_name PlayStateManager
extends Node

enum Turn { P1, P2 }
var turn = Turn.P1

enum State { 
	IntroAnimation, 
	BlockSelection, 
	MoveSelection, 
	MoveAnimation, 
	GameOver 
}
var state = State.BlockSelection

func change_turn():
	turn = Turn.P2 if turn == Turn.P1 else Turn.P1

func player1s_turn() -> bool: return turn == Turn.P1
