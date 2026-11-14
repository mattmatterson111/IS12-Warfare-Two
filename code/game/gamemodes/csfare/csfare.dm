#define CSFARE_MAX_TEAM_SIZE 10
#define CSFARE_MATCHES_PER_ROUND 10
#define CSFARE_PREPARATION_TIME (1 MINUTES)
#define CSFARE_MATCH_TIME (2 MINUTES + 30 SECONDS)
#define CSFARE_BOMB_TIME (40 SECONDS)
#define CSFARE_RETURN_TO_LOBBY 2

/datum/game_mode/csfare
	name = "CSFare"
	config_tag = "csfare"
	round_description = "Redistani Counter-Terrorism Forces must stop the Blusnian terrorists from planting the bomb!"
	extended_round_description = "Ten matches!"
	required_players = 0
	votable = FALSE
	auto_recall_shuttle = TRUE

	var/list/red_roster = list()
	var/list/blue_roster = list()
	var/list/round_wins = list(RED_TEAM = 0, BLUE_TEAM = 0)
	var/current_match = 1
	var/matches_completed = 0
	var/preparation_end_time
	var/match_end_time
	var/preparing = FALSE
	var/match_in_progress = FALSE
	var/round_complete = FALSE
	var/job_setup_valid = TRUE
	var/red_soldier_original_outfit
	var/blue_soldier_original_outfit
	var/soldier_outfits_overridden = FALSE
	var/obj/item/plastique/blue/csfare/planted_bomb
	var/obj/item/plastique/blue/csfare/map_bomb
	var/turf/map_bomb_start_turf
	var/bomb_status = "Not planted"
	var/selected_map_name
	var/selected_map_min_z
	var/selected_map_max_z
	var/turf/red_spawn_turf
	var/turf/blue_spawn_turf
	var/list/red_spawn_turfs = list()
	var/list/blue_spawn_turfs = list()

/datum/game_mode/csfare/New()
	..()
	name = "CSFare"

/datum/game_mode/csfare/pre_setup()
	..()
	var/datum/job/red_soldier = SSjobs.GetJobByType(/datum/job/soldier/red_soldier)
	var/datum/job/blue_soldier = SSjobs.GetJobByType(/datum/job/soldier/blue_soldier)
	if(!red_soldier || !blue_soldier)
		log_error("CSFare requires the red and blue soldiers on the active map")
		job_setup_valid = TRUE
		return TRUE

	if(!load_selected_map())
		job_setup_valid = TRUE
		return TRUE

	for(var/datum/job/job in SSjobs.occupations)
		job.total_positions = 0
		job.spawn_positions = 0

	red_soldier.total_positions = CSFARE_MAX_TEAM_SIZE
	red_soldier.spawn_positions = CSFARE_MAX_TEAM_SIZE
	blue_soldier.total_positions = CSFARE_MAX_TEAM_SIZE
	blue_soldier.spawn_positions = CSFARE_MAX_TEAM_SIZE

	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.ready || !player.client || !player.mind)
			continue
		if(player.client.prefs.alternate_option == CSFARE_RETURN_TO_LOBBY)
			player.ready = FALSE
			continue

		var/datum/job/team_job
		if(player.client.warfare_faction == RED_TEAM)
			team_job = red_soldier
		else if(player.client.warfare_faction == BLUE_TEAM)
			team_job = blue_soldier

		if(!team_job || !SSjobs.AssignRole(player, team_job.title))
			player.ready = FALSE
			to_chat(player, "<span class='warning'>Teams are full. You are allowed to spectate.</span>")
			player.new_player_panel()

	for(var/obj/effect/landmark/start/spawn_point in landmarks_list)
		var/turf/spawn_turf = get_turf(spawn_point)
		if(selected_map_min_z && (spawn_turf.z < selected_map_min_z || spawn_turf.z > selected_map_max_z))
			continue
		if(spawn_point.name == red_soldier.title && !red_spawn_turf)
			red_spawn_turf = spawn_turf
		if(spawn_point.name == red_soldier.title)
			red_spawn_turfs |= spawn_turf
		if(spawn_point.name == blue_soldier.title)
			if(!blue_spawn_turf)
				blue_spawn_turf = spawn_turf
			blue_spawn_turfs |= spawn_turf

	if(!red_spawn_turfs.len || !blue_spawn_turfs.len)
		log_error("CSFare requires red and blue soldier spawn landmarks on the active map")
		job_setup_valid = TRUE
		return TRUE

	red_spawn_turf = pick(red_spawn_turfs)
	blue_spawn_turf = pick(blue_spawn_turfs)
	if(!validate_map_objects())
		job_setup_valid = TRUE
		return TRUE
	if(!soldier_outfits_overridden)
		red_soldier_original_outfit = red_soldier.outfit_type
		blue_soldier_original_outfit = blue_soldier.outfit_type
		red_soldier.outfit_type = /decl/hierarchy/outfit/job/redsoldier/unarmed
		blue_soldier.outfit_type = /decl/hierarchy/outfit/job/bluesoldier/unarmed
		soldier_outfits_overridden = TRUE
	return TRUE

