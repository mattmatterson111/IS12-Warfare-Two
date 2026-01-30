/obj/effect/map_entity/func_conveyor
	name = "func_conveyor"
	icon_state = "trigger_push"
	is_brush = TRUE
	var/push_dir = NORTH
	var/push_speed = 1
	var/push_interval = 3
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

/*
Inputs:
Start - Starts the conveyor
Enable - Starts the conveyor
Stop - Stops the conveyor
Disable - Stops the conveyor
Toggle - Toggles the running state
Reverse - Reverses the direction
SetSpeed - Sets the push speed (param: value)
*/
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