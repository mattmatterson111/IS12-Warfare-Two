/datum/universal_state/nuclear_explosion
	name = "Nuclear Demolition Warhead"
	var/atom/explosion_source
	var/obj/screen/cinematic
	var/dramatic_time = 60 SECONDS
	var/end_early = FALSE

/datum/universal_state/nuclear_explosion/New(atom/nuke, var/how_long, var/early = FALSE)
	explosion_source = nuke

	//create the cinematic screen obj
	cinematic = new
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.plane = HUD_PLANE
	cinematic.layer = HUD_ABOVE_ITEM_LAYER
	cinematic.mouse_opacity = 2
	cinematic.screen_loc = "1,0"

	if(how_long)
		dramatic_time = how_long SECONDS

	end_early = early

/datum/universal_state/nuclear_explosion/OnEnter()
	if(ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1

	sleep(dramatic_time)
	sound_to(world, sound('sound/effects/fadetoblack.ogg'))
	start_cinematic_intro()
	sleep(4 SECONDS)

	var/turf/T = get_turf(explosion_source)
	if(isStationLevel(T.z))
		sound_to(world, sound('sound/effects/nuclear.ogg'))//makes no sense if you're not on the station but whatever
		if(end_early)
			spawn(15) // cant use sleep here, messes with the rest of the bs
				for(var/client/C in GLOB.clients)
					winset(C, "", "command=.quit")
					//C.Del()
				spawn(5)
					world.Del()
		dust_mobs(GLOB.using_map.station_levels)
		play_cinematic_station_destroyed()
		to_world("<span class='danger'>[GLOB.war_lore.name] was destroyed by the nuclear blast!</span>")
		sleep(65)
	else
		to_world("<span class='danger'>A nuclear device was set off, but the explosion was out of reach of the [station_name()]!</span>")

		dust_mobs(list(T.z))
		play_cinematic_station_unaffected()
/*
	spawn(100)
		for(var/mob/living/L in GLOB.living_mob_list_)
			if(L.client)
				L.client.screen -= cinematic
*/
	sound_to(world, sound('sound/effects/the_end.ogg'))
	if(ticker && ticker.mode)
		ticker.mode.station_was_nuked = 1
		ticker.mode.explosion_in_progress = 0
		if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			universe_has_ended = 1
			sleep(15)
			for(var/client/C in GLOB.clients)
				winset(C, "", "command=.quit")
				//C.Del()
			sleep(5)
			world.Del()


/datum/universal_state/nuclear_explosion/OnExit()
	if(ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 0

/datum/universal_state/nuclear_explosion/proc/dust_mobs(var/list/affected_z_levels)
	for(var/mob/living/L in SSmobs.mob_list)
		var/turf/T = get_turf(L)
		if(T && (T.z in affected_z_levels))
			//this is needed because dusting resets client screen 1.5 seconds after being called (delayed due to the dusting animation)
			var/mob/ghost = L.ghostize(0) //So we ghostize them right beforehand instead
			if(ghost && ghost.client)
				ghost.client.screen += cinematic
			L.dust() //then dust the body

/datum/universal_state/nuclear_explosion/proc/show_cinematic_to_players()
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			M.client.screen += cinematic

/datum/universal_state/nuclear_explosion/proc/start_cinematic_intro()
	//for(var/mob/M in GLOB.player_list) //I guess so that people in the lobby only hear the explosion
	//	sound_to(M, sound('sound/machines/Alarm.ogg'))

	show_cinematic_to_players()
	flick("intro_nuke",cinematic)
	sleep(3 SECONDS)

/datum/universal_state/nuclear_explosion/proc/play_cinematic_station_destroyed()
	flick("station_explode_fade_red",cinematic)
	//cinematic.icon_state = "summary_selfdes"
	sleep(100)

/datum/universal_state/nuclear_explosion/proc/play_cinematic_station_unaffected()
	cinematic.icon_state = "station_intact"
	sleep(5)
	sound_to(world, sound('sound/effects/explosionfar.ogg'))//makes no sense if you are on the station but whatever


	sleep(75)


//MALF
/datum/universal_state/nuclear_explosion/malf/start_cinematic_intro()
	for(var/mob/M in GLOB.player_list) //I guess so that people in the lobby only hear the explosion
		to_chat(M, sound('sound/machines/Alarm.ogg'))

	sleep(28)

	show_cinematic_to_players()
	flick("intro_malf",cinematic)
	sleep(72)
	flick("intro_nuke",cinematic)
	sleep(30)