/datum/game_mode/csfare/proc/load_selected_map()
	var/list/map_files = get_csfare_map_files()
	var/map_path = GLOB.csfare_selected_map
	GLOB.csfare_selected_map = null

	if(!map_path)
		if(!map_files.len)
			selected_map_name = "Current map (no .dmm files found)"
			return TRUE
		var/map_file = pick(map_files)
		map_path = "maps/csfare/[map_file]"
	else
		var/map_found = FALSE
		for(var/available_map_file in map_files)
			if("maps/csfare/[available_map_file]" == map_path)
				map_found = TRUE
				break
		if(!map_found)
			log_error("The selected CSFare map '[map_path]' is not available in maps/csfare")
			return FALSE

	var/map_file_name = copytext(map_path, length("maps/csfare/") + 1)
	selected_map_name = copytext(map_file_name, 1, length(map_file_name) - 3)
	var/datum/map_template/template = new(list(map_path), selected_map_name)
	if(!template.width || !template.height)
		log_error("CSFare map '[map_path]' could not be read as a .dmm")
		qdel(template)
		return FALSE

	clear_coldfare_map()

	var/previous_max_z = world.maxz
	var/turf/map_center = template.load_new_z()
	if(!map_center || world.maxz <= previous_max_z)
		log_error("CSFare map '[map_path]' failed to load into a new z-level")
		qdel(template)
		return FALSE

	selected_map_min_z = previous_max_z + 1
	selected_map_max_z = world.maxz
	if(!GLOB.using_map.map_levels)
		GLOB.using_map.map_levels = list()
	for(var/z_level = selected_map_min_z, z_level <= selected_map_max_z, z_level++)
		GLOB.using_map.station_levels |= z_level
		GLOB.using_map.contact_levels |= z_level
		GLOB.using_map.map_levels |= z_level

	qdel(template)
	return TRUE

/datum/game_mode/csfare/proc/clear_coldfare_map()
	if(!GLOB.using_map || GLOB.using_map.name != "Coldfare")
		return

	// Compiled-in z-levels cannot be unloaded safely, so clear them and leave their indices allocated.
	var/list/z_levels_to_clear = GLOB.using_map.station_levels.Copy()
	for(var/z_level in z_levels_to_clear)
		if(!isnum(z_level) || z_level < 1 || z_level > world.maxz)
			continue

		for(var/turf/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
			for(var/obj/object in T)
				qdel(object)
			for(var/mob/unkeyed_mob in T)
				if(!unkeyed_mob.key)
					qdel(unkeyed_mob)
			T.ChangeTurf(/turf/space)

		GLOB.using_map.station_levels -= z_level
		GLOB.using_map.player_levels -= z_level
		GLOB.using_map.contact_levels -= z_level
		if(GLOB.using_map.map_levels)
			GLOB.using_map.map_levels -= z_level
		GLOB.using_map.base_turf_by_z -= num2text(z_level)
		GLOB.using_map.accessible_z_levels -= num2text(z_level)

	log_game("Cleared the compiled Coldfare map before loading CSFare.")

/datum/game_mode/csfare/post_job_assignment()
	for(var/datum/job/job in SSjobs.occupations)
		job.total_positions = 0
		job.spawn_positions = 0
		job.current_positions = 0

	var/datum/job/red_soldier = SSjobs.GetJobByType(/datum/job/soldier/red_soldier)
	var/datum/job/blue_soldier = SSjobs.GetJobByType(/datum/job/soldier/blue_soldier)
	if(!red_soldier || !blue_soldier)
		return

	red_soldier.total_positions = CSFARE_MAX_TEAM_SIZE
	red_soldier.spawn_positions = CSFARE_MAX_TEAM_SIZE
	blue_soldier.total_positions = CSFARE_MAX_TEAM_SIZE
	blue_soldier.spawn_positions = CSFARE_MAX_TEAM_SIZE
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.mind)
			continue
		if(player.mind.assigned_role == red_soldier.title)
			red_soldier.current_positions++
		else if(player.mind.assigned_role == blue_soldier.title)
			blue_soldier.current_positions++

/datum/game_mode/csfare/startRequirements()
	if(!job_setup_valid)
		return "CSFare requires red and blue soldier jobs, spawn landmarks, both bomb sites, team cargo stations and pads, two preparation grilles, and exactly one CSFare bomb on the active map"
	var/setup_error = ..()
	if(setup_error)
		restore_soldier_outfits()
	return setup_error

