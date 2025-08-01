/atom/movable/screen/text/screen_text/screen
	screen_loc = "LEFT,BOTTOM"
	style_open = "<span class='maptext' style=font-size:20pt;text-align:center valign='top'>"
	fade_in_time = 0.75 SECONDS
	fade_out_delay = 4 SECONDS
	play_delay = 0.5
	maptext_width = 480
	maptext_height = 400

/atom/movable/screen/text/screen_text/screen/play_to_client()

	var/client/owner = owner_ref
	if(!owner)
		return

	owner.screen += src

	if(fade_in_time)
		animate(src, alpha = 255)

	var/list/lines_to_skip = list()
	var/static/html_locate_regex = regex("<.*>")
	var/tag_position = findtext(text_to_play, html_locate_regex)
	var/reading_tag = TRUE

	while(tag_position)
		if(reading_tag)
			if(text_to_play[tag_position] == ">")
				reading_tag = FALSE
				lines_to_skip += tag_position
			else
				lines_to_skip += tag_position
			tag_position++
		else
			tag_position = findtext(text_to_play, html_locate_regex, tag_position)
			reading_tag = TRUE

	// tag_position = findtext(text_to_play, "&nbsp;")
	// while(tag_position)
	// 	lines_to_skip.Add(tag_position, tag_position+1, tag_position+2, tag_position+3, tag_position+4, tag_position+5)
	// 	tag_position = tag_position + 6
	// 	tag_position = findtext(text_to_play, "&nbsp;", tag_position)
	for(var/letter = 2 to length(text_to_play) + letters_per_update step letters_per_update)
		if(letter in lines_to_skip)
			continue
		if(!owner)
			continue
		var/char = copytext_char(text_to_play, letter, letter+1)
		maptext = "[style_open][copytext_char(text_to_play, 1, letter)][style_close]"
		if(QDELETED(src))
			return
		if(char == "\n")
			sleep(5) // Miniscule amount of trolling.
		if(char != " " || char != "	")
			sound_to(owner, sound('sound/effects/ui_text_beep1.ogg', volume = 75))
		sleep(play_delay)

	if(auto_end)
		addtimer(CALLBACK(src, .proc/fade_out), fade_out_delay)

/datum/ghosttrap/soldier
	object = "soldier"
	pref_check = BE_PAI
	ghost_trap_message = "They are occupying a soldier now."
	ghost_trap_role = "Soldier"
	can_set_own_name = FALSE
	list_as_special_role = FALSE

/datum/ghosttrap/soldier/welcome_candidate(mob/target)
	if(istype(target, /mob/living/carbon/human/objective))
		var/mob/living/carbon/human/objective/S = target
		S.member.introduce_player(S)
		return

/mob/living/carbon/human/objective
	var/datum/ert_squad/ertsquad = null // I belong to this squad
	var/datum/squadmember/member = null // I belong to this template ughh

/mob/living/carbon/human/objective/ssd_check()
	if(istype(loc, /obj/structure))
		return
	. = ..()

/mob/living/carbon/human/objective/Stat()
	. = ..()
	stat("<b>CURRENT DIRECTIVE:</b>", "<b>[ertsquad.directive ? ertsquad.directive : "STAND BY"]</b>")
/*
/mob/living/carbon/human/objective/ClickOn(var/atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(is_dead())
		return

	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"] && modifiers["middle"])

		if(!is_squad_leader(src)) return . = ..() // Not a squad leader?
		if(doing_something) return . = ..() // Busy?


		var/datum/ert_squad/squad_dat = null

		if(src.squad) // This block is a mess, i'll break it down
			squad_dat = squad

		if(!squad_dat)
			if(!client.holder) // If you don't have a squad, and you're not an admin, return the normal click
				return . = ..()
			var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads + "CANCEL" // If you ARE an admin, get prompted
			if (key == "CANCEL") // Cancel? Sure
				return . = ..()
			squad_dat = SSsquads.active_squads[key] // Grab the squad from the active_squads list using the key name
			if(!squad_dat) return . = ..() // None? somehow? return to prevent issues

		if(!isturf(A))
			if(!ismob(A))
				return . = ..()
		doing_something = TRUE
		var/list/waypoints = list("Evac/Exfil", "Clear Area", "Armed Hostiles", "Group Up", "Breach Stack", "Breach Explosives")
		if(client.holder)
			waypoints += "Priority"
			waypoints += "Terminate"
			waypoints += "Exfil Asset"
			waypoints += "Objective"
		var/callout = input("SELECT THE DESIRED PING") as anything in waypoints

		var/message = null
		if(client.holder)
			message = input("Input the secondary text", ">> (OPTIONAL) <<")

		doing_something = FALSE
		create_squad_waypoint(A, squad_dat.members, message, src, callout = callout)
		return
	. = ..()
*/

