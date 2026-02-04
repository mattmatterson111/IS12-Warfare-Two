//TODO: Flash range does nothing currently

proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, z_transfer = UP|DOWN, shaped, silent, particles, color = LIGHT_COLOR_LAVA, autosize = TRUE, large, sizeofboom, smoke, explosionsound, farexplosionsound)
	var/multi_z_scalar = 0.35
	src = null	//so we don't abort once src is deleted
	spawn(0)
		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		// Handles recursive propagation of explosions.
		if(z_transfer)
			var/adj_dev   = max(0, (multi_z_scalar * devastation_range) - (shaped ? 2 : 0) )
			var/adj_heavy = max(0, (multi_z_scalar * heavy_impact_range) - (shaped ? 2 : 0) )
			var/adj_light = max(0, (multi_z_scalar * light_impact_range) - (shaped ? 2 : 0) )
			var/adj_flash = max(0, (multi_z_scalar * flash_range) - (shaped ? 2 : 0) )


			if(adj_dev > 0 || adj_heavy > 0)
				if(HasAbove(epicenter.z) && z_transfer & UP)
					explosion(GetAbove(epicenter), round(adj_dev), round(adj_heavy), round(adj_light), round(adj_flash), 0, UP, shaped)
				if(HasBelow(epicenter.z) && z_transfer & DOWN)
					explosion(GetBelow(epicenter), round(adj_dev), round(adj_heavy), round(adj_light), round(adj_flash), 0, DOWN, shaped)

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flash_range)

		// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
		// Stereo users will also hear the direction of the explosion!
		// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
		// 3/7/14 will calculate to 80 + 35
		var/far_dist = 0
		far_dist += heavy_impact_range * 5
		far_dist += devastation_range * 20
		var/frequency = get_rand_frequency()
		if(!silent)
			for(var/mob/M in GLOB.player_list)
				if(M.z == epicenter.z)
					var/turf/M_turf = get_turf(M)
					var/dist = get_dist(M_turf, epicenter)
					// If inside the blast radius + world.view - 2
					if(dist <= round(max_range + world.view - 2, 1))
						if(devastation_range > 0)
							if(!explosionsound)
								M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
							else
								M.playsound_local(epicenter, get_sfx(explosionsound), 100, 1, frequency, falloff = 5)
							shake_camera(M, Clamp(devastation_range, 3, 10), 2)
						else
							if(!explosionsound)
								M.playsound_local(epicenter, get_sfx("explosion_small"), 100, 1, frequency, falloff = 5)
							else
								M.playsound_local(epicenter, get_sfx(explosionsound), 100, 1, frequency, falloff = 5)
							shake_camera(M, 4, 1)


						//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

					else if(dist <= far_dist)
						var/far_volume = Clamp(far_dist*3, 30, 50) // Volume is based on explosion size and dist
						far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
						if(devastation_range > 0)
							if(!farexplosionsound)
								M.playsound_local(epicenter, pick('sound/effects/explosionfarnew.ogg','sound/effects/explosionfar2.ogg','sound/effects/explosionfar3.ogg','sound/effects/explosionfar4.ogg'), far_volume * 2, 1, frequency, falloff = 5)
							else
								M.playsound_local(epicenter, get_sfx(farexplosionsound), far_volume * 2, 1, frequency, falloff = 5)
							shake_camera(M, 5, 1)
						else
							if(!farexplosionsound)
								M.playsound_local(epicenter, 'sound/effects/explosionsmallfarnew.ogg', far_volume * 2, 1, frequency, falloff = 5)
							else
								M.playsound_local(epicenter, get_sfx(farexplosionsound), far_volume * 2, 1, frequency, falloff = 5)
		if(particles)
			var/boom_range
			if(!sizeofboom)
				boom_range = max_range
			else
				boom_range = sizeofboom
			if(autosize)
				if(devastation_range > 0)
					new /obj/effect/temp_visual/explosion(epicenter, boom_range, color, FALSE, TRUE)
				else if(heavy_impact_range > 0)
					new /obj/effect/temp_visual/explosion(epicenter, boom_range, color, FALSE, FALSE)
				else if(light_impact_range > 0)
					new /obj/effect/temp_visual/explosion(epicenter, boom_range, color, TRUE, FALSE)
			else if(!autosize)
				if(large)
					new /obj/effect/temp_visual/explosion(epicenter, boom_range, color, FALSE, TRUE)
				else
					new /obj/effect/temp_visual/explosion(epicenter, boom_range, color, TRUE, FALSE)

		var/approximate_intensity = (devastation_range * 3) + (heavy_impact_range * 2) + light_impact_range
		// Large enough explosion. For performance reasons, powernets will be rebuilt manually
		if(!defer_powernet_rebuild && (approximate_intensity > 25))
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			if(smoke)
				E.smoke = TRUE
			E.set_up(epicenter)
			E.start()

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z
		if(config.use_recursive_explosions)
			var/power = devastation_range * 2 + heavy_impact_range + light_impact_range //The ranges add up, ie light 14 includes both heavy 7 and devestation 3. So this calculation means devestation counts for 4, heavy for 2 and light for 1 power, giving us a cap of 27 power.
			explosion_rec(epicenter, power, shaped)
		else
			for(var/turf/T in trange(max_range, epicenter))
				var/dist = sqrt((T.x - x0)**2 + (T.y - y0)**2)

				if(dist < devastation_range)		dist = 1
				else if(dist < heavy_impact_range)	dist = 2
				else if(dist < light_impact_range)	dist = 3
				else								continue

				T.ex_act(dist)
				if(!T)
					T = locate(x0,y0,z0)
				for(var/atom_movable in T.contents)	//bypass type checking since only atom/movable can be contained by turfs anyway
					var/atom/movable/AM = atom_movable
					if(AM && AM.simulated && !T.protects_atom(AM))
						AM.ex_act(dist)

		var/took = (world.timeofday-start)/10
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2) world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)


