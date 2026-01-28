// Choreography System POC
// Defines the timeline controller. Create subtypes for specific scenes.

// ============================================================================
// LOGIC CHOREOGRAPHED SCENE
// ============================================================================
// Controls the timeline. Triggers IO outputs at specific times.

/obj/effect/map_entity/logic_choreographed_scene
	name = "logic_choreographed_scene"
	icon_state = "choreo"
	
	// Define events in subtypes or override get_script()
	// Format: list(time_ds, target_name, input_name, param)
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

// ============================================================================
// EXAMPLES
// ============================================================================

// Example: Bunker Intro Sequence
/obj/effect/map_entity/logic_choreographed_scene/example_intro
	name = "choreo_intro"
	events = list(
		// Time (ds), Target Name, Input Name, Param
		list(10, "light_entry", "TurnOn", null),
		list(30, "door_bunker", "Open", null),
		list(50, "logic_relay_security", "Trigger", null),
		list(60, "light_hallway", "TurnOn", null)
	)

// ============================================================================
// CAMERA CINEMATIC TRIGGER
// ============================================================================
// Pans the camera to a target location and back

/obj/effect/map_entity/camera_trigger
	name = "camera_trigger"
	icon_state = "camera"
	is_brush = TRUE
	
	var/target_name = "" // Target to pan to
	var/pan_time = 2 SECONDS // Time to pan to the target
	var/hold_time = 3 SECONDS // Time to stay at the target
	var/smooth_return = FALSE // If TRUE, pans back. If FALSE, snaps back.
	
	var/list/active_viewers = list() // Mobs currently viewing the cinematic

/obj/effect/map_entity/camera_trigger/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !ismob(AM))
		return
	trigger_cinematic(AM)

/obj/effect/map_entity/camera_trigger/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	if(lowertext(input_name) == "trigger")
		if(ismob(activator))
			trigger_cinematic(activator)
		return TRUE
	return FALSE

/obj/effect/map_entity/camera_trigger/proc/trigger_cinematic(mob/M)
	if(!M.client || (M in active_viewers))
		return
	
	var/atom/target = find_target()
	if(!target)
		return

	active_viewers += M
	
	// Create a temporary camera object (using info_target as requested)
	var/obj/effect/map_entity/info_target/cam = new(M.loc)
	cam.name = "Cinematic Camera ([M])"
	
	// Lock perspective
	var/old_eye = M.client.eye
	var/old_perspective = M.client.perspective
	
	M.client.perspective = EYE_PERSPECTIVE
	M.client.eye = cam
	
	var/turf/start_T = get_turf(M)
	var/turf/end_T = get_turf(target)
	
	// Calculate pixel offset
	var/dx = (start_T.x - end_T.x) * 32
	var/dy = (start_T.y - end_T.y) * 32
	
	// Start at target, but offset visually to look like we are at start
	cam.loc = end_T
	cam.pixel_x = dx
	cam.pixel_y = dy
	
	// Animate to 0,0 (which is the target location physically)
	// Using generic easing 0 or standard valid one since EASE_IN_OUT wasn't found
	animate(cam, pixel_x = 0, pixel_y = 0, time = pan_time)
	
	// Schedule return
	spawn(pan_time + hold_time)
		if(smooth_return)
			// Pan back
			animate(cam, pixel_x = dx, pixel_y = dy, time = pan_time)
			sleep(pan_time)
		
		// Reset
		if(M && M.client)
			M.client.eye = old_eye
			M.client.perspective = old_perspective
		
		qdel(cam)
		active_viewers -= M

/obj/effect/map_entity/camera_trigger/proc/find_target()
	if(!target_name) return null
	var/list/targets = find_io_targets(target_name)
	if(length(targets))
		return targets[1]
	return null