/obj/structure/soldiercryo
	icon = 'icons/obj/cryostart.dmi'
	name = "C.S. Unit"

	icon_state = "cryo_loaded"
	var/empty_state = "cryo_used"

	var/mob/occupant = null

	var/exit_sound = 'sound/effects/cryo_exit1.ogg'
	var/enter_sound = 'sound/effects/cryo_enter1.ogg'

	var/allow_reentry = TRUE
	var/locked = FALSE

/obj/structure/soldiercryo/RightClick(mob/user)
	if(CanPhysicallyInteract(user))
		eject()
	else
		..()

/obj/structure/soldiercryo/proc/eject(user, forced)
	if(forced)
		go_out()
		return
	if (usr.stat != 0)
		return
	go_out()
	add_fingerprint(user)
	return

/obj/structure/soldiercryo/RightClick(mob/user)
	if(CanPhysicallyInteract(user))
		user.doing_something = TRUE
		if(do_after(user, 50, src, TRUE, stay_still = TRUE))
			eject(user)
			user.doing_something = FALSE
		else
			user.doing_something = FALSE
	else
		..()

/obj/structure/soldiercryo/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/structure/soldiercryo/proc/move_inside(var/mob/living/carbon/human/user, var/force)

	if (user.stat != 0 && !force)
		return
	if (src.occupant)
		to_chat(user, "<span class='warning'>The scanner is already occupied!</span>")
		return
	user.pulling = null
	if (user.client)
		user.client.perspective = EYE_PERSPECTIVE
		user.client.eye = src
	user.forceMove(src)
	src.occupant = user
	src.icon_state = initial(icon_state)
	/*
	for(var/obj/O in src)
		//O = null
		qdel(O)
		//Foreach goto(124)
	*/
	src.add_fingerprint(user)
	if(istype(user, /mob/living/carbon/human/objective) && !force)
		locked = TRUE
		to_chat(user, "Your mission is complete.\nYou return to stasis.")
		user.ghostize(FALSE)
	// originally I had the entry sound disabled if your entry was forced in by code, but it wasnt as cool..
	playsound(src.loc, enter_sound, 100, 0)
	return

/obj/structure/soldiercryo/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.dropInto(loc)
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.dropInto(loc)
	src.occupant = null
	src.icon_state = empty_state
	playsound(src.loc, exit_sound, 100, 0)
	return

/obj/structure/soldiercryo/attackby(obj/item/grab/normal/G, user as mob)
	if(!istype(G))
		return ..()
	if (!ismob(G.affecting))
		return
	if (src.occupant)
		to_chat(user, "<span class='warning'>The C.S.U. is already occupied!</span>")
		return
	var/mob/M = G.affecting
	move_inside(M, FALSE)
	src.icon_state = initial(icon_state)
	for(var/obj/O in src)
		O.forceMove(loc)
	src.add_fingerprint(user)
	qdel(G)

//Like grap-put, but for mouse-drop.
/obj/structure/soldiercryo/MouseDrop_T(var/mob/target, var/mob/user)
	if(!user || !target)
		return // safeguarding BECAUSE BYOMND IS SHITFUCK!!!
	if(!istype(target))
		return
	if (src.occupant)
		to_chat(user, "<span class='warning'>The scanner is already occupied!</span>")
		return
	if (target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle the subject before attempting to move them.</span>")
		return
	user.visible_message("<span class='notice'>\The [user] begins placing \the [target] into \the [src].</span>", "<span class='notice'>You start placing \the [target] into \the [src].</span>")
	if(!do_after(user, 30, src))
		return
	var/mob/M = target
	move_inside(M, FALSE)
	for(var/obj/O in src)
		O.forceMove(loc)
	src.add_fingerprint(user)