/datum/game_mode/csfare/proc/restore_soldier_outfits()
	if(!soldier_outfits_overridden)
		return
	var/datum/job/red_soldier = SSjobs.GetJobByType(/datum/job/soldier/red_soldier)
	var/datum/job/blue_soldier = SSjobs.GetJobByType(/datum/job/soldier/blue_soldier)
	if(!red_soldier || !blue_soldier)
		log_error("CSFare could not restore the Red and Blue Soldier outfits.")
		return
	red_soldier.outfit_type = red_soldier_original_outfit
	blue_soldier.outfit_type = blue_soldier_original_outfit
	soldier_outfits_overridden = FALSE

/datum/game_mode/csfare/post_setup()
	..()
	for(var/mob/living/carbon/human/player in GLOB.human_mob_list)
		if(!player.client)
			continue
		if(player.warfare_faction == RED_TEAM && player.mind && player.mind.assigned_role == "Red Soldier")
			red_roster |= player.client
			var/turf/red_turf = get_team_spawn_turf(RED_TEAM)
			if(red_turf)
				player.forceMove(red_turf)
		else if(player.warfare_faction == BLUE_TEAM && player.mind && player.mind.assigned_role == "Blue Soldier")
			blue_roster |= player.client
			var/turf/blue_turf = get_team_spawn_turf(BLUE_TEAM)
			if(blue_turf)
				player.forceMove(blue_turf)

	GLOB.faction_dosh[RED_TEAM] = 15
	GLOB.faction_dosh[BLUE_TEAM] = 15
	spawn(60)
		for(var/obj/machinery/kaos/cargo_machine/csfare/machine in world)
			if(is_loaded_map_object(machine))
				machine.reconnectpads()

	preparing = TRUE
	preparation_end_time = world.time + CSFARE_PREPARATION_TIME
	set_preparation_grilles(TRUE)
	to_world("<span class='notice'><b>CSFare map selected: [selected_map_name]. Match [current_match]/[CSFARE_MATCHES_PER_ROUND] preparation begins. Deploy in 1 minute!</b></span>")
	update_huds()

/datum/game_mode/csfare/process()
	update_huds()
	if(round_complete)
		return

	if(preparing && world.time >= preparation_end_time)
		start_match()

	if(!match_in_progress)
		return

	if(planted_bomb && world.time >= planted_bomb.detonation_time)
		planted_bomb.detonate()
		return

	if(red_roster.len && blue_roster.len)
		var/red_alive = count_alive(red_roster)
		var/blue_alive = count_alive(blue_roster)
		if(!red_alive)
			finish_match(BLUE_TEAM, "the Blue team eliminated every Red player")
			return
		if(!blue_alive)
			finish_match(RED_TEAM, "the Red team eliminated every Blue player")
			return

	if(!planted_bomb && world.time >= match_end_time)
		finish_match(RED_TEAM, "time expired before the bomb was planted")

/datum/game_mode/csfare/check_finished()
	return round_complete

/datum/game_mode/csfare/check_win()
	return

/datum/game_mode/csfare/declare_completion()
	set waitfor = FALSE
	restore_soldier_outfits()
	to_world("<span class='notice'><b>CSFare is complete! Red: [round_wins[RED_TEAM]] match wins; Blue: [round_wins[BLUE_TEAM]] match wins.</b></span>")
	master_mode = "extended"
	world.save_mode(master_mode)

/datum/game_mode/csfare/handle_latejoin(mob/living/carbon/human/character)
	..()
	if(!character || !character.client)
		return
	if(character.warfare_faction == RED_TEAM && character.mind && character.mind.assigned_role == "Red Soldier")
		red_roster |= character.client
		var/turf/red_turf = get_team_spawn_turf(RED_TEAM)
		if(red_turf)
			character.forceMove(red_turf)
	else if(character.warfare_faction == BLUE_TEAM && character.mind && character.mind.assigned_role == "Blue Soldier")
		blue_roster |= character.client
		var/turf/blue_turf = get_team_spawn_turf(BLUE_TEAM)
		if(blue_turf)
			character.forceMove(blue_turf)

/datum/game_mode/csfare/proc/start_match()
	preparing = FALSE
	match_in_progress = TRUE
	match_end_time = world.time + CSFARE_MATCH_TIME
	bomb_status = "Not planted"
	to_world("<span class='notice'><b>CSFare [current_match]/[CSFARE_MATCHES_PER_ROUND] has started!</b></span>")
	set_preparation_grilles(FALSE)
	give_bomb_to_blue()

