SUBSYSTEM_DEF(squads)
	name = "SQUAD management"
	init_order = -165
	flags = SS_NO_FIRE
	var/list/squad_templates = list()
	var/list/active_squads = list()
	var/list/used_maps = list()

/datum/controller/subsystem/squads/Initialize()
	. = ..()
	populate_templates()

/datum/controller/subsystem/squads/proc/populate_templates()
	for(var/type in subtypesof(/datum/ert_squad))
		var/datum/ert_squad/squad = new type()
		squad_templates[squad.name] += squad

/client/proc/spawn_squad()
	set category = "roleplay"
	set name = "Spawn SQUAD"
	set desc = "Spawns a SQUAD using a selected template."

	if(!holder)
		return
	if(!length(SSsquads.squad_templates))
		return
	var/key = input("Select a template", "SQUAD SPAWN") as anything in subtypesof(/datum/ert_squad)+"CANCEL"
	if(key == "CANCEL")
		return
	var/designation = input("What should it be designated as?") as text
	if(SSsquads.active_squads[designation])
		to_chat(src, "Let's try not to have repeating squad names, shall we?")
		return
	if(!designation)
		return // don't bother.
	var/datum/ert_squad/team = new key()
	team.name = designation
	for(var/type in SSsquads.used_maps)
		if(istype(type,SSmapping.map_templates[team.map]))
			to_chat(src, "A squad with this map is already loaded.")
			return
	var/datum/map_template/ruin/ert/template = SSmapping.map_templates[team.map]
	team.loaded_map = template
	SSsquads.used_maps |= template
	var/new_z_centre = template.load_new_z()
	if (new_z_centre)
		log_and_message_admins("has placed a map template ([template.name]) on a new zlevel.", location=new_z_centre)
	else
		to_chat(src, "Failed to place map")
		return
	var/amount = input("How many blanks should be spawned?", "Squad member body initiative") as num
	if(amount == 0 || amount > length(template.spawnpoints-/obj/effect/landmark/squad/leader))
		amount = length(template.spawnpoints-/obj/effect/landmark/squad/leader)
	team.spawn_squad(template.spawnpoints, template.locker_spawns, amount)
	SSsquads.active_squads[designation] = team
	message_admins("[ckey] created a new team designated as [designation] with [amount] members.")

/client/proc/change_squad_directive()
	set category = "roleplay"
	set name = "Change SQUAD directive"
	set desc = "Changed a SQUAD's directive."

	if(!holder)
		return

	if(!length(SSsquads.active_squads))
		to_chat(src, "There are no active squads.")
		return
	var/key = input("Select an active squad", "SELECT SELECT") as anything in SSsquads.active_squads+"CANCEL"
	if(key == "CANCEL")
		return
	var/datum/ert_squad/squad = SSsquads.active_squads[key]
	if(!squad)
		return
	var/choice = input("** COMMAND MESSAGE ** // Blank?", "Agh") as anything in list("CUSTOM","TEMPLATE","NONE")
	var/alt_text = null
	var/directive = ""
	if(choice == "CUSTOM")
		directive = input("** COMMAND MESSAGE ** // TEXT") as text
	else if(choice == "TEMPLATE")
		directive = input("Select a template:") as anything in list("NEW DIRECTIVE INBOUND", "ESTABLISH FOB", )
	else
		directive = ""
		alt_text = "AWAIT FURTHER DIRECTIVES"
	if(directive == squad.directive)
		return
	squad.set_directive(directive, alt_text)
	message_admins("[ckey] has changed the objective of [squad.name] squad to: [directive]")

/client/proc/spawn_squadleader()
	set category = "roleplay"
	set name = "Spawn SQUAD Leader"
	set desc = "Spawns a SQUAD Leader using a CKEY."

	if(!holder)
		return

	var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads+"CANCEL"
	if(key == "CANCEL")
		return
	var/datum/ert_squad/squad = SSsquads.active_squads[key]
	if(!squad)
		return

	var/client/C = input(src, "Select a leader", "LEADER SPAWN") as null|anything in GLOB.clients
	if(C)
		if(!isobserver(C.mob))
			return to_chat(usr, "The selected player is not a ghost.")
		message_admins("[C] has been spawned as a squad leader for '[squad.name] squad'.")
		var/mob/M = squad.spawn_leader(C)
		M.verbs += /client/proc/place_squad_waypoint
		M.verbs += /client/proc/clear_squad_waypoint


/client/proc/spawn_adminleader()
	set category = "roleplay"
	set name = "Spawn SQUAD (admin) Leader"
	set desc = "Spawns yourself as an admin SQUAD Leader."

	if(!holder)
		return

	var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads+"CANCEL"
	if(key == "CANCEL")
		return
	var/datum/ert_squad/squad = SSsquads.active_squads[key]
	if(!squad)
		return

	squad.spawn_adminleader(src)
	message_admins("[ckey] has been spawned as an admin squad leader for '[squad.name] squad'.")

