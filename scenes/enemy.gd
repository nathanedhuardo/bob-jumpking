extends CharacterBody2D

var gravity = 100
var speed = 50
var direction = 1.0
@export var jump_height = 5 *16
var JUMP_VELOCITY =  100

func _physics_process(delta: float) -> void:
	velocity.y += gravity
	velocity.x = direction * speed
	$AnimatedSprite2D.flip_h = direction > 0.0
	
	if not $left.is_colliding():
		direction = 1.0
	elif not $right.is_colliding():
		direction = -1.0
		
	move_and_slide()
	
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var direction_to_player = self.global_position.direction_to(body.global_position)
		var prox = direction_to_player.dot(Vector2(0, -1))
		print(prox)
		if prox > 0.7:
			body.velocity.y = body.jump_velocity
			self.queue_free()
		else:
			get_tree().reload_current_scene()