/proc/add_crater(turf/T, scale = 1.0)
	if(!T)
		return
	var/image/crater = image(icon='icons/turf/crater64.dmi', icon_state="dirt_shell_alt", dir=pick(GLOB.cardinal), layer = BASE_ABOVE_OBJ_LAYER, pixel_x = rand(-14,-16), pixel_y = rand(-14,-16))
	crater.transform = matrix() * scale
	T.overlays += crater
	
	if(scale >= 1.1)
		if(!locate(/obj/effect/crater_cover) in T)
			var/obj/effect/crater_cover/CC = new(T)
			CC.cover_strength = Clamp(30 * scale, 30, 60)

proc/drop_mortar(turf/dropped, mortar)
	var/direction = pick(GLOB.cardinal)
	var/turf/dropped_turf = get_step(dropped,direction)
	var/thismortarnoise = pick('sound/effects/mortar_fallingalt.ogg', 'sound/effects/mortar_fallingalt2.ogg')
	var/delay
	playsound(dropped_turf, thismortarnoise, 100, FALSE)
	var/obj/effect/shadow/S = new(dropped_turf)
	
	switch(thismortarnoise)
		if('sound/effects/mortar_fallingalt.ogg') delay = 3.9
		if('sound/effects/mortar_fallingalt2.ogg') delay = 2.25

	var/is_ballistic = (mortar == "bunker-buster")
	if(is_ballistic)
		delay += 3.0

	spawn(delay SECONDS)
		qdel(S)
		if(mortar == "rflare" || mortar == "bflare")
			if(mortar == "rflare") new /obj/mortar/flare(dropped_turf)
			else new /obj/mortar/flare/blue(dropped_turf)
			return

		var/power_factor = rand(8, 12) / 10
		
		explosion(dropped_turf, 1 * power_factor, 1 * power_factor, 1 * power_factor, 1 * power_factor, particles = TRUE, autosize = FALSE, sizeofboom = 1 * power_factor, large = TRUE, explosionsound = pick('sound/effects/farexplonewnew1.ogg','sound/effects/farexplonewnew2.ogg','sound/effects/farexplonewnew3.ogg','sound/effects/explosionfarnew.ogg','sound/effects/explosionfar2.ogg','sound/effects/explosionfar3.ogg','sound/effects/explosionfar4.ogg'))

		var/crater_scale = 1.0 * power_factor
		switch(mortar)
			if("cluster") crater_scale *= 0.6
			if("smoke") crater_scale *= 0.5
			if("concussion") crater_scale *= 1.3
			if("incendiary") crater_scale *= 0.8
			if("bunker-buster") crater_scale *= 2.0

		spawn(5)
			add_crater(dropped_turf, crater_scale)

		new /obj/effect/lingering_haze(dropped_turf, 20)

		switch(mortar)
			if("shrapnel") new /obj/mortar/frag(dropped_turf)
			if("gas") new /obj/mortar/gas(dropped_turf)
			if("fire") new /obj/mortar/fire(dropped_turf)
			if("smoke") new /obj/mortar/smoke(dropped_turf)
			if("incendiary") new /obj/mortar/incendiary(dropped_turf)
			if("cluster") new /obj/mortar/cluster(dropped_turf)
			if("concussion") new /obj/mortar/concussion(dropped_turf)
			if("bunker-buster") new /obj/mortar/ballistic(dropped_turf)

		for(var/mob/living/carbon/human/H in range(2 * power_factor, dropped_turf))
			if(H.stat == DEAD) continue
			if(H.ear_damage != null)
				H.ear_damage += rand(10, 20) * power_factor
			to_chat(H, "<span class='danger'>Your ears are ringing!</span>")
			shake_camera(H, 15 * power_factor, 3)

/obj/effect/shadow
	name = "Shadow"
	icon = 'icons/effects/effects.dmi'
	icon_state = "target"
	density = FALSE


proc/artillery_barage(var/x, var/y, var/z, mortartype="shrapnel", bypass_restrictions = FALSE, maxamount = 10)

	var/x_random = x
	var/y_random = y
	var/sleep_randomizer = 10
	var/turf/turf_to_drop

	for(var/i = 1, i< maxamount, i++)
		x_random = x + (rand(0, 6) -3 )
		y_random = y + (rand(0, 6) -3 )
		sleep_randomizer = rand(8, 25)
		turf_to_drop = locate(x_random, y_random, z)
		if(bypass_restrictions)
			drop_mortar(turf_to_drop, mortartype)
			sleep(sleep_randomizer)
			continue
		if(istype(turf_to_drop.loc, /area/warfare/battlefield/no_mans_land) || istype(turf_to_drop.loc, /area/warfare/battlefield/capture_point/mid))
			drop_mortar(turf_to_drop, mortartype)
		else
			world.log << "Invalid landing zone. [x_random], [y_random]... defaulting to original position."
			turf_to_drop = locate(x,y,2)
			drop_mortar(turf_to_drop, mortartype)


		sleep(sleep_randomizer)
