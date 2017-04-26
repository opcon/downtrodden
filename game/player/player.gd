extends RigidBody2D

const JUMP_SPEED = 300
const MAX_WALLJUMPS = 5
const MAX_JETPACK_SPEED = 700
const JETPACK_ACCEL = 2500
const MAX_JETPACK_FUEL = 150
const JETPACK_FUEL_DELTA = 50
const JETPACK_REFUEL_BONUS = 2
const MAX_MOVE_SPEED = 800
const MOVE_ACCEL = 5000
const MOVE_DECEL = 5000
const MAX_EXTRA_SCALE = 0.1
const SCALE_ACCEL = 0.4
const SCALE_DECEL = 0.4
const FLOOR_TIMER_CUTOFF = 0.25

var health_state_machine
var jetpack_state_machine

var alive = true
var invincible
var jetpacking = false
var found_floor = false
var jetpack_recharging = false
var jetpack_fuel = MAX_JETPACK_FUEL
var walljumps_remaining = MAX_WALLJUMPS

var floor_timer = 0

onready var parent_node = get_parent()
onready	var pc = get_node("player-colour")
onready var score_node = parent_node.get_node("score")

var death_particles_packed = preload("death-particles.tscn")
var colour_ramp

var last_collided_team = -1

export(int) var index = 0
export(Color) var base_colour = Color(0, 0, 0)

var team = 0

var input_enabled = true

func _integrate_forces(state):
	if (not alive or not input_enabled): return
	
	var lv = state.get_linear_velocity()
	var step = state.get_step()
	
	# Find the floor (a contact with upwards facing collision normal)
	found_floor = false
	var not_colliding_top = true
	var collision_normal = Vector2(0, 0)
	var floor_index = -1
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if (ci.dot(Vector2(0, -1)) > 0.6): # Collided below us
			found_floor = true
			floor_timer = 0
			floor_index = x
			var cobject = state.get_contact_collider_object(x)
			if (cobject.is_in_group("player") and cobject.team != team and not cobject.invincible):
				# Give us the bounce
				lv.y -= JUMP_SPEED
				# Kill player we collided with, if they are not already dead
				cobject.die(team)
		if (ci.dot(Vector2(0,1)) > 0.99): # Collided above us
			not_colliding_top = false;
			var cobject = state.get_contact_collider_object(x)
			if (cobject.is_in_group("player") and cobject.team != team):
				# If we collided with a player above us, we are dead
				die(cobject.team)
				return
		else:
			collision_normal = ci
	
	var move_left = Input.is_action_pressed("move_left" + str(index))
	var move_right = Input.is_action_pressed("move_right" + str(index))
	var jump = Input.is_action_pressed("move_up" + str(index))
	var jetpack = Input.is_action_pressed("jetpack" + str(index))
	
	if (found_floor):
		walljumps_remaining = MAX_WALLJUMPS
	
	if (jetpack_recharging):
		jetpack_fuel = min(jetpack_fuel + JETPACK_FUEL_DELTA*JETPACK_REFUEL_BONUS*step, MAX_JETPACK_FUEL)
	
	if (jetpack and jetpack_fuel > 0):
		jetpacking = true
		get_node("base-square/jetpack-particles").set_emitting(true)
		lv.y = max(lv.y - JETPACK_ACCEL * step, -MAX_JETPACK_SPEED)
		jetpack_fuel = max(jetpack_fuel - JETPACK_FUEL_DELTA * step, 0)
		
	else:
		jetpacking = false
		get_node("base-square/jetpack-particles").set_emitting(false)
	
	if (move_left):
		lv.x -= MOVE_ACCEL*step
		if (lv.x < -MAX_MOVE_SPEED):
			lv.x = -MAX_MOVE_SPEED
	elif (move_right):
		lv.x += MOVE_ACCEL*step
		if (lv.x > MAX_MOVE_SPEED):
			lv.x = MAX_MOVE_SPEED
	else:
		if (lv.x > 50):
			lv.x -= MOVE_DECEL*step
		elif (lv.x < -50):
			lv.x += MOVE_DECEL*step
		else: lv.x = 0
	if (jump):
		if (found_floor):
			lv.y -= JUMP_SPEED
		elif (state.get_contact_count() > 0 and not_colliding_top and walljumps_remaining > 0):
			walljumps_remaining -= 1
			lv.y = -3*JUMP_SPEED
			lv.x = collision_normal.x * JUMP_SPEED*3
			
	var p2d = get_node("base-square")
	var cs2d = get_node("player-collision")
	var s = p2d.get_scale()
	var extrascale = SCALE_ACCEL*step
	if (move_left or move_right or jetpack):
		s += Vector2(extrascale,extrascale)
		s.x = min(s.x, 1+MAX_EXTRA_SCALE)
		s.y = min(s.y, 1+MAX_EXTRA_SCALE)
	elif (s.x != 1 and s.y != 1):
		extrascale = SCALE_DECEL*step
		s -= Vector2(extrascale,extrascale)
		s.x = max(s.x, 1)
		s.y = max(s.y, 1)
	p2d.set_scale(s)
	cs2d.set_scale(s)
	pc.set_scale(s)
	
	if (jetpack_fuel <= 0):
		pc.hide()
	else:
		pc.show()
		var points = pc.get_polygon()
		points[0].y = (1 - jetpack_fuel / MAX_JETPACK_FUEL) * 100
		points[3].y = (1- jetpack_fuel / MAX_JETPACK_FUEL) * 100
		pc.set_polygon(points)
	
	lv += state.get_total_gravity()*step
	state.set_linear_velocity(lv)

