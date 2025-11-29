class_name PlayerHybrid
extends CharacterBody2D

const WALK_SPEED = 150.0
const AIR_SPEED = 150.0 
const MAX_JUMP_FORCE = 600.0

const AIR_ACCELERATION = 800.0 
const AIR_FRICTION = 400.0 

const MAX_CHARGE_TIME = 1.0 

# --- CONFIGURAÇÕES DO SLIDE EM RAMPAS ---
const SLIDE_ANGLE_DEGREES = 20.0     
const SLIDE_ACCEL = 700.0             # aceleração ao deslizar
const SLIDE_MAX_SPEED = 120.0         # velocidade máxima do deslize


var gravity = 980
var charge_time = 0.0
var is_charging = false

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	# Se quiser que o player deslize mesmo totalmente parado, deixe false:
	floor_stop_on_slope = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		handle_air_movement(delta)
	else:
		handle_ground_logic(delta)
	
	move_and_slide()
	update_animations()


func handle_ground_logic(delta):
	# --- DETECTAR RAMPAS E INICIAR DESLIZE ---
	var sliding = false
	var floor_angle = 0.0
	var floor_normal = Vector2.UP

	if is_on_floor():
		floor_angle = abs(get_floor_angle())  # em radianos
		floor_normal = get_floor_normal()

		if floor_angle > deg_to_rad(SLIDE_ANGLE_DEGREES):
			sliding = true

	if sliding:
		# Criar vetor tangente ao plano da rampa
		var slope_dir = Vector2(floor_normal.y, -floor_normal.x).normalized()

		# Garantir que a tangente esteja apontando PARA BAIXO
		if slope_dir.dot(Vector2.DOWN) < 0:
			slope_dir = -slope_dir

		# Acelerar o player na direção da rampa
		var target = slope_dir * SLIDE_MAX_SPEED
		velocity = velocity.move_toward(target, SLIDE_ACCEL * delta)

		# Animação opcional
		anim.play("fall")

		# Bloquear carregamento de pulo enquanto desliza
		is_charging = false
		charge_time = 0.0
		return

	# --- LÓGICA NORMAL DE CHÃO (SEM ESTAR EM RAMPA) ---
	if Input.is_action_pressed("ui_accept"):
		is_charging = true
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED) 
		charge_time += delta
		
		if charge_time > MAX_CHARGE_TIME:
			charge_time = MAX_CHARGE_TIME
		
		anim.play("charge")
		
	elif Input.is_action_just_released("ui_accept") and is_charging:
		do_jump_king_jump()
	
	else:
		is_charging = false
		charge_time = 0.0
		
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * WALK_SPEED
			anim.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)


func handle_air_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * AIR_SPEED, AIR_ACCELERATION * delta)
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)


func do_jump_king_jump():
	is_charging = false
	
	var charge_percent = charge_time / MAX_CHARGE_TIME
	charge_percent = clamp(charge_percent, 0.2, 1.0)
	
	velocity.y = -MAX_JUMP_FORCE * charge_percent
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * AIR_SPEED


func update_animations():
	if is_charging:
		return 
		
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	else:
		if velocity.x != 0:
			anim.play("walk")
		else:
			anim.play("idle")
