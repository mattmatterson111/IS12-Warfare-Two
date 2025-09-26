/datum/squadmember
	var/name_override = "%FIRST %LAST %RAND%RAND" // %RAND is a random number, %FIRST %LAST are first and last names
	var/force_gender = MALE // Either MALE, FEMALE or NULL

	var/decl/hierarchy/outfit/outfit = null

	var/spawn_inside_of = /obj/structure/soldiercryo

	var/closet_type = /obj/structure/closet/secure_closet/warfare/newver

	var/mob_type = /mob/living/carbon/human/objective // Only human/objective subtypes pls

	var/ghost_message = "<h1><span class='phobia'>WAKE UP, SOLDIER OF %SQUAD SQUAD!"

	var/datum/ert_squad/squad = null

	var/spawn_sound = 'sound/effects/ert/soldier_spawnin.ogg'

	/// ID stuff
	var/rank
	var/assignment

/datum/squadmember/New(var/squad)
	. = ..()
	src.squad = squad
	outfit = outfit_by_type(outfit)

/datum/squadmember/proc/spawn_mob(var/turf/T, var/list/locker_spawns, var/leader = FALSE, var/client/C)
	var/mob/living/carbon/human/H = new mob_type(T)
	squad.members += H
	post_spawn(H, locker_spawns)
	if(ghost_message && !leader)
		var/datum/ghosttrap/G = get_ghost_trap("soldier")
		var/ghost_message_post = replacetext(ghost_message, "%SQUAD", squad.name)
		G.request_player(H, ghost_message_post, 30 SECONDS)
	if(C)
		H.ckey = C.ckey
		H.client = C
	return H

/datum/squadmember/proc/introduce_player(mob/living/carbon/human/objective/H)
	if(H.client) // gotta make sure
		if(spawn_sound)
			sound_to(H.client, sound(spawn_sound))
			sleep(15)
		var/list/dat = "<Font size=1>YOU ARE [uppertext(H.real_name)].\n"
		dat += "YOU SERVE YOUR BENEFACTOR.\n"
		dat += "YOU OBEY YOUR SQUAD LEADER.\n"
		dat += "YOU COOPERATE WITH YOUR SQUAD.</font>\n\n"
		dat += "<font size=2>AWAIT FURTHER INSTRUCTIONS.</font>"
		H.play_screen_text(jointext(dat,null), alert = /atom/movable/screen/text/screen_text/screen)


/datum/squadmember/proc/post_spawn(mob/living/carbon/human/objective/H, var/list/locker_spawns)
	H.squad = squad

	if(force_gender)
		H.gender = force_gender
	else
		H.change_gender(pick(MALE,FEMALE))
	if(name_override)
		var/name = replacetext(name_override, "%RAND", rand(1,9))
		if(H.get_gender() == MALE)
			name = replacetext(name, "%FIRST", pick(GLOB.first_names_male))
		else
			name = replacetext(name, "%FIRST", pick(GLOB.first_names_female))
		name = replacetext(name, "%LAST", pick(GLOB.last_names))
		H.real_name = name
		H.name = name
	H.warfare_faction = squad.warfare_faction
	var/use_closet = FALSE
	var/obj/this_spawn = null
	if(closet_type)
		for(var/obj/O in locker_spawns)
			var/turf/T = get_turf(H)
			if(!T.AdjacentQuick(O.loc))
				continue
			this_spawn = O
			for(var/obj/a in T.contents)
				if(istype(a, /obj/structure/closet)) // shitty.
					this_spawn = null
					break
	if(this_spawn)
		use_closet = TRUE
	if(outfit && !use_closet)
		outfit.equip(H)
	if(use_closet)
		var/obj/structure/closet/C = new closet_type(this_spawn.loc)
		outfit.spawn_into(C, H)
		C.anchored = TRUE

	if(spawn_inside_of)
		var/obj/structure/soldiercryo/cryo = new spawn_inside_of(H.loc)
		cryo.move_inside(H, force = TRUE)

	H.member = src

