extends Node

#preload obstacles
var stump_scene = preload("res://Mapas/Cenas/stump.tscn")
var rock_scene = preload("res://Mapas/Cenas/rock.tscn")
var barrel_scene = preload("res://Mapas/Cenas/barrel.tscn")
var bird_scene = preload("res://Mapas/Cenas/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heights := [200, 390]

#variaveis
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 3
var score : int
const SCORE_MODIFIER : int = 100
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 30
const SPEED_MODIFIER : int = 500
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game(): 
	#reset var
	score = 0
	show_score()
	game_running = false
	difficulty = 0
	#reset
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset HUD
	$HUD.get_node("StartLabel").show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#gerar obstaculos
		generate_obs()
		
		
		#mover Dino e Camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		#atualizar pontuacao
		score += speed
		show_score()
		
		#atualizar a posição do chao
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#gerar obstaculos terrestres
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_orb(obs, obs_x, obs_y)

func add_orb(obs, x ,y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)


func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