/datum/game_mode/csfare/proc/finish_match(winning_team, reason)
	if(!match_in_progress || round_complete)
		return

	match_in_progress = FALSE
	if(winning_team == RED_TEAM || winning_team == BLUE_TEAM)
		round_wins[winning_team]++
		to_world("<span class='notice'><b>[winning_team] wins CSFare Match [current_match]: [reason]!</b></span>")
	else
		to_world("<span class='notice'><b>CSFare Match [current_match] ended without a winner: [reason].</b></span>")

	matches_completed++
	if(planted_bomb)
		if(planted_bomb.defused)
			bomb_status = "Defused"
		else if(reason == "the bomb detonated")
			bomb_status = "Detonated"
		else
			bomb_status = "Cancelled"
	planted_bomb = null
	return_map_bomb()
	clear_unanchored_floor_objects()

	var/restore_eliminated_players = matches_completed < CSFARE_MATCHES_PER_ROUND
	reset_roster(red_roster, RED_TEAM, restore_eliminated_players)
	reset_roster(blue_roster, BLUE_TEAM, restore_eliminated_players)

	if(matches_completed >= CSFARE_MATCHES_PER_ROUND)
		round_complete = TRUE
		master_mode = "extended"
		world.save_mode(master_mode)
		to_world("<span class='notice'><b>The CSFare round is over. The round will restart to normal warfare.</b></span>")
		if(config.continous_rounds)
			spawn(ticker.restart_timeout)
				if(round_complete)
					world.Reboot()
		update_huds()
		return

	current_match++
	preparing = TRUE
	preparation_end_time = world.time + CSFARE_PREPARATION_TIME
	set_preparation_grilles(TRUE)
	to_world("<span class='notice'><b>Match [current_match]/[CSFARE_MATCHES_PER_ROUND] preparation begins. The next match starts in 1 minute!</b></span>")

/datum/game_mode/csfare/proc/handle_player_death(mob/living/carbon/human/victim)
	if(!match_in_progress || !victim)
		return

	var/datum/client_lite/killer_lite = victim.last_attacker_ ? victim.last_attacker_.client : null
	var/killer_name = victim.last_attacker_ ? victim.last_attacker_.name : null
	var/client/killer_client
	if(killer_lite && killer_lite.key)
		for(var/client/connected_client in GLOB.clients)
			if(ckey(connected_client.key) == ckey(killer_lite.key))
				killer_client = connected_client
				break

	if(killer_client && (killer_client.warfare_faction == RED_TEAM || killer_client.warfare_faction == BLUE_TEAM) && killer_client.warfare_faction != victim.warfare_faction)
		GLOB.faction_dosh[killer_client.warfare_faction] += 30
		to_world("<span class='danger'><b>[killer_name] eliminated [victim.real_name]. [killer_client.warfare_faction] earned 30 credits</b></span>")
	else if(killer_name)
		to_world("<span class='danger'><b>[killer_name] eliminated [victim.real_name].</b></span>")
	else
		to_world("<span class='danger'><b>[victim.real_name] was eliminated.</b></span>")

	if(victim.warfare_faction == RED_TEAM)
		SSwarfare.red.team -= victim
	else if(victim.warfare_faction == BLUE_TEAM)
		SSwarfare.blue.team -= victim

/datum/game_mode/csfare/proc/give_bomb_to_blue()
	if(!map_bomb || QDELETED(map_bomb))
		log_error("CSFare cannot give out the map-placed bomb because it is missing.")
		return

	map_bomb.reset_for_match()
	var/list/available_carriers = list()
	for(var/client/player_client in blue_roster)
		var/mob/living/carbon/human/player = get_roster_body(player_client)
		if(player && player.stat != DEAD)
			available_carriers |= player
	if(available_carriers.len)
		var/mob/living/carbon/human/carrier = pick(available_carriers)
		if(!carrier.put_in_hands(map_bomb))
			map_bomb.forceMove(get_turf(carrier))
	else if(blue_spawn_turf)
		map_bomb.forceMove(blue_spawn_turf)

/datum/game_mode/csfare/proc/return_map_bomb()
	if(!map_bomb || QDELETED(map_bomb))
		return
	map_bomb.reset_for_match()
	if(map_bomb_start_turf)
		map_bomb.forceMove(map_bomb_start_turf)

/datum/game_mode/csfare/proc/register_bomb(obj/item/plastique/blue/csfare/bomb)
	if(!match_in_progress || world.time >= match_end_time || planted_bomb)
		return FALSE
	planted_bomb = bomb
	bomb_status = "Planted"
	match_end_time = 0
	to_world("<span class='danger'><b>The bomb has been planted at [bomb.target.name]! It will detonate in 40 seconds!</b></span>")
	return TRUE