/client/proc/place_squad_waypoint() // this got changed to just be proper fully admin only
	set name = "Place Squad Waypoint"
	set category = "roleplay"

	var/datum/ert_squad/squad

	if(holder)
		var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads + "CANCEL"
		if (key == "CANCEL")
			return
		squad = SSsquads.active_squads[key]
	else if (istype(mob, /mob/living/carbon/human/objective))
		var/mob/living/carbon/human/objective/O = mob
		if (!is_squad_leader(O))
			return
		squad = O.squad

	if (!squad)
		return

	var/atom/location = get_step(mob, mob.dir)
	if (!location)
		return

	var/mob/M = locate(/mob/living/carbon) in location.contents
	if (M)
		location = M

	var/message
	if(holder)
		message = sanitize(input("WAYPOINT LABEL", "INFORM THEM") as text | null)
	var/list/points = list("Evac/Exfil", "Clear Area", "Armed Hostiles", "Group Up", "Breach Stack", "Breach Explosives")
	if(holder)
		points += "Priority"
		points += "Terminate"
		points += "Exfil Asset"
		points += "Objective"
	var/callout = input("SELECT THE DESIRED PING") as anything in points
	if (holder && callout == "Terminate" && M)
		if (is_squad_leader(M))
			squad.SL.verbs -= /client/proc/place_squad_waypoint
			squad.SL.verbs -= /client/proc/clear_squad_waypoint
			var/mob/old_SL = squad.SL
			squad.SL = null

			for (var/mob/mob in squad.members)
				if (!mob.client)
					continue
				sound_to(mob.client, sound('sound/effects/ert/evil_announcement.ogg'))
				spawn(5)
					mob.play_screen_text("<font size=1>ATTENTION PLEASE\n\nFIELD DEMOTION CONFIRMED\n<i>[uppertext(old_SL.real_name)]</i> IS NO LONGER IN COMMAND</font>", alert = /atom/movable/screen/text/screen_text/screen)

	create_squad_waypoint(location, squad.members, message, mob, callout = callout)
	to_chat(src, "Placed '[callout]' succesfully")

/client/proc/clear_squad_waypoint()
	set name = "Clear Squad Waypoint"
	set category = "roleplay"

	var/datum/ert_squad/squad

	if (holder)
		var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads + "CANCEL"
		if (key == "CANCEL")
			return
		squad = SSsquads.active_squads[key]
	else if (istype(mob, /mob/living/carbon/human/objective))
		var/mob/living/carbon/human/objective/O = mob
		if (!is_squad_leader(O))
			return
		squad = O.squad

	if (!squad)
		return

	clear_squad_waypoints(squad.members)



/proc/create_squad_waypoint(atom/location, list/mob/receivers, text = "", mob/creator, full_text_override = null, callout = "bait")
	for (var/mob/living/carbon/human/H in receivers)
		if (!H.client)
			continue
		sound_to(H.client, sound('sound/effects/ert/assign_leader_click.ogg'))
		var/who = isobserver(creator) ? "benefactor" : "squad leader"

		to_chat(H, full_text_override ? full_text_override : SPAN_WHITE("Your [who] has created a waypoint, titled: \"<i>[SPAN_YELLOW_LARGE(callout)]</i>\""))
		if (H.waypoint.target)
			H.waypoint.end_tracking(H.waypoint.target)
		H.waypoint.track(location, full_text_override ? full_text_override : text, template = callout)

/proc/clear_squad_waypoints(list/mob/receivers)
	for (var/mob/living/carbon/human/H in receivers)
		if(!H.client)
			continue
		if (!H.waypoint.target)
			continue
		H.waypoint.end_tracking(H.waypoint.target)

/client/proc/promote_to_squadleader()
	set name = "Promote SQUADMEMBER to SL"
	set category = "roleplay"

	if (!holder) // NO.
		return

	var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads+"CANCEL"
	if(key == "CANCEL")
		return
	var/datum/ert_squad/squad = SSsquads.active_squads[key]
	if(!squad)
		return

	if(squad.SL)
		to_chat(src, "The squad already has a Squad Leader, their name is [squad.SL.name]")
		return

	var/mob/H = input("SELECT A PAWN", "LAMB FOR THE SLAUGHTER") as mob in squad.members
	squad.SL = H
	squad.SL.verbs += /client/proc/place_squad_waypoint
	squad.SL.verbs += /client/proc/clear_squad_waypoint

	for(var/mob/M in squad.members)
		if(!M.client)
			continue
		sound_to(M.client, sound('sound/effects/ert/evil_announcement.ogg'))
		spawn(5)
			M.play_screen_text("<font size=1>ATTENTION PLEASE\n\nFIELD PROMOTION CONFIRMED\n<i>[uppertext(squad.SL.real_name)]</i> IS NOW IN COMMAND</font>", alert = /atom/movable/screen/text/screen_text/screen)

/client/proc/demote_squadleader()
	set name = "Demote SL to Squadmember"
	set category = "roleplay"

	if (!holder) // No.
		return

	var/key = input("Select an active squad", "SQUAD SPAWN") as anything in SSsquads.active_squads+"CANCEL"
	if(key == "CANCEL")
		return
	var/datum/ert_squad/squad = SSsquads.active_squads[key]
	if(!squad)
		return

	squad.SL.verbs -= /client/proc/place_squad_waypoint
	squad.SL.verbs -= /client/proc/clear_squad_waypoint
	var/mob/old_SL = squad.SL
	squad.SL = null

	for(var/mob/M in squad.members)
		if(!M.client)
			continue
		sound_to(M.client, sound('sound/effects/ert/evil_announcement.ogg'))
		spawn(5)
			M.play_screen_text("<font size=1>ATTENTION PLEASE\n\nFIELD DEMOTION CONFIRMED\n<i>[uppertext(old_SL.real_name)]</i> IS NO LONGER IN COMMAND</font>", alert = /atom/movable/screen/text/screen_text/screen)

/proc/is_squad_leader(mob/M) // Shitty helper proc dont mind this
	if(!istype(M, /mob/living/carbon/human/objective))
		return FALSE
	if(M.client?.holder)
		return TRUE
	var/mob/living/carbon/human/objective/O = M
	return O.ertsquad?.SL == O