extends Node2D

func play_snd(snd) -> void:
	if snd == "walk":
		$walk.play()
