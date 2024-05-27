extends CharacterBody2D

var speed: float = 200.0
var direction: Vector2 = Vector2.LEFT
var move_left: bool = true
var max_health: int = 1000
var current_health: int = max_health

func _ready() -> void:
	velocity = direction * speed
	collision_layer = 4  # Layer 4
	collision_mask = 2   # Collide with layer 2 (bullets)
	add_to_group("enemies")
	print("Enemy ready with direction: ", direction, " and speed: ", speed)
	
	# Add health bar
	var health_bar = get_node("HealthBar")
	health_bar.max_value = max_health
	health_bar.value = current_health
	
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		print("Enemy collided with: ", collision.get_collider())
		if collision.get_collider().is_in_group("bullets"):
			take_damage(300)
	
	# Check if the enemy is out of screen bounds and queue_free if true
	var viewport = get_viewport_rect()
	if position.x < -50 or position.x > viewport.size.x + 50 or position.y < -50 or position.y > viewport.size.y + 50:
		print("Enemy went off-screen and is being removed.")
		queue_free()

	# Update the velocity based on the current direction
	velocity = direction * speed

func take_damage(amount: int):
	current_health -= amount
	print("Enemy took damage. Current health: ", current_health)
	
	var health_bar = get_node("HealthBar")
	health_bar.value = current_health
	
	if current_health <= 0:
		kill()
		
func kill():
	print("Enemy destroyed.")
	add_points_to_game(1)
	queue_free()  # Remove the enemy

func add_points_to_game(amount: int):
	var game_manager = get_node("/root/Main")  # Adjust the path as necessary
	game_manager.add_points(amount)
