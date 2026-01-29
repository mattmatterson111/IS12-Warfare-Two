SUBSYSTEM_DEF(weather)
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 1 SECOND
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	// Stores the current weather state for each Z-level
	// Format: list(z_level_id = datum/weather_node) or list(z_index = ...)
	var/list/z_states = list()

	// Time of Day simulation
	var/time_of_day = 600 // Start at 06:00 (in minutes, 0-1440)
	var/time_speed = 1.0 // Multiplier for how fast time passes
	var/next_event_check = 0
	
	// Events
	// We check these periodically.
	// 06:00 = Sunrise
	// 08:00 = Day
	// 18:00 = Sunset
	// 20:00 = Night

/datum/controller/subsystem/weather/Initialize()
	. = ..()
	register_cycle_defaults()

/datum/controller/subsystem/weather/fire()
	// Advance time
	time_of_day += (wait * 0.1) * time_speed // wait is in deciseconds
	if(time_of_day >= 1440)
		time_of_day -= 1440
	
	// Check for state changes based on time
	// This is a simple state machine check. 
	// Optimally we'd queue events, but polling every second is fine for weather.
	check_time_events()

/datum/controller/subsystem/weather/proc/check_time_events()
	var/target_state_name = "Night"
	if(time_of_day >= 360 && time_of_day < 480) // 06:00 - 08:00
		target_state_name = "Sunrise"
	else if(time_of_day >= 480 && time_of_day < 1080) // 08:00 - 18:00
		target_state_name = "Day"
	else if(time_of_day >= 1080 && time_of_day < 1200) // 18:00 - 20:00
		target_state_name = "Sunset"
	else
		target_state_name = "Night"

	// Apply to all Z-levels that are auto-cycling
	// We need a list of which Zs are purely "Auto". 
	// For now, let's assume if they have a weather entity with "Auto" or if we force it.
	// Actually, we should probably store "cycle_enabled" mappings.
	for(var/z in z_states)
		var/datum/weather_state/WS = z_states[z]
		if(WS && WS.cycle_enabled && WS.name != target_state_name)
			transition_z_level(z, target_state_name)

/datum/controller/subsystem/weather/proc/transition_z_level(z, state_name)
	var/datum/weather_state/new_state
	switch(state_name)
		if("Day") new_state = new /datum/weather_state/day
		if("Night") new_state = new /datum/weather_state/night
		if("Sunset") new_state = new /datum/weather_state/sunset
		if("Sunrise") new_state = new /datum/weather_state/sunrise
	
	if(new_state)
		new_state.cycle_enabled = TRUE // Keep cycling on
		set_z_weather(z, new_state)

/datum/controller/subsystem/weather/proc/register_cycle_defaults()
	// If we wanted hardcoded defaults
	return

// Apply weather to a client based on their Z-level
/datum/controller/subsystem/weather/proc/update_client_weather(client/C)
	if(!C || !C.mob) return

	var/z = C.mob.z
	var/datum/weather_state/WS = z_states["[z]"]

	if(!WS)
		// Default to Day (Clear)
		C.mob.special_lighting_unregister_signals()
		return

	switch(WS.name)
		if("Day")
			C.mob.special_lighting_unregister_signals()
		if("Night")
			// If joining/moving to night, we want it dark immediately.
			// Sunset ends at black, so we can trigger sunset and force it to end state?
			// Or just set the overlay manually?
			// For now, let's trigger sunset. The checking logic in trigger_sunset might prevent re-firing if already set.
			// Ideally we have a 'force_night' proc or we just let sunset handle it.
			C.mob.trigger_sunset() 
		if("Sunset")
			C.mob.trigger_sunset()
		if("Sunrise")
			C.mob.trigger_sunrise()

// Register a new state for a Z-level
/datum/controller/subsystem/weather/proc/set_z_weather(z_level, datum/weather_state/WS)
	z_states["[z_level]"] = WS
	// Update all clients on this Z
	for(var/client/C in GLOB.clients)
		if(C.mob && C.mob.z == z_level)
			update_client_weather(C)

// Simple datum to hold weather config
/datum/weather_state
	var/name = "Default"
	var/cycle_enabled = FALSE

/datum/weather_state/day
	name = "Day"

/datum/weather_state/night
	name = "Night"

/datum/weather_state/sunset
	name = "Sunset"

/datum/weather_state/sunrise
	name = "Sunrise"
