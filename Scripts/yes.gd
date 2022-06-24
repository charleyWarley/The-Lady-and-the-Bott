extends ToolButton

var click = false
export(String, FILE, ".tscn") var worldScene
onready var unlit_font = load("res://World/Environment/Fonts/Uni_Unlit.tres")
onready var lit_font = load("res://World/Environment/Fonts/Uni_Lit.tres")


func on_click():
	var font = DynamicFont.new()
	$Label.add_font_override("font", lit_font)
	click = true

func cancel():
	var font = DynamicFont.new()
	$Label.add_font_override("font", unlit_font)
	click = false
	
func on_release():
	cancel()
	get_tree().change_scene(worldScene)


func _on_Quit_button_down():
	on_click()


func _on_Quit_button_up():
	on_release()


func _on_Restart_button_up():
	cancel()
	get_tree().reload_current_scene()


func _on_Restart_button_down():
	on_click()
