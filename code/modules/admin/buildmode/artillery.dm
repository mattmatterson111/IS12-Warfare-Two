/datum/build_mode/artillery
	name = "Artillery"
	icon_state = "buildmode1"

	var/shell_type = "shrapnel"
	var/pattern = "scatter"
	var/shell_count = 5
	var/strike_delay = 35
	var/fire_delay = 5
	var/firing_sfx = TRUE

/datum/build_mode/artillery/Help()
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Click        = Fire artillery strike at location</span>")
	to_chat(user, "<span class='notice'>Right Click       = Configure (shell type, pattern, count)</span>")
	to_chat(user, "<span class='notice'>Direction Button  = Sets direction for line/creep patterns</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Current: [pattern] | [shell_type] | [shell_count] shells ([fire_delay] ticks between shells)</span>")
	to_chat(user, "<span class='notice'>SFX: [firing_sfx ? "ON" : "OFF"]</span>")

/datum/build_mode/artillery/Configurate()
	var/list/options = list("Shell Type", "Pattern", "Shell Count", "Strike Delay", "Fire Delay", "Toggle Firing SFX")
	var/choice = input("Configure Artillery", "Artillery") as null|anything in options

	switch(choice)
		if("Shell Type")
			var/list/types = list("shrapnel", "smoke", "incendiary", "cluster", "concussion", "gas", "bunker-buster", "rflare", "bflare")
			var/new_type = input("Select shell type", "Shell Type", shell_type) as null|anything in types
			if(new_type)
				shell_type = new_type

		if("Pattern")
			var/list/patterns = list("scatter", "concentrated", "line", "box", "creep")
			var/new_pattern = input("Select pattern", "Pattern", pattern) as null|anything in patterns
			if(new_pattern)
				pattern = new_pattern

		if("Shell Count")
			var/new_count = input("Number of shells (1-20)", "Shell Count", shell_count) as num|null
			if(new_count)
				shell_count = Clamp(new_count, 1, 20)

		if("Strike Delay")
			var/new_delay = input("Delay before impact (ticks)", "Delay", strike_delay) as num|null
			if(new_delay)
				strike_delay = max(0, new_delay)

		if("Fire Delay")
			var/new_delay = input("Delay between mortars (ticks)", "Fire Delay", fire_delay) as num|null
			if(new_delay)
				fire_delay = max(0, new_delay)

		if("Toggle Firing SFX")
			firing_sfx = !firing_sfx

	to_chat(user, "<span class='notice'>Artillery: [pattern] | [shell_type] | [shell_count] shells | [fire_delay] fire delay | SFX: [firing_sfx ? "ON" : "OFF"]</span>")

/datum/build_mode/artillery/OnClick(var/atom/A, var/list/parameters)
	if(parameters["left"])
		var/turf/T = get_turf(A)
		if(!T)
			return

		var/direction = host.dir

		to_chat(user, "<span class='warning'>Firing [pattern] artillery strike at [T.x],[T.y]!</span>")
		Log("Artillery [pattern] [shell_type] x[shell_count] at [T.x],[T.y],[T.z]")

		spawn(0)
			if(firing_sfx)
				sound_to(world, 'sound/effects/arty_distant.ogg')
				sleep(20)

			switch(pattern)
				if("scatter")
					mortar_scatter(T, 3, shell_count, shell_type, fire_delay)
				if("concentrated")
					mortar_concentrated(T, shell_count, shell_type, fire_delay)
				if("line")
					mortar_line(T, direction, shell_count, 2, shell_type, fire_delay)
				if("box")
					mortar_box(T, 5, 5, shell_type, fire_delay)
				if("creep")
					mortar_creep(T, direction, 3, shell_count, 3, shell_type, fire_delay)

	else if(parameters["right"])
		Configurate()
