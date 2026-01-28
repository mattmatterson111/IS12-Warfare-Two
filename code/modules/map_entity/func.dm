// Func entities for physical effects

// Func Conveyor - pushes entities in a direction
/obj/effect/map_entity/func_conveyor
	name = "func_conveyor"
	icon_state = "trigger_push"
	is_brush = TRUE
	var/push_dir = NORTH
	var/push_speed = 1  // Tiles per push
	var/push_interval = 3  // Ticks between pushes
	var/running = TRUE

/obj/effect/map_entity/func_conveyor/Initialize()
	. = ..()
	if(running)
		START_PROCESSING(SSfastprocess, src)

/obj/effect/map_entity/func_conveyor/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/map_entity/func_conveyor/Process()
	if(!running || !enabled)
		return
	var/list/turfs_to_check = list(get_turf(src))
	if(brush_neighbors)
		for(var/obj/effect/map_entity/E in brush_neighbors)
			turfs_to_check |= get_turf(E)
	for(var/turf/T in turfs_to_check)
		for(var/atom/movable/AM in T)
			if(AM.anchored)
				continue
			if(istype(AM, /obj/effect/map_entity))
				continue
			for(var/i = 1 to push_speed)
				step(AM, push_dir)

/obj/effect/map_entity/func_conveyor/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("start", "enable")
			running = TRUE
			START_PROCESSING(SSfastprocess, src)
			return TRUE
		if("stop", "disable")
			running = FALSE
			STOP_PROCESSING(SSfastprocess, src)
			return TRUE
		if("toggle")
			running = !running
			if(running)
				START_PROCESSING(SSfastprocess, src)
			else
				STOP_PROCESSING(SSfastprocess, src)
			return TRUE
		if("reverse")
			push_dir = turn(push_dir, 180)
			return TRUE
		if("setspeed")
			push_speed = text2num(params?["value"]) || push_speed
			return TRUE
	return FALSE

// Func Breakable - object with health that fires OnBreak when destroyed
/obj/effect/map_entity/func_breakable
	name = "func_breakable"
	icon_state = "landmark2"
	var/health = 100
	var/max_health = 100
	var/broken = FALSE

/obj/effect/map_entity/func_breakable/proc/take_damage(amount)
	if(broken)
		return
	health -= amount
	fire_output("OnDamaged", null, src)
	if(health <= 0)
		do_break()

/obj/effect/map_entity/func_breakable/proc/do_break()
	if(broken)
		return
	broken = TRUE
	fire_output("OnBreak", null, src)

/obj/effect/map_entity/func_breakable/proc/repair()
	broken = FALSE
	health = max_health
	fire_output("OnRepair", null, src)

/obj/effect/map_entity/func_breakable/attackby(obj/item/W, mob/user)
	. = ..()
	var/damage = W.force
	if(damage > 0)
		take_damage(damage)
		to_chat(user, "You hit \the [src].")

/obj/effect/map_entity/func_breakable/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("damage")
			var/amount = text2num(params?["value"]) || 10
			take_damage(amount)
			return TRUE
		if("break")
			do_break()
			return TRUE
		if("repair")
			repair()
			return TRUE
		if("sethealth")
			health = text2num(params?["value"]) || health
			return TRUE
	return FALSE

// Func Rotating - continuously rotates using animate()
/obj/effect/map_entity/func_rotating
	name = "func_rotating"
	icon_state = "landmark2"
	var/rotation_speed = 45  // Degrees per second
	var/rotating = FALSE
	var/clockwise = TRUE

/obj/effect/map_entity/func_rotating/Initialize()
	. = ..()
	if(rotating)
		start_rotation()

/obj/effect/map_entity/func_rotating/proc/start_rotation()
	rotating = TRUE
	var/direction = clockwise ? 1 : -1
	var/degrees_per_tick = rotation_speed / 10  // 10 ticks per second
	var/matrix/M = matrix()
	M.Turn(degrees_per_tick * direction)
	// Continuous rotation using animate loop
	animate(src, transform = transform * M, time = 1, loop = -1, flags = ANIMATION_PARALLEL)

/obj/effect/map_entity/func_rotating/proc/stop_rotation()
	rotating = FALSE
	animate(src)  // Stop animation
	transform = matrix()  // Reset to default

/obj/effect/map_entity/func_rotating/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("start")
			start_rotation()
			return TRUE
		if("stop")
			stop_rotation()
			return TRUE
		if("toggle")
			if(rotating)
				stop_rotation()
			else
				start_rotation()
			return TRUE
		if("reverse")
			clockwise = !clockwise
			if(rotating)
				stop_rotation()
				start_rotation()
			return TRUE
		if("setspeed")
			rotation_speed = text2num(params?["value"]) || rotation_speed
			if(rotating)
				stop_rotation()
				start_rotation()
			return TRUE
	return FALSE
