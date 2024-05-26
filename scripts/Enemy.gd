extends CharacterBody2D

var speed: float = 100.0
var direction: Vector2 = Vector2.LEFT
var move_left: bool = true

func _ready() -> void:
	velocity = direction * speed
	collision_layer = 4  # Layer 4
	collision_mask = 2   # Collide with layer 2 (bullets)
	add_to_group("enemies")
	print("Enemy ready with direction: ", direction, " and speed: ", speed)
	
	# Create and configure the timer
	var timer = Timer.new()
	timer.wait_time = 1.0  # Adjust the time to change direction as needed
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	add_child(timer)
	timer.start()

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		print("Enemy collided with: ", collision.get_collider())
		if collision.get_collider().is_in_group("bullets"):
			kill(collision)
	
	# Update the velocity based on the current direction
	velocity = direction * speed

func kill(collision):
	print("Enemy hit by bullet at position: ", collision.get_collider().position)
	add_points_to_game(1)
	queue_free()                           # Remove the enemy
	collision.get_collider().queue_free()  # Remove the bullet

func _on_Timer_timeout() -> void:
	move_left = !move_left
	if move_left:
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT

func add_points_to_game(amount: int):
	var game_manager = get_node("/root/Main")  # Adjust the path as necessary
	game_manager.add_points(amount)

