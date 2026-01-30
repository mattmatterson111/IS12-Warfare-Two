GLOBAL_DATUM_INIT(daylight_controller, /datum/daylight_controller, new)
//GLOBAL_DATUM_INIT(global_daylight_plane, /obj/screen/plane_master/daylight, new)

/datum/daylight_phase
	var/color
	var/duration
	var/output_channel

/datum/daylight_phase/New(color, duration, output_channel)
	src.color = color
	src.duration = duration
	src.output_channel = output_channel

/datum/daylight_phase/proc/on_cycle_start()
	if(output_channel)
		IO_output(output_channel, "Start", GLOB.daylight_controller)

/datum/daylight_phase/proc/on_cycle_end()
	if(output_channel)
		IO_output(output_channel, "End", GLOB.daylight_controller)

/datum/daylight_controller
	var/list/phases
	var/total_duration = 0
	var/current_phase_index = 0
	var/current_color = "#000000"
	var/datum/daylight_phase/current_active_phase
	
	// Debug/Control variables
	var/speed = 1
	var/current_time = 0
	var/last_process_time = 0

/datum/daylight_controller/New()
	..()
	phases = list(
		new /datum/daylight_phase("#000000", 200,      "midnight"),
		new /datum/daylight_phase("#110500", 100,      "dawn_start"),
		new /datum/daylight_phase("#9e4f1b", 200,      "sunrise"),
		new /datum/daylight_phase("#ddd6cc", 1000,     "noon"),
		new /datum/daylight_phase("#a35520", 200,      "sunset"),
		new /datum/daylight_phase("#110500", 100,      "dusk_end"),
	)
	
	for(var/datum/daylight_phase/P in phases)
		total_duration += P.duration
	
	last_process_time = world.time

/datum/daylight_controller/proc/update_cycle()
	if(!total_duration) return

	// Calculate delta time in deciseconds
	var/dt = world.time - last_process_time
	last_process_time = world.time
	
	// Advance current time
	current_time = (current_time + dt * speed)
	
	// Handle wrapping
	if(current_time >= total_duration)
		current_time = current_time % total_duration
	if(current_time < 0) // Handle negative speed
		current_time = total_duration + (current_time % total_duration)

	var/accumulated_time = 0
	var/found_index = 0
	var/datum/daylight_phase/current_phase
	var/datum/daylight_phase/next_phase
	var/time_into_phase = 0
	
	for(var/i = 1 to phases.len)
		var/datum/daylight_phase/P = phases[i]
		if(current_time < accumulated_time + P.duration)
			current_phase = P
			found_index = i
			time_into_phase = current_time - accumulated_time
			
			var/next_i = (i % phases.len) + 1
			next_phase = phases[next_i]
			break
		accumulated_time += P.duration
	
	if(current_phase)
		if(current_active_phase != current_phase)
			if(current_active_phase)
				current_active_phase.on_cycle_end()
			
			current_active_phase = current_phase
			current_active_phase.on_cycle_start()
			current_phase_index = found_index
		
		var/fraction = time_into_phase / current_phase.duration
		var/target_color = BlendRGB(current_phase.color, next_phase.color, fraction)
		set_color(target_color, 10)

/datum/daylight_controller/proc/set_color(new_color, time = 10)
	current_color = new_color
	for(var/obj/effect/lighting_dummy/daylight/D in GLOB.lighting_dummies)
		animate(D, color = current_color, time = time)


/client/proc/debug_daylight_phase()
	set name = "Debug Daylight Phase"
	set category = "Debug"
	
	if(!GLOB.daylight_controller)
		return
	
	var/list/phase_names = list()
	for(var/datum/daylight_phase/P in GLOB.daylight_controller.phases)
		if(P.output_channel)
			phase_names[P.output_channel] = P
		else
			phase_names["[P.color]"] = P
			
	var/chosen_name = input(src, "Select phase to jump to", "Debug Daylight") as null|anything in phase_names
	if(!chosen_name)
		return
		
	var/datum/daylight_phase/chosen_phase = phase_names[chosen_name]
	
	// Find start time of this phase
	var/accumulated_time = 0
	for(var/datum/daylight_phase/P in GLOB.daylight_controller.phases)
		if(P == chosen_phase)
			break
		accumulated_time += P.duration
		
	GLOB.daylight_controller.current_time = accumulated_time
	GLOB.daylight_controller.last_process_time = world.time // Reset last process time to avoid huge jump
	GLOB.daylight_controller.update_cycle() // Force immediate update

/client/proc/debug_daylight_speed()
	set name = "Debug Daylight Speed"
	set category = "Debug"
	
	if(!GLOB.daylight_controller)
		return
		
	var/new_speed = input(src, "Set daylight speed multiplier", "Debug Daylight Speed", GLOB.daylight_controller.speed) as num|null
	if(new_speed == null)
		return
		
	GLOB.daylight_controller.speed = new_speed
