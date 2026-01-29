/obj/screen/plane_master/daylight
	name = "daylight"
	plane = DAYLIGHT_PLANE
	screen_loc = "west, south"
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	render_target = "*daylight_overlay"
	alpha = 255 // Hidden from direct view, utilized by Lighting Plane filter
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR

GLOBAL_DATUM_INIT(daylight_controller, /datum/daylight_controller, new)
GLOBAL_DATUM_INIT(global_daylight_plane, /obj/screen/plane_master/daylight, new)

/datum/daylight_phase
	var/color
	var/duration
	var/message

	New(color, duration, message)
		src.color = color
		src.duration = duration
		src.message = message

/datum/daylight_controller
	var/list/phases
	var/total_duration = 0
	var/current_phase_index = 0
	var/current_color = "#000000"

/datum/daylight_controller/New()
	..()
	// Define the cycle here.
	// Format: Color, Duration (deciseconds), Message (optional)
	phases = list(
		new /datum/daylight_phase("#000000", 200,      "Midnight falls."),
		new /datum/daylight_phase("#110500", 100,      null), // Dawn Start
		new /datum/daylight_phase("#9e4f1b", 200,      "The sun rises."),
		new /datum/daylight_phase("#ddd6cc", 1000,     "It is noon."),
		new /datum/daylight_phase("#a35520", 200,      "The sun begins to set."),
		new /datum/daylight_phase("#110500", 100,      "Twilights fades."), // Dusk End
	)
	
	for(var/datum/daylight_phase/P in phases)
		total_duration += P.duration

/datum/daylight_controller/proc/update_cycle()
	if(!total_duration) return

	// We offset by world.time.
	// Note: If you want to sync this to "real" gametime, you might want a specific offset.
	// usage: world.time % total_duration
	
	var/time_in_cycle = world.time % total_duration
	var/accumulated_time = 0
	var/found_index = 0
	var/datum/daylight_phase/current_phase
	var/datum/daylight_phase/next_phase
	var/time_into_phase = 0
	
	for(var/i = 1 to phases.len)
		var/datum/daylight_phase/P = phases[i]
		if(time_in_cycle < accumulated_time + P.duration)
			current_phase = P
			found_index = i
			time_into_phase = time_in_cycle - accumulated_time
			
			// Get next phase (wrap around)
			var/next_i = (i % phases.len) + 1
			next_phase = phases[next_i]
			break
		accumulated_time += P.duration
	
	if(current_phase)
		// Check for phase change to send message
		if(current_phase_index != found_index)
			current_phase_index = found_index
			if(current_phase.message)
				to_chat(world, "<span class='notice'>[current_phase.message]</span>")
		
		var/fraction = time_into_phase / current_phase.duration
		var/target_color = BlendRGB(current_phase.color, next_phase.color, fraction)
		set_color(target_color, 10)

/datum/daylight_controller/proc/set_color(new_color, time = 10)
	current_color = new_color
	animate(GLOB.global_daylight_plane, color = current_color, time = time)

