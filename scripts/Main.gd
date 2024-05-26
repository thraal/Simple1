extends Node2D

var player_scene: PackedScene
var enemy_scene: PackedScene
var bullet_scene: PackedScene

var enemy_spawn_interval: float = 10.0
var enemy_timer: float = 0.0
var max_enemies: int = 2

var points: int = 0
var amo: int = 10

var game_over = preload("res://scenes/game_over.tscn").instantiate()

func _ready() -> void:
	# Load the scenes
	player_scene = preload("res://scenes/Player.tscn")
	enemy_scene = preload("res://scenes/Enemy.tscn")
	bullet_scene = preload("res://scenes/Bullet.tscn")
	
	# Spawn the player
	spawn_player()
	
	# Start the enemy spawn timer
	enemy_timer = enemy_spawn_interval

func _physics_process(delta: float) -> void:
	if amo <= 0:
		print("Game over!")
		get_tree().root.get_child(0).queue_free()
		get_tree().root.add_child(game_over)

func add_points(amount: int):
	points += amount
	update_points_display()

func update_points_display():
	var points_label = get_node("Canvas").get_node("PointsLabel")
	points_label.text = "score: " + str(points)

func add_amo(amount: int):
	amo += amount
	update_amo_display()

func update_amo_display():
	var points_label = get_node("Canvas").get_node("AmoLabel")
	points_label.text = "Amo: " + str(amo)

func spawn_player() -> void:
	var player_instance = player_scene.instantiate() as Node2D
	get_node("Canvas").add_child(player_instance)
	
	# Set the initial position of the player
	var viewport = get_viewport_rect()
	var player_body = player_instance.get_node("CharacterBody2D") as CharacterBody2D
	var player_height = player_body.get_node("Sprite2D").texture.get_height()
	player_body.position = Vector2(viewport.size.x / 2, viewport.size.y - player_height / 2)
	print("Player Position: ", player_body.position)
	
	# Connect the shooting signal
	player_body.connect("shoot_bullet", Callable(self, "_on_shoot_bullet"))

func spawn_enemy() -> void:
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return
	
	var enemy_instance = enemy_scene.instantiate() as Node2D
	get_node("Canvas").add_child(enemy_instance)
	
	var enemy = enemy_instance.get_node("CharacterBody2D") as CharacterBody2D
	
	# Randomly choose left or right for the enemy spawn
	var viewport = get_viewport_rect()
	var enemy_height = enemy.get_node("Sprite2D").texture.get_height()
	var spawn_y = self.get_node("EnemySpawnPoint").position.y  # Ensure the enemy is within the top bounds (slightly below top edge)
	
	if randi() % 2 == 0:
		enemy.position = Vector2(viewport.size.x + 50, spawn_y)
		enemy.direction = Vector2(-1, 0)
	else:
		enemy.position = Vector2(-50, spawn_y)
		enemy.direction = Vector2(1, 0)
	
	enemy.velocity = enemy.direction * enemy.speed
	print("Spawned enemy at position: ", enemy.position, " with velocity: ", enemy.velocity)
	enemy.add_to_group("enemies")

func _on_shoot_bullet(position: Vector2) -> void:
	var bullet_instance = bullet_scene.instantiate() as Node2D
	get_node("Canvas").add_child(bullet_instance)
	
	# Get the bullet CharacterBody2D node
	var bullet = bullet_instance.get_node("CharacterBody2D") as CharacterBody2D
	
	# Set the bullet's position and direction
	bullet.position = position
	var target_position = get_viewport().get_mouse_position()
	var direction = (target_position - bullet.position).normalized()
	
	# Set the bullet's direction and velocity
	bullet.direction = direction
	bullet.velocity = direction * bullet.speed  # Ensure the bullet starts moving
	
	# Calculate and set the bullet's rotation
	bullet.rotation = atan2(direction.y, direction.x) + PI/2
	
	print("Shot bullet from position: ", bullet.position, " to direction: ", direction, " with velocity: ", bullet.velocity)

