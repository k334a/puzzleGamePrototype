extends CanvasLayer

signal resetPuzzle
signal resetGame
signal unPause

func enable() -> void:
	show()
	%ResetPuzzleButton.disabled = false
	%ResetGameButton.disabled = false
	%ReturnToGameButton.disabled = false

func _on_reset_puzzle_button_pressed() -> void:
	resetPuzzle.emit()
	hide()
	%ResetPuzzleButton.disabled = true
	%ResetGameButton.disabled = true
	%ReturnToGameButton.disabled = true

func _on_reset_game_button_pressed() -> void:
	resetGame.emit()
	hide()
	%ResetPuzzleButton.disabled = true
	%ResetGameButton.disabled = true
	%ReturnToGameButton.disabled = true

func _on_return_to_game_button_pressed() -> void:
	unPause.emit()
	hide()
	%ResetPuzzleButton.disabled = true
	%ResetGameButton.disabled = true
	%ReturnToGameButton.disabled = true
