extends Control

onready var death_screen = $Death
onready var help_screen = $Help
onready var player = get_parent().get_node("Viewports/ViewportContainer1/Viewport1/World/Player")
onready var box = get_parent().get_node("Viewports/ViewportContainer1/Viewport1/World/PushBox")
onready var songs = $ui_sound/songs
onready var dg = $ui_sound/dg
onready var sp_sav_panel = $Dialogue/Savya/PanelContainer
onready var sp_ali_panel = $Dialogue/Alizea/PanelContainer
onready var sp_sav_text1 = $Dialogue/Alizea/PanelContainer/Panel/sp1/Label1
onready var sp_ali_text1 = $Dialogue/Alizea/PanelContainer/Panel/sp1/Label1
onready var sp_ali_text2 = $Dialogue/Alizea/PanelContainer/Panel/sp1/Label2
onready var sp_ali_text3 = $Dialogue/Alizea/PanelContainer/Panel/sp1/Label3
onready var door = get_parent().get_node("Viewports/ViewportContainer1/Viewport1/World/Environment/Objects/Doors/DoorLever/Door")
onready var end = $EndScreen

const SONGS = {
	"song1":
preload("res://audio/song1.wav"),
	"song2":
preload("res://audio/song2.wav"),
	"ambience":
preload("res://audio/Ambience1.wav")	
}

const DG = {
	"hello":
preload("res://audio/sp_ali1.wav"),
	"help":
preload("res://audio/sp_ali2.wav"),
	"hear":
preload("res://audio/sp_ali3.wav")
}

var sp_sav = false
var sp_ali = false
var sp_sav1 = false
var sp_sav2 = false
var sp_sav3 = false
var sp_ali1 = true
var sp_ali2 = false
var sp_ali3 = false
var sp_wait = 0
var speak = false
var text = false

var paused = false
var music = true
var help = false
var loc1 = Vector2(-525, -225)
var loc2 = Vector2(-560, -220)
var lives = 3

func _ready() -> void:
	play_snd("song1")
	death_screen.visible = false
	help_screen.visible = false
	sp_sav_panel.visible = false
	sp_ali_panel.visible = false
	sp_ali_text1.visible = false
	sp_ali_text2.visible = false
	sp_ali_text3.visible = false
	end.visible = false
	
	
func _process(delta) -> void:
	if paused:
		return
	if speak and sp_wait > 0:
		sp_wait += 1
		print(sp_wait)
		if sp_wait == 25:
			if sp_ali1:
				play_snd("hello") #xenʌaqaipaʌn - hello, Kallean
			elif sp_ali2:
				play_snd("help") #xaafaʌnuun wʊut̚ ke shuʰʊt̚̚ - please help me, Kallean
			elif sp_ali3:
				play_snd("hear") #dʒjaikʰhuun ke shuʰʊt̚ - can you hear me?, Kallean

func _physics_process(_delta) -> void:
	if door.complete:
		end.visible = true
		paused = true
	
	if player.dead:
		die()
	if help:
		paused = true
		player.paused = true
		box.paused = true
		help_screen.visible = true
	elif !help:
		paused = false
		player.paused = false
		box.paused = false
		help_screen.visible = false
		help_screen.visible = false
	if box.buddy:
		sp_sav_panel.visible = false
		sp_ali_panel.visible = false
		sp_ali_text1.visible = false
		sp_ali_text2.visible = false
		sp_ali_text3.visible = false
	elif !box.buddy and text:
			if sp_ali1:
				sp_ali_text1.visible = true
				sp_ali_text1.visible_characters += 1
			elif sp_ali2:
				sp_ali_text2.visible = false
				sp_ali_text2.visible = true
				sp_ali_text2.visible_characters += 1
			elif sp_ali3:
				sp_ali_text2.visible = false
				sp_ali_text3.visible = true
				sp_ali_text3.visible_characters += 1
	else:
		sp_sav_panel.visible = false
		sp_ali_panel.visible = false
		sp_ali_text1.visible = false
		sp_ali_text2.visible = false
		sp_ali_text3.visible = false
		
func _input(event) -> void:
	if !box.buddy:
		if event.is_action_pressed("bud_down"):
			speak = !speak
			text = !text
			if !sp_ali:
				sp_ali = true
		
		if event.is_action_released("bud_down"):
			if sp_ali:
				speak()
			if sp_wait > 45:
				if sp_ali1:
					sp_ali1 = false
					sp_ali2 = true
				elif sp_ali2:
					sp_ali2 = false
					sp_ali3 = true
				elif sp_ali3:
					sp_ali3 = false
					sp_ali1 = true
				sp_wait = 0
		
		#This is supposed to turn off the text if any key is pressed, but it just blocks it from appearing
		#if speak and text:
		#	if event is InputEventKey:
		#		if event.pressed:
		#			unspeak()
					
	if event.is_action_pressed("help"):
		help = !help
	if event.is_action_pressed("mute"):
		music = !music
		if !music:
			songs.stop()
		else:
			var sounds = ["song1", "song2", "ambience"]
			var sng = sounds[randi() % sounds.size()]
			play_snd(sng)
	if event.is_action_released("zoom"):
		zoom()


func zoom() -> void:
	OS.window_fullscreen = !OS.window_fullscreen


func play_snd(snd) -> void:
	if SONGS.has(snd):
		songs.stream = SONGS[snd]
		songs.play()
	elif DG.has(snd):
		dg.stream = DG[snd]
		dg.play()


func checkpoint() -> void:
	loc1 = player.position
	loc2 = box.position


func speak() -> void:
	if !paused:
		sp_wait += 1
		if sp_ali:
			sp_ali_panel.visible = !sp_ali_panel.visible
			sp_ali = false
		
	if sp_sav:
		sp_sav_panel.visible = !sp_sav_panel.visible
		sp_sav = false


func unspeak() -> void:
	sp_wait = 0
	sp_ali = false
	sp_sav = false
	sp_sav_panel.visible = false
	sp_ali_panel.visible = false


func die() -> void:
	player.lives -= 1
	if player.lives > 0:
		player.position = loc1
		box.position = loc2
	elif player.lives == 0:
		death_screen.visible = true
	player.dead = !player.dead
