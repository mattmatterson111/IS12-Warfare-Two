/obj/effect/map_entity/logic_choreographed_scene
	name = "logic_choreographed_scene"
	icon_state = "choreo"
	
	var/list/events = list()
	
	var/list/timers = list()
	var/running = FALSE

/obj/effect/map_entity/logic_choreographed_scene/proc/get_script()
	return events

/obj/effect/map_entity/logic_choreographed_scene/proc/start_scene()
	if(running)
		return
	
	var/list/script = get_script()
	if(!length(script))
		return

	running = TRUE
	debug_flash(MAP_ENTITY_COLOR_SEQUENCE)
	debug_log("starting choreographed scene")
	fire_output("OnStart", null, src)


	for(var/list/event in script)
		var/time = event[1]
		var/target = event[2]
		var/input = event[3]
		var/param = (length(event) >= 4) ? event[4] : null

		var/tid = addtimer(CALLBACK(src, PROC_REF(execute_event), target, input, param), time, TIMER_STOPPABLE)
		timers += tid

/obj/effect/map_entity/logic_choreographed_scene/proc/stop_scene()
	running = FALSE
	for(var/tid in timers)
		deltimer(tid)
	timers.Cut()
	fire_output("OnCancel", null, src)

/obj/effect/map_entity/logic_choreographed_scene/proc/execute_event(target_name, input_name, param)
	if(!running || !enabled)
		return
	
	IO_output("[target_name]:[input_name]:[param]", null, src)
	debug_flash(MAP_ENTITY_COLOR_SEQUENCE)

/*
Inputs:
Start - Starts the scene
Stop - Stops the scene
Cancel - Stops the scene

Outputs:
OnStart - Fired when the scene starts
OnCancel - Fired when the scene is active and cancelled
*/
/obj/effect/map_entity/logic_choreographed_scene/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("start")
			start_scene()
			return TRUE
		if("stop", "cancel")
			stop_scene()
			return TRUE
	return FALSE

/obj/effect/map_entity/logic_choreographed_scene/example_intro
	name = "choreo_intro"
	events = list(
		list(10, "light_entry", "TurnOn", null),
		list(30, "door_bunker", "Open", null),
		list(50, "logic_relay_security", "Trigger", null),
		list(60, "light_hallway", "TurnOn", null)
	)

/obj/effect/map_entity/camera_trigger
	name = "camera_trigger"
	icon_state = "camera"
	is_brush = FALSE
	
	/// Mode: "brush", "manual_brush", "input"
	var/mode = "brush"
	var/target_name = ""
	var/target_sequence = ""
	var/pan_time = 2 SECONDS
	var/hold_time = 3 SECONDS
	var/smooth_return = FALSE
	// var/trigger_on_enter = TRUE // Deprecated, mapped to mode="brush"
	
	var/list/active_viewers = list()
	var/list/entities_inside = null

/obj/effect/map_entity/camera_trigger/Initialize()
	. = ..()
	
	// Legacy mapping (if trigger_on_enter was FALSE, it implied manual trigger, so manual_brush)
	if(vars.Find("trigger_on_enter") && !vars["trigger_on_enter"])
		mode = "manual_brush"
	
	if(mode == "brush" || mode == "manual_brush")
		is_brush = TRUE
		if(mode == "brush")
			spawn(1)
				connect_brush_neighbors()

/obj/effect/map_entity/camera_trigger/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(mode != "brush" && mode != "manual_brush")
		return
	if(!ismob(AM))
		return
	
	LAZYADD(entities_inside, AM)
	
	if(mode == "brush")
		trigger_cinematic(AM)

/obj/effect/map_entity/camera_trigger/Uncrossed(atom/movable/AM)
	. = ..()
	if(mode != "brush" && mode != "manual_brush")
		return
	if(!ismob(AM))
		return

	if(AM in entities_inside)
		LAZYREMOVE(entities_inside, AM)

/*
Inputs:
Trigger - Triggers behavior based on mode.
          Input mode: triggers activator.
          Manual_brush mode: triggers all in brush.
*/
/obj/effect/map_entity/camera_trigger/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	if(lowertext(input_name) == "trigger")
		if(mode == "input")
			if(ismob(activator))
				trigger_cinematic(activator)
		else if(mode == "manual_brush")
			if(entities_inside)
				for(var/mob/M in entities_inside)
					trigger_cinematic(M)
		return TRUE
	return FALSE



/obj/effect/map_entity/camera_trigger/proc/trigger_cinematic(mob/M)
	if(!M.client || (M in active_viewers))
		return
	
	active_viewers += M
	
	var/list/sequence = list()
	
	if(target_name)
		var/list/found = find_io_targets(target_name)
		if(length(found)) sequence += found[1]
	
	if(target_sequence)
		var/list/names = splittext(target_sequence, ";")
		for(var/name in names)
			var/list/found = find_io_targets(name)
			if(length(found)) sequence += found[1]
			
	if(!length(sequence))
		active_viewers -= M
		return

	spawn(0)
		play_sequence(M, sequence)

/obj/effect/map_entity/camera_trigger/proc/play_sequence(mob/M, list/targets)
	var/turf/start_T = get_turf(M)
	if(!M.client) return



	for(var/atom/target in targets)
		if(!M || !M.client) break
		
		var/turf/target_T = get_turf(target)
		var/dx = (target_T.x - start_T.x) * 32
		var/dy = (target_T.y - start_T.y) * 32
		
		animate(M.client, pixel_x = dx, pixel_y = dy, time = pan_time, easing = SINE_EASING)
		sleep(pan_time + hold_time)
	
	if(M && M.client)
		if(smooth_return)
			animate(M.client, pixel_x = 0, pixel_y = 0, time = pan_time, easing = SINE_EASING)
			sleep(pan_time)
		else
			animate(M.client, pixel_x = 0, pixel_y = 0, time = 0)
	
	active_viewers -= M