/datum/game_mode/csfare/proc/bomb_defused(obj/item/plastique/blue/csfare/bomb)
	if(planted_bomb != bomb || !match_in_progress)
		return
	bomb.defused = TRUE
	bomb_status = "Defused"
	to_world("<span class='notice'><b>The bomb has been defused!</b></span>")
	finish_match(RED_TEAM, "the bomb was defused")

/datum/game_mode/csfare/proc/count_alive(list/roster)
	var/alive = 0
	for(var/client/player_client in roster)
		var/mob/living/carbon/human/player = get_roster_body(player_client)
		if(player && player.stat != DEAD)
			alive++
	return alive

/datum/game_mode/csfare/proc/get_roster_body(client/player_client)
	if(!player_client || !player_client.mob)
		return null
	if(istype(player_client.mob, /mob/living/carbon/human))
		return player_client.mob
	if(istype(player_client.mob, /mob/observer/ghost))
		var/mob/observer/ghost/ghost = player_client.mob
		if(ghost.mind && istype(ghost.mind.current, /mob/living/carbon/human))
			return ghost.mind.current
	return null

/datum/game_mode/csfare/proc/get_team_spawn_turf(faction)
	var/list/spawn_turfs = faction == RED_TEAM ? red_spawn_turfs : blue_spawn_turfs
	if(spawn_turfs.len)
		return pick(spawn_turfs)
	return null

/datum/game_mode/csfare/proc/reset_roster(list/roster, faction, restore_eliminated_players = TRUE)
	var/datum/team/team_datum = faction == RED_TEAM ? SSwarfare.red : SSwarfare.blue
	for(var/client/player_client in roster)
		var/mob/living/carbon/human/player = get_roster_body(player_client)
		if(!player)
			continue
		if(player.stat == DEAD)
			if(!restore_eliminated_players)
				continue
			player.revive()
		else
			player.rejuvenate()
		var/turf/team_spawn = get_team_spawn_turf(faction)
		if(team_spawn)
			player.forceMove(team_spawn)
		player.warfare_faction = faction
		team_datum.team |= player
		if(player_client.mob != player)
			player.key = player_client.key

/datum/game_mode/csfare/proc/clear_unanchored_floor_objects()
	for(var/obj/object in world)
		if(object != map_bomb && !object.anchored && isturf(object.loc))
			qdel(object)

/datum/game_mode/csfare/proc/is_loaded_map_object(atom/object)
	var/turf/object_turf = get_turf(object)
	if(!object_turf)
		return FALSE
	if(selected_map_min_z)
		return object_turf.z >= selected_map_min_z && object_turf.z <= selected_map_max_z
	return !red_spawn_turf || object_turf.z == red_spawn_turf.z

/datum/game_mode/csfare/proc/get_observer_spawn_turf()
	for(var/obj/structure/objective/b/site_b in world)
		if(is_loaded_map_object(site_b))
			return get_turf(site_b)
	return null

/datum/game_mode/csfare/proc/validate_map_objects()
	var/site_a_found = FALSE
	var/site_b_found = FALSE
	var/red_machine_found = FALSE
	var/blue_machine_found = FALSE
	var/red_pad_found = FALSE
	var/blue_pad_found = FALSE
	var/preparation_grille_count = 0
	var/map_bomb_count = 0

	for(var/obj/structure/objective/a/site_a in world)
		if(is_loaded_map_object(site_a))
			site_a_found = TRUE
			break
	for(var/obj/structure/objective/b/site_b in world)
		if(is_loaded_map_object(site_b))
			site_b_found = TRUE
			break
	for(var/obj/machinery/kaos/cargo_machine/csfare/red/machine in world)
		if(is_loaded_map_object(machine))
			red_machine_found = TRUE
			break
	for(var/obj/machinery/kaos/cargo_machine/csfare/blue/machine in world)
		if(is_loaded_map_object(machine))
			blue_machine_found = TRUE
			break
	for(var/obj/structure/cargo_pad/csfare/red/pad in world)
		if(is_loaded_map_object(pad))
			red_pad_found = TRUE
			break
	for(var/obj/structure/cargo_pad/csfare/blue/pad in world)
		if(is_loaded_map_object(pad))
			blue_pad_found = TRUE
			break
	for(var/obj/structure/grille/sewer/csfare/grille in world)
		if(is_loaded_map_object(grille))
			preparation_grille_count++
	for(var/obj/item/plastique/blue/csfare/bomb in world)
		if(is_loaded_map_object(bomb))
			map_bomb_count++
			if(!map_bomb)
				map_bomb = bomb
				map_bomb_start_turf = get_turf(bomb)

	if(!site_a_found || !site_b_found || !red_machine_found || !blue_machine_found || !red_pad_found || !blue_pad_found || preparation_grille_count < 2 || map_bomb_count != 1)
		log_error("The CSFare map must include Bomb Sites A and B, both teams' CSFare cargo machines and pads, two preparation grilles, and exactly one CSFare bomb.")
		return FALSE
	return TRUE

