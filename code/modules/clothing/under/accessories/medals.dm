//Medals!

/obj/item/clothing/accessory/medal
	name = ACCESSORY_SLOT_MEDAL
	desc = "A simple medal."
	icon_state = "bronze"
	slot = ACCESSORY_SLOT_MEDAL

/obj/item/clothing/accessory/medal/iron
	name = "iron medal"
	desc = "A simple iron medal."
	icon_state = "iron"
	item_state = "iron"

/obj/item/clothing/accessory/medal/bronze
	name = "bronze medal"
	desc = "A simple bronze medal."
	icon_state = "bronze"
	item_state = "bronze"

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A simple silver medal."
	icon_state = "silver"
	item_state = "silver"

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A simple gold medal."
	icon_state = "gold"
	item_state = "gold"

//NT medals

/obj/item/clothing/accessory/medal/gold/nanotrasen
	name = "\improper NanoTrasen command medal"
	desc = "A gold medal awarded to NanoTrasen employees for service as the Captain of a NanoTrasen facility, station, or vessel."
	icon_state = "gold_nt"

/obj/item/clothing/accessory/medal/silver/nanotrasen
	name = "\improper NanoTrasen service medal"
	desc = "A silver medal awarded to NanoTrasen employees for distinguished service in support of corporate interests."
	icon_state = "silver_nt"

/obj/item/clothing/accessory/medal/bronze/nanotrasen
	name = "\improper NanoTrasen sciences medal"
	desc = "A bronze medal awarded to NanoTrasen employees for signifigant contributions to the fields of science or engineering."
	icon_state = "bronze_nt"

/obj/item/clothing/accessory/medal/iron/nanotrasen
	name = "\improper NanoTrasen merit medal"
	desc = "An iron medal awarded to NanoTrasen employees for merit."
	icon_state = "iron_nt"

//WARMEDALS

/obj/item/clothing/accessory/medal/red
	name = "Red medal"
	desc = "A medal given to those who served in combat well!"
	icon_state = "bronze"
	item_state = "bronze"
	warfare_team = RED_TEAM

/obj/item/clothing/accessory/medal/blue
	name = "Blue medal"
	desc = "A medal given to those who served in combat well!"
	icon_state = "iron"
	item_state = "iron"
	warfare_team = BLUE_TEAM

//WARMEDALS PROCS//

//MORALE BUFF/DEBUFF!!!
/obj/item/clothing/accessory/medal/on_attached(var/obj/item/clothing/S, var/mob/user)
	..()
	// Give happiness buff to the wearer
	if(S.loc && ishuman(S.loc))
		var/mob/living/carbon/human/H = S.loc
		H.clear_event("Awarded")
		H.add_event("Awarded", /datum/happiness_event/awarded)

/obj/item/clothing/accessory/medal/on_removed(var/mob/user)
	// Get the wearer BEFORE calling parent (which nulls has_suit)
	var/mob/living/carbon/human/H = null
	if(has_suit && ishuman(has_suit.loc))
		H = has_suit.loc

	..() // Now call parent

	// Combined check: both wearer and remover must be human
	if(H && ishuman(user))
		var/mob/living/carbon/human/remover = user

		// Check if remover is captain and on same team
		var/is_red_captain = remover.HasRoleSimpleCheck("Red Captain")
		var/is_blue_captain = remover.HasRoleSimpleCheck("Blue Captain")

		// Make sure both have warfare_faction set and captain is on same team
		if(H.warfare_faction && remover.warfare_faction)
			if((is_red_captain || is_blue_captain) && H.warfare_faction == remover.warfare_faction)
				// Clear positive buff and apply negative one
				H.clear_event("Awarded")
				H.add_event("Demoted", /datum/happiness_event/demoted)

				// Remove from medal tracking
				GLOB.medals_awarded -= H.real_name
				to_chat(remover, SPAN_WARNING("You have revoked [H.real_name]'s medal. Serves them right."))
				to_chat(H, SPAN_DANGER("Your medal has been revoked by [remover.real_name]!"))

//MAIN CHECKS!!
/obj/item/clothing/accessory/medal/proc/can_be_awarded_by(var/mob/living/carbon/human/awarder, var/mob/living/carbon/human/recipient)
	//Determine Kapittan's team
	var/captain_team = null
	if(awarder.HasRoleSimpleCheck("Red Captain"))
		captain_team = RED_TEAM
	else if(awarder.HasRoleSimpleCheck("Blue Captain"))
		captain_team = BLUE_TEAM
	else //Your rank is not high enough soldier!
		to_chat(awarder, SPAN_WARNING("My rank is not high enough to bestow such honours...</i></b>"))
		return FALSE

	//Check medal team matches captain team
	if(warfare_team != captain_team)
		to_chat(awarder, SPAN_MINDVOICE("THIS IS BORDERLINE TREASON! THE COMMAND HAS BEEN NOTIFIED!"))
		log_and_message_admins("attempted to award a [warfare_team] medal while being on [captain_team] team.", awarder)
		return FALSE

	//Check recipient is on same team
	if(awarder.warfare_faction != recipient.warfare_faction)
		to_chat(awarder, SPAN_MINDVOICE("THIS IS BORDERLINE TREASON! THE COMMAND HAS BEEN NOTIFIED!"))
		log_and_message_admins("attempted to award a [warfare_team] medal to [key_name(recipient)] who is on the enemy team.", awarder)
		return FALSE

	//Self-awarding check
	if(awarder == recipient)
		//You can't award yourself Kapittan!
		if(!awarder.mind || !awarder.mind.backstory)
			to_chat(awarder, SPAN_WARNING("You cannot award medals to yourself!</i></b>"))
			return FALSE

		//Unless you are corrupt :)
		if(!istype(awarder.mind.backstory, /datum/backstory/nepotismcaptain))
			to_chat(awarder, SPAN_WARNING("You cannot award medals to yourself!</i></b>"))
			return FALSE

		return TRUE

	return TRUE

//MEDAL TRAKKER
/obj/item/clothing/accessory/medal/proc/try_award_medal(var/mob/living/carbon/human/awarder, var/mob/living/carbon/human/recipient)
	if(!can_be_awarded_by(awarder, recipient))
		return FALSE

	//Check if already awarded (unless nepotism self-praise and glory)
	if(recipient.real_name in GLOB.medals_awarded)
		var/is_nepotism_self_award = (awarder == recipient && awarder.mind?.backstory?.type == /datum/backstory/nepotismcaptain)
		if(!is_nepotism_self_award)
			to_chat(awarder, SPAN_WARNING("[recipient.real_name] has already been awarded a medal during this battle!"))
			return FALSE

		//OUR DECORATED NOT SO HEROIC NEPO CAPTAIN!
		var/list/existing = GLOB.medals_awarded[recipient.real_name]
		if(!islist(existing[1]))
			existing = list(existing)
		existing += list(list(
			"name" = recipient.real_name,
			"awarded_by" = awarder.real_name,
			"team" = warfare_team,
			"medal_name" = name
		))
		GLOB.medals_awarded[recipient.real_name] = existing
	else
		//OUR DECORATED WAR HEROES! (Roundend Tracker)
		GLOB.medals_awarded[recipient.real_name] = list(
			"name" = recipient.real_name,
			"awarded_by" = awarder.real_name,
			"team" = warfare_team,
			"medal_name" = name,
			"posthumous" = (recipient.stat == DEAD)
		)

	return TRUE