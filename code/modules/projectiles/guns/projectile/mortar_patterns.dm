/proc/mortar_scatter(turf/center, radius = 3, shell_count = 5, shell_type = "shrapnel", fire_delay = 5)
	if(!center)
		return

	for(var/i in 1 to shell_count)
		var/offset_x = rand(-radius, radius)
		var/offset_y = rand(-radius, radius)
		var/turf/T = locate(center.x + offset_x, center.y + offset_y, center.z)
		if(T)
			spawn((i-1) * fire_delay + rand(0, 5))
				drop_mortar(T, shell_type)

/proc/mortar_line(turf/center, direction = NORTH, shell_count = 5, spacing = 2, shell_type = "shrapnel", fire_delay = 5)
	if(!center)
		return

	var/opposite = turn(direction, 180)

	var/half_count = round((shell_count - 1) / 2)

	for(var/i in 0 to shell_count - 1)
		var/offset = i - half_count
		var/turf/T = center

		if(offset > 0)
			for(var/j in 1 to offset * spacing)
				T = get_step(T, direction)
		else if(offset < 0)
			for(var/j in 1 to abs(offset) * spacing)
				T = get_step(T, opposite)

		if(T)
			spawn(i * fire_delay + rand(0, 3))
				drop_mortar(T, shell_type)

/proc/mortar_line_perpendicular(turf/center, direction = NORTH, shell_count = 5, spacing = 2, shell_type = "shrapnel", fire_delay = 5)
	if(!center)
		return

	var/perpendicular = turn(direction, 90)
	var/opposite_perp = turn(direction, -90)

	var/half_count = round((shell_count - 1) / 2)

	for(var/i in 0 to shell_count - 1)
		var/offset = i - half_count
		var/turf/T = center

		if(offset > 0)
			for(var/j in 1 to offset * spacing)
				T = get_step(T, perpendicular)
		else if(offset < 0)
			for(var/j in 1 to abs(offset) * spacing)
				T = get_step(T, opposite_perp)

		if(T)
			spawn(i * fire_delay + rand(0, 3))
				drop_mortar(T, shell_type)

/proc/mortar_box(turf/center, width = 5, height = 5, shell_type = "shrapnel", fire_delay = 5)
	if(!center)
		return

	var/list/perimeter = list()
	var/half_w = round(width / 2)
	var/half_h = round(height / 2)

	for(var/x in -half_w to half_w)
		var/turf/top = locate(center.x + x, center.y + half_h, center.z)
		var/turf/bottom = locate(center.x + x, center.y - half_h, center.z)
		if(top)
			perimeter += top
		if(bottom)
			perimeter += bottom

	for(var/y in (-half_h + 1) to (half_h - 1))
		var/turf/left = locate(center.x - half_w, center.y + y, center.z)
		var/turf/right = locate(center.x + half_w, center.y + y, center.z)
		if(left)
			perimeter += left
		if(right)
			perimeter += right

	var/delay = 0
	for(var/turf/T in perimeter)
		spawn(delay)
			drop_mortar(T, shell_type)
		delay += fire_delay + rand(0, 2)

/proc/mortar_creep(turf/start, direction = NORTH, waves = 3, shells_per_wave = 5, advance_distance = 3, shell_type = "shrapnel", fire_delay = 5)
	if(!start)
		return

	var/turf/wave_center = start

	for(var/wave in 1 to waves)
		mortar_line_perpendicular(wave_center, direction, shells_per_wave, 2, shell_type, fire_delay)

		sleep(fire_delay * 3)

		for(var/i in 1 to advance_distance)
			wave_center = get_step(wave_center, direction)
			if(!wave_center)
				return

/proc/mortar_concentrated(turf/center, shell_count = 5, shell_type = "shrapnel", fire_delay = 5)
	if(!center)
		return

	for(var/i in 1 to shell_count)
		var/offset_x = rand(-2, 2)
		var/offset_y = rand(-2, 2)
		var/turf/T = locate(center.x + offset_x, center.y + offset_y, center.z)
		if(T)
			spawn((i-1) * fire_delay + rand(0, 3))
				drop_mortar(T, shell_type)