/datum/game_mode/csfare/proc/set_preparation_grilles(enabled)
	for(var/obj/structure/grille/sewer/csfare/grille in world)
		if(is_loaded_map_object(grille))
			grille.set_preparation_active(enabled)

/datum/game_mode/csfare/proc/update_huds()
	var/time_left = 0
	var/phase_text = "Match complete"
	if(preparing)
		time_left = max(0, round((preparation_end_time - world.time + 9) / 10))
		phase_text = "Preparation"
	else if(match_in_progress && planted_bomb)
		time_left = max(0, round((planted_bomb.detonation_time - world.time + 9) / 10))
		phase_text = "Bomb"
	else if(match_in_progress)
		time_left = max(0, round((match_end_time - world.time + 9) / 10))
		phase_text = "Match"

	var/minutes_left = (time_left - (time_left % 60)) / 60
	var/time_text = "[add_zero(minutes_left, 2)]:[add_zero(time_left % 60, 2)]"
	var/score_text = "Red [round_wins[RED_TEAM]] - [round_wins[BLUE_TEAM]] Blue"
	var/player_text = "Red [count_alive(red_roster)]/[red_roster.len]: [format_roster(red_roster)]<br>Blue [count_alive(blue_roster)]/[blue_roster.len]: [format_roster(blue_roster)]"
	var/status_text = "Bomb: [bomb_status]"
	for(var/client/player_client in GLOB.clients)
		if(!player_client.csfare_hud)
			player_client.csfare_hud = new
		player_client.screen |= player_client.csfare_hud
		player_client.csfare_hud.maptext = "<div align='center'><b>CSFare [current_match]/[CSFARE_MATCHES_PER_ROUND] &nbsp; [phase_text] [time_text] &nbsp; [score_text] &nbsp; [status_text]<br>[player_text]</b></div>"

/datum/game_mode/csfare/proc/format_roster(list/roster)
	var/list/player_statuses = list()
	for(var/client/player_client in roster)
		var/mob/living/carbon/human/player = get_roster_body(player_client)
		var/player_name = player ? player.real_name : player_client.key
		if(!player_name)
			player_name = "Unknown"
		var/player_status = !player ? "Disconnected" : player.stat == DEAD ? "Dead" : "Alive"
		player_statuses += "[html_encode(player_name)] ([player_status])"
	return jointext(player_statuses, ", ")

/obj/structure/objective
	name = "bomb site"
	desc = "Burn it all down to the ground."
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_pad"
	anchored = TRUE
	density = FALSE

/obj/structure/objective/a
	name = "Bomb Site A"

/obj/structure/objective/b
	name = "Bomb Site B"

/obj/structure/grille/sewer/csfare
	name = "temporary CSFare preparation grille"

/obj/structure/grille/sewer/csfare/proc/set_preparation_active(active)
	if(active)
		destroyed = FALSE
		health = initial(health)
		set_density(initial(density))
		invisibility = initial(invisibility)
	else
		set_density(FALSE)
		invisibility = 101
	update_icon()

/obj/item/plastique/blue/csfare
	name = "CSFare bomb"
	desc = "Drop bomb men"
	timer = 40
	var/detonation_time
	var/defused = FALSE
	var/mob/defuser

/obj/item/plastique/blue/csfare/afterattack(atom/movable/target, mob/user, flag)
	if(!flag)
		return
	if(!istype(target, /obj/structure/objective/a) && !istype(target, /obj/structure/objective/b))
		to_chat(user, "<span class='warning'>The bomb can only be planted at site A or B.</span>")
		return
	if(!ticker || !istype(ticker.mode, /datum/game_mode/csfare) || user.warfare_faction != BLUE_TEAM)
		to_chat(user, "<span class='warning'>Only a Blue soldier can plant this bomb. Are you trying to sabotage Redistan?</span>")
		return
	var/datum/game_mode/csfare/mode = ticker.mode
	if(!mode.match_in_progress || world.time >= mode.match_end_time || mode.planted_bomb)
		to_chat(user, "<span class='warning'>The bomb cannot be planted anymore.</span>")
		return
	if(user.get_active_hand() != src || !do_after(user, 50, target))
		return
	if(!mode.match_in_progress || world.time >= mode.match_end_time || !in_range(user, target) || mode.planted_bomb)
		return

	var/obj/structure/objective/site = target
	user.drop_item()
	forceMove(site)
	src.target = site
	timer = 40
	detonation_time = world.time + CSFARE_BOMB_TIME
	site.overlays += image_overlay
	if(!mode.register_bomb(src))
		mode.return_map_bomb()
		return
	spawn(CSFARE_BOMB_TIME - (10 SECONDS))
		if(!QDELETED(src) && detonation_time && !defused && ticker && istype(ticker.mode, /datum/game_mode/csfare))
			var/datum/game_mode/csfare/current_mode = ticker.mode
			if(current_mode.planted_bomb == src)
				to_world("<span class='danger'><b>The bomb has 10 seconds remaining!</b></span>")

