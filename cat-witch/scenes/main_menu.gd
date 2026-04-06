extends CanvasLayer

signal start_game

func _on_credits_button_pressed() -> void:
	%BackButton.disabled = false
	%CreditsButton.disabled = true
	%BeginGameButton.disabled = true
	$Control2.show()

func _on_begin_game_button_pressed() -> void:
	start_game.emit()
	hide()
	%BackButton.disabled = true
	%CreditsButton.disabled = true
	%BeginGameButton.disabled = true

func _on_back_button_pressed() -> void:
	$Control2.hide()
	%BackButton.disabled = true
	%CreditsButton.disabled = false
	%BeginGameButton.disabled = false

func enable() -> void:
	show()
	%CreditsButton.disabled = false
	%BeginGameButton.disabled = false


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
