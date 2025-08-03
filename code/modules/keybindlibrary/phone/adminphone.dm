/obj/structure/phone/rotary/admin
	name = "<span class='phobia'>Base</span> Admin Phone"
	desc = "<span class='phobia'>You Shouldn't be seeing this</span>"
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	phonename = "ADMIN"
	icon_state = "blue"
	base_state = "blue"

/obj/structure/phone/rotary/admin/blue
	name = "Blue Admin Phone"
	desc = "The height of admin technology - A rotary phone!"
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	phonename = "BLUE COMMAND"
	icon_state = "blue"
	base_state = "blue"

/obj/structure/phone/rotary/admin/red
	name = "Red Admin Phone"
	desc = "The height of admin technology - A rotary phone!"
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	phonename = "RED COMMAND"
	icon_state = "red"
	base_state = "red"


/obj/structure/phone/rotary/admin/ring()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(src, sound_id, 'code/modules/keybindlibrary/phone/sound/rotaryphone/phone_ring.ogg', volume = 35, range = 9, falloff = 3, prefer_mute = TRUE, ignore_vis = TRUE)
	audible_message("\icon[src]<span class='warning'>[src.name] begins ringing!</span>")
	ringing = TRUE
	log_and_message_admins("<h3><span class='phobia'>Somebody is calling the [src.name] - use the 'Become Phone Operator' verb in the 'Special Verbs' tab and answer it!</span></h3>", src)

GLOBAL_VAR(operator_target) //hacky way to fetch somebody who decides to be a phone operator

/client/proc/become_phone_operator()
	set name = "Become Phone Operator"
	set category = "Special Verbs"
	set desc = "Become a Phone Operator in the admin phone room"
	if(!holder)
		to_chat(usr, "<span class='danger'>Only administrators may use this command.</span>")
		return
	if(!ticker)
		to_chat(usr, "<span class='danger'>The game hasn't started yet!</span>")
		return
	if(ticker.current_state == 1)
		to_chat(usr, "<span class='danger'>The round hasn't started yet!</span>")
		return

	var/confirm = input(src, "Are you sure you want to become a phone operator? You can hotswap back to your old self after handling the call.", "Ratory Fone") as null|anything in list("Yes", "No")
	if(confirm == "Yes")
		log_and_message_admins("[src] became a phone operator.", src)
		for(var/obj/effect/landmark/start/phoneoperator/spawnpoint in world)
			GLOB.operator_target = src.mob
			var/turf/T = get_turf(spawnpoint)
			new/mob/living/carbon/human/phone_operator(T)
			/*
			phone_guy.attatched_being = src.mob
			to_chat(src,"[phone_guy.attatched_being.name]")
			*/

	else
		return

/mob/living/carbon/human/phone_operator/proc/hotswap_to_old_body()
	set name = "Return To Old Body"
	set category = "PHONE GUY"
	var/mob/deletion_target = src
	attatched_being.ckey = ckey
	qdel(deletion_target)

/mob/living/carbon/human/phone_operator
	var/mob/attatched_being = null //For Hotspswapping

/mob/living/carbon/human/phone_operator/Initialize()
	. = ..()
	attatched_being = GLOB.operator_target
	to_chat(GLOB.operator_target,"[attatched_being]")
	ckey = attatched_being.ckey
	to_chat(usr,"To return to your old body, use the 'Return To Old Body' verb in the 'PHONE GUY' catagory.")
	add_verbs(/mob/living/carbon/human/phone_operator/proc/hotswap_to_old_body)
	GLOB.operator_target = null

/obj/effect/landmark/start/phoneoperator
	name = "Phone operator"

/decl/hierarchy/outfit/phone_operator //Will give them a unique outfit sometime soon - stuff
	uniform = /obj/item/clothing/under/rank/internalaffairs/plain