func _ready():
	# Preload fsm script
	var fsm_resource = preload("res://scripts/fsm.gd")
	
	# Set up our health state machine
	health_state_machine = fsm_resource.new()
	health_state_machine.add_state("alive")
	health_state_machine.add_state("dead")
	health_state_machine.add_state("invincible")
	health_state_machine.add_link("alive", "dead", "condition", [self, "is_alive", false])
	health_state_machine.add_link("dead", "invincible", "timeout", [3])
	health_state_machine.add_link("invincible", "alive", "timeout", [1])
	health_state_machine.set_state("alive")
	health_state_machine.connect("state_changed",self,"on_health_state_changed")
	
	# Set up our jetpack state machine
	jetpack_state_machine = fsm_resource.new()
	jetpack_state_machine.add_state("depleting")
	jetpack_state_machine.add_state("recharging")
	jetpack_state_machine.add_state("warming-up")
	jetpack_state_machine.add_link("depleting", "warming-up", "condition", [self, "should_recharge_jetpack", true])
	jetpack_state_machine.add_link("warming-up", "recharging", "timeout", [1])
	jetpack_state_machine.add_link("warming-up", "depleting", "condition", [self, "should_stop_recharging_jetpack", true])
	jetpack_state_machine.add_link("recharging", "depleting", "condition", [self, "should_stop_recharging_jetpack", true])
	jetpack_state_machine.set_state("depleting")
	jetpack_state_machine.connect("state_changed", self, "on_jetpack_state_changed")
	
	var colour3 =  base_colour
	colour3.a = 0
	
	colour_ramp = ColorRamp.new()
	colour_ramp.set_colors([base_colour, base_colour, colour3])
	colour_ramp.set_offsets([0, 0.6667, 1])
	
	get_node("base-square/jetpack-particles").set_color_ramp(colour_ramp)
	get_node("player-colour").set_color(base_colour)
	get_node("base-square/player-outline").set_color(base_colour)
	
	randomize()
	move_to_spawn()
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	health_state_machine.process(delta)
	jetpack_state_machine.process(delta)
	floor_timer += delta

func move_to_spawn():
	var spawn_points = get_tree().get_nodes_in_group("spawn")
	var spi = randi() % spawn_points.size()
	set_pos(spawn_points[spi].get_pos())

func is_alive():
	return alive

func die(killer_team):
	if (not alive or invincible):
		return
	last_collided_team = killer_team
	alive = false

func on_health_state_changed(state_from, state_to, args):
	if (state_to == "invincible"):
		alive = true
		invincible = true
		move_to_spawn()
		get_node("AnimationPlayer").play("blink-player")
		enable()
	elif (state_to == "alive"):
		invincible = false
	elif (state_to == "dead"):
		alive = false
		jetpack_fuel = MAX_JETPACK_FUEL
		score_node.add_to_score(last_collided_team)
		var inst = death_particles_packed.instance()
		parent_node.add_child(inst)
		inst.set_pos(get_pos())
		inst.set_color_ramp(colour_ramp)
		disable()

var old_layer_mask
var old_collision_mask

func enable():
	show()
	set_layer_mask(old_layer_mask)
	set_collision_mask(old_collision_mask)
	
func disable():
	hide()
	get_node("base-square/jetpack-particles").set_emitting(false)
	old_layer_mask = get_layer_mask()
	old_collision_mask = get_collision_mask()
	set_layer_mask(0)
	set_collision_mask(0)

func should_recharge_jetpack():
	return found_floor and (jetpack_fuel < MAX_JETPACK_FUEL)

func should_stop_recharging_jetpack():
	return jetpacking or jetpack_fuel >= MAX_JETPACK_FUEL or (not found_floor && floor_timer > FLOOR_TIMER_CUTOFF)

func on_jetpack_state_changed(state_from, state_to, args):
	print("Changed to jetpack state ", state_to)
	if (state_to == "recharging"):
		jetpack_recharging = true
	elif (state_to == "depleting"):
		jetpack_recharging = false