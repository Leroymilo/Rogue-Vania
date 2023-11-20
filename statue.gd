extends RigidBody2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_collide(linear_velocity)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	linear_velocity = Vector2.ZERO

func push(dir: Vector2):
	linear_velocity = dir * Parameters.PLAYER_SPEED / 2