/datum/ert_squad
	var/name = "REDACTED"
	var/benefactor = "REDACTED"
	var/warfare_faction = ""

	var/datum/squadmember/basic_template = null
	var/datum/squadmember/leader_template = null
	var/datum/squadmember/admin_leader_template = null

	var/list/members = list()

	var/map = "Test ERT"
	var/datum/map_template/ruin/ert/loaded_map = null // just so we can reference it post-spawn.

	var/mob/living/carbon/human/objective/SL = null /// Squad leader

	var/directive = null
	var/new_objective_sound = null
	var/new_objective_text = "<span class='phobia'>OBEY YOUR BENEFACTOR\n>> %DIRECTIVE <</span>"
	var/objective_type = /atom/movable/screen/text/screen_text/screen
	var/new_objective_text_screen = "<font color='white' size='3'>** COMMAND MESSAGE **</font>\n<font color='#cfcfcf' size=1>%DIRECTIVE</font>"

/datum/ert_squad/New()
	. = ..()
	basic_template = new basic_template(src)

	leader_template = new leader_template(src)

	admin_leader_template = new admin_leader_template(src)

/datum/ert_squad/proc/spawn_squad(var/list/spawnpoints, var/list/locker_spawns, amount)
	var/spawned = 0
	for(var/obj/A in spawnpoints)
		if(istype(A, /obj/effect/landmark/squad/leader))
			continue
		if(spawned >= length(spawnpoints))
			break
		if(spawned >= amount)
			break
		basic_template.spawn_mob(get_turf(A), locker_spawns)
		spawned++

/datum/ert_squad/proc/set_directive(directive, visible_text)
	src.directive = directive

	var/text = replacetext(new_objective_text, "%DIRECTIVE", directive)

	var/objtext = replacetext(new_objective_text_screen, "%DIRECTIVE", visible_text ? visible_text : uppertext(directive))

	for(var/mob/living/carbon/human/objective/O in members)
		to_chat(O, text)
		if(!O.client)
			continue
		O.play_screen_text(objtext, alert = objective_type)

// It's seperate procs incase a subtype overrides it //

/datum/ert_squad/proc/spawn_leader(var/client/C)
	var/turf/T = null
	for(var/obj/effect/landmark/squad/leader/A in shuffle(loaded_map.spawnpoints))
		T = A.loc
		break

	var/mob/M = leader_template.spawn_mob(T, loaded_map.locker_spawns, TRUE, C)
	SL = M
	return SL

/datum/ert_squad/proc/spawn_adminleader(var/client/C)
	var/turf/T = get_turf(C.mob)

	admin_leader_template.spawn_mob(T, loaded_map.locker_spawns, TRUE, C)

// // // // // // // // // // // // // // // // // // // // // // // // //

/datum/squadmember/debug
	outfit = /decl/hierarchy/outfit/soldier/leader

/datum/squadmember/debug/post_spawn(mob/living/carbon/human/objective/H)
	. = ..()
	H.add_stats(rand(12,17), rand(10,16), rand(8,14), rand(10, 18))
	H.warfare_language_shit(squad.warfare_faction)
	H.set_hud_stats()
	H.SKILL_LEVEL(medical) = 15
	H.SKILL_LEVEL(surgery) = 15
	H.SKILL_LEVEL(ranged) = 15
	H.SKILL_LEVEL(engineering) = 15
	H.SKILL_LEVEL(melee) = 15
	//Gun skills
	H.SKILL_LEVEL(auto_rifle) = 15
	H.SKILL_LEVEL(semi_rifle) = 15
	H.SKILL_LEVEL(sniper) = 15
	H.SKILL_LEVEL(shotgun) = 15
	H.SKILL_LEVEL(lmg) = 15
	H.SKILL_LEVEL(smg) = 15
	H.SKILL_LEVEL(boltie) = 15

/datum/squadmember/basic
	outfit = /decl/hierarchy/outfit/soldier

/datum/squadmember/basic/spawn_mob(turf/T)
	. = ..()

/datum/squadmember/basic/post_spawn(mob/living/carbon/human/objective/H)
	. = ..()
	H.add_stats(rand(12,17), rand(10,16), rand(8,12))
	H.warfare_language_shit(LANGUAGE_RED)
	H.set_hud_stats()

/datum/ert_squad/red
	warfare_faction = RED_TEAM
	basic_template = /datum/squadmember/basic
	leader_template = /datum/squadmember/basic
	admin_leader_template = /datum/squadmember/debug

/datum/ert_squad/blue
	warfare_faction = BLUE_TEAM
	basic_template = /datum/squadmember/basic
	leader_template = /datum/squadmember/basic
	admin_leader_template = /datum/squadmember/debug

/datum/ert_squad/test
	warfare_faction = RED_TEAM
	basic_template = /datum/squadmember/basic
	leader_template = /datum/squadmember/basic
	admin_leader_template = /datum/squadmember/debug

