extends CharacterBody2D

var speed: float = 800.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	velocity = direction * speed
	collision_layer = 2  # Layer 2
	collision_mask = 4   # Collide with layer 4 (enemies)
	add_to_group("bullets")
	remove_amo_from_game(1)
	print("Bullet ready with direction: ", direction, " and speed: ", speed)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		print("Bullet collided with: ", collision.get_collider())
		if collision.get_collider().is_in_group("enemies"):
			print("Bullet hit enemy at position: ", collision.get_collider().position)
			collision.get_collider().kill(collision)  # Remove the enemy
			queue_free()                           # Remove the bullet
		else:
			print("Bullet hit something else")

	# Check if the bullet is out of screen bounds and queue_free if true
	var viewport = get_viewport_rect()
	if position.x < -50 or position.x > viewport.size.x + 50 or position.y < -50 or position.y > viewport.size.y + 50:
		queue_free()

func remove_amo_from_game(amount: int):
	var game_manager = get_node("/root/Main")  # Adjust the path as necessary
	game_manager.add_amo(-amount)
