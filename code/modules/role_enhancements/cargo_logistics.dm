
/mob/living/carbon/human/proc/view_cargo_points()
	set name = "View Cargo Points"
	set category = "Logistics"
	
	if(mind.assigned_role != "Quartermaster" && mind.assigned_role != "Captain")
		to_chat(src, SPAN_WARNING("You are not authorized to view strategic resource data."))
		return

	var/points = 0
	if(warfare_faction == RED_TEAM)
		points = SSwarfare.red.points
	else if(warfare_faction == BLUE_TEAM)
		points = SSwarfare.blue.points
		
	to_chat(src, SPAN_BNOTICE("Current Team Resource Points: [points]"))

/mob/living/carbon/human/proc/place_cargo_waypoint()
	set name = "Place Cargo Waypoint"
	set category = "Logistics"
	
	if(mind.assigned_role != "Quartermaster")
		return

	var/turf/T = get_turf(src)
	var/datum/waypoint/W = new(T, src, warfare_faction, null, "cargo", "CARGO POINT", 5 MINUTES)
	to_chat(src, SPAN_NOTICE("Cargo delivery point marked at [T.loc.name]."))

/datum/job/qm/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.verbs += /mob/living/carbon/human/proc/view_cargo_points
		H.verbs += /mob/living/carbon/human/proc/place_cargo_waypoint