/obj/item/plastique/blue/csfare/proc/reset_for_match()
	if(target && !QDELETED(target))
		target.overlays -= image_overlay
	target = null
	timer = 40
	detonation_time = 0
	defused = FALSE
	defuser = null

/obj/item/plastique/blue/csfare/attack_hand(mob/user)
	if(detonation_time)
		return begin_defuse(user, FALSE)
	return ..()

/obj/item/plastique/blue/csfare/attackby(obj/item/item, mob/user)
	if(detonation_time && isWirecutter(item))
		return begin_defuse(user, TRUE)
	..()

/obj/item/plastique/blue/csfare/attack_self(mob/user)
	if(detonation_time)
		to_chat(user, "<span class='notice'>The bomb's fuse cannot be changed after planting.</span>")
		return
	..()

/obj/item/plastique/blue/csfare/proc/begin_defuse(mob/user, use_wirecutters)
	if(defused || !ticker || !istype(ticker.mode, /datum/game_mode/csfare) || !detonation_time)
		return FALSE
	if(user.warfare_faction != RED_TEAM)
		to_chat(user, "<span class='warning'>Only a Red soldier can defuse the bomb. Are you trying to sabotage Blusnia?</span>")
		return FALSE
	if(!in_range(user, src))
		to_chat(user, "<span class='warning'>You need to get closer to defuse the bomb!</span>")
		return FALSE
	if(defuser)
		to_chat(user, "<span class='warning'>The bomb is already being defused!</span>")
		return FALSE

	defuser = user
	var/required_time = use_wirecutters ? 5 SECONDS : 10 SECONDS
	var/end_time = world.time + required_time
	var/initial_brute = ishuman(user) ? user:getBruteLoss() : 0
	var/initial_burn = ishuman(user) ? user:getFireLoss() : 0
	var/initial_tox = ishuman(user) ? user:getToxLoss() : 0
	var/initial_oxy = ishuman(user) ? user:getOxyLoss() : 0
	var/datum/progressbar/progress = new(user, required_time, src)

	while(world.time < end_time)
		sleep(1)
		if(QDELETED(src) || defuser != user || !user || get_dist(user, src) > 1 || user.incapacitated())
			break
		if(ishuman(user) && (user:getBruteLoss() > initial_brute || user:getFireLoss() > initial_burn || user:getToxLoss() > initial_tox || user:getOxyLoss() > initial_oxy))
			to_chat(user, "<span class='warning'>You flinch!</span>")
			break
		progress.update(world.time - (end_time - required_time))

	qdel(progress)
	var/defuse_complete = !QDELETED(src) && user && defuser == user && world.time >= end_time && get_dist(user, src) <= 1
	defuser = null
	if(defuse_complete)
		var/datum/game_mode/csfare/mode = ticker.mode
		mode.bomb_defused(src)
		return TRUE
	return FALSE

/obj/item/plastique/blue/csfare/proc/detonate()
	if(defused || !ticker || !istype(ticker.mode, /datum/game_mode/csfare))
		return
	var/datum/game_mode/csfare/mode = ticker.mode
	var/turf/bomb_turf = get_turf(src)
	to_world("<span class='danger'><b>The bomb has detonated!</b></span>")
	if(target)
		target.overlays -= image_overlay
	mode.finish_match(BLUE_TEAM, "the bomb detonated")
	if(bomb_turf)
		explosion(bomb_turf, -1, -1, 2, 3, particles = TRUE, autosize = TRUE)

/obj/item/plastique/blue/csfare/ex_act(severity)
	return

/obj/item/plastique/blue/csfare/Destroy()
	if(target && !QDELETED(target))
		target.overlays -= image_overlay
	if(ticker && istype(ticker.mode, /datum/game_mode/csfare))
		var/datum/game_mode/csfare/mode = ticker.mode
		if(mode.planted_bomb == src)
			mode.planted_bomb = null
	return ..()

/obj/screen/csfare_hud
	icon = null
	mouse_opacity = FALSE
	screen_loc = "NORTH,CENTER"
	plane = HUD_PLANE
	layer = HUD_ABOVE_ITEM_LAYER
	maptext_width = 1200
	maptext_height = 70
	maptext_x = -600
	maptext_y = -40

/client
	var/obj/screen/csfare_hud/csfare_hud

/obj/machinery/kaos/cargo_machine/csfare
	var/list/csfare_product_price_overrides = list(
		/decl/cargo_product/crate/boltaction_pack = 15,
		/decl/cargo_product/crate/shotgun_pack = 15,
		/decl/cargo_product/crate/pistol_pack = 10,
		/decl/cargo_product/crate/warmonger_pack = 20,
		/decl/cargo_product/crate/rifle_ammo = 5,
		/decl/cargo_product/crate/shotgun_ammo = 5,
		/decl/cargo_product/crate/pistol_ammo = 5,
		/decl/cargo_product/crate/warmonger_ammo = 5,
		/decl/cargo_product/crate/firstaid_pack = 10,
		/decl/cargo_product/csfare/cs_redhelmet = 5,
		/decl/cargo_product/csfare/cs_redarmor = 15,
		/decl/cargo_product/csfare/cs_bluehelmet = 5,
		/decl/cargo_product/csfare/cs_bluearmor = 15
	)
	var/list/csfare_product_contents_overrides = list(
		/decl/cargo_product/crate/boltaction_pack = list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 1),
		/decl/cargo_product/crate/shotgun_pack = list(/obj/item/gun/projectile/shotgun/pump/shitty = 1),
		/decl/cargo_product/crate/pistol_pack = list(/obj/item/gun/projectile/golt = 1, /obj/item/gun/projectile/warfare = 1),
		/decl/cargo_product/crate/warmonger_pack = list(/obj/item/gun/projectile/automatic/m22/warmonger = 1)
		/decl/cargo_product/crate/rifle_ammo = list(/obj/item/ammo_box/rifle = 3),
		/decl/cargo_product/crate/shotgun_ammo = list(/obj/item/ammo_box/shotgun = 3),
		/decl/cargo_product/crate/pistol_ammo = list(/obj/item/ammo_magazine/c45m/warfare = 3, /obj/item/ammo_magazine/a50 = 3),
		/decl/cargo_product/crate/warmonger_ammo = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 3)
		/decl/cargo_product/crate/firstaid_pack = list(/obj/item/storage/firstaid/regular = 3)
	)

	proc/get_csfare_available_products()
		var/list/allowed_types = list(
			/decl/cargo_product/crate/boltaction_pack,
			/decl/cargo_product/crate/shotgun_pack,
			/decl/cargo_product/crate/pistol_pack,
			/decl/cargo_product/crate/warmonger_pack,
			/decl/cargo_product/crate/rifle_ammo,
			/decl/cargo_product/crate/shotgun_ammo,
			/decl/cargo_product/crate/pistol_ammo,
			/decl/cargo_product/crate/warmonger_ammo,
			/decl/cargo_product/crate/firstaid_pack
		)
		if(id == RED_TEAM)
			allowed_types += list(
				/decl/cargo_product/csfare/cs_redhelmet,
				/decl/cargo_product/csfare/cs_redarmor
			)
		else if(id == BLUE_TEAM)
			allowed_types += list(
				/decl/cargo_product/csfare/cs_bluehelmet,
				/decl/cargo_product/csfare/cs_bluearmor
			)

		var/list/available = list()
		for(var/product_type in allowed_types)
			var/decl/cargo_product/product = decls_repository.get_decl(product_type)
			if(product && (!product.faction_id || product.faction_id == id))
				available |= product
		return available

	proc/get_csfare_product_price_override(decl/cargo_product/product)
		var/override_price = csfare_product_price_overrides[product.type]
		return isnull(override_price) ? product.price : override_price

	proc/get_csfare_product_contents_override(decl/cargo_product/product)
		var/list/override_contents = csfare_product_contents_overrides[product.type]
		return isnull(override_contents) ? product.contents : override_contents

	proc/is_csfare_product(decl/cargo_product/product)
		return product in get_csfare_available_products()

/obj/machinery/kaos/cargo_machine/csfare/red
	name = "CSFare Red Cargo Machine"
	id = RED_TEAM

/obj/machinery/kaos/cargo_machine/csfare/blue
	name = "CSFare Blue Cargo Machine"
	id = BLUE_TEAM

/obj/structure/cargo_pad/csfare/red
	name = "CSFare Red Cargo Pad"
	id = RED_TEAM

/obj/structure/cargo_pad/csfare/blue
	name = "CSFare Blue Cargo Pad"
	id = BLUE_TEAM

/proc/iscfare()
	return (ticker && istype(ticker.mode, /datum/game_mode/csfare)) || master_mode == "csfare"

#undef CSFARE_MAX_TEAM_SIZE
#undef CSFARE_MATCHES_PER_ROUND
#undef CSFARE_PREPARATION_TIME
#undef CSFARE_MATCH_TIME
#undef CSFARE_BOMB_TIME
#undef CSFARE_RETURN_TO_LOBBY
