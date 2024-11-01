/// Returns distance of two objects in tiles like get_dist but being inside another object doesn't break it and being on a different z-level returns INFINITY
#define GET_DIST(A, B) (get_step(A, 0)?.z == get_step(B, 0)?.z ? max(abs(get_step(A, 0)?.x - get_step(B, 0)?.x), abs(get_step(A, 0)?.y - get_step(B, 0)?.y)) : INFINITY)
/// Returns 0 if A and B are on adjacent turfs, through any amount of nested objs/mobs. Otherwise returns bounds_dist.
#define BOUNDS_DIST(A, B) ((GET_DIST(A, B) <= 1 ? 0 : max(0, bounds_dist(A, B))))
/// Returns if A is in range of B given range
#define IN_RANGE(A, B, range) (GET_DIST(A, B) <= range)**

/obj/item/phone
	name = "base phone item"
	desc = "YOU SHOULD NOT BE ABLE TO SEE THIS."
	icon = 'code/modules/keybindlibrary/phone/icon/telephone.dmi'
	icon_state = "handset_1"
	var/obj/structure/phone/linked_phone
	var/covered

/obj/item/phone/Process()
	if(GET_DIST(linked_phone, src) > 2)
		visible_message("<span class='danger'>The phone cord reaches it limit and the handset is yanked back to its base!</span>")
		if(linked_phone)
			if(linked_phone.oncallwith)
				linked_phone.oncallwith.speakmessage("<span class='phonespeaker'>You hear the handset being yanked back by the cord and- disconnecting...</span>")
		if(istype(loc, /mob))
			var/mob/thismob = loc
			thismob.remove_from_mob(src)
		forceMove(linked_phone)
		linked_phone.icon_state = linked_phone.base_state
		linked_phone.phonemounted = TRUE
		linked_phone.clearconnection()
		linked_phone.stopshittyprocessing()
		if(istype(linked_phone, /obj/structure/phone/rotary))
			playsound(linked_phone, 'code/modules/keybindlibrary/phone/sound/rotaryphone/putdown1.ogg',100,0)
		else
			playsound(linked_phone, 'code/modules/keybindlibrary/phone/sound/phones/phone_slam.ogg',100,0)

/obj/item/phone/keyPress(key as text, mob/user)
	tophone(key, user)
	return TRUE

/obj/item/phone/wield(mob/user)
	if(wielded)
		return
	if(!is_held_twohanded(user))
		return
	if(user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	wielded = 1
	covered = TRUE
	if(force_wielded)
		force = force_wielded
	else
		force = (force * 1.5)
	name = "covered [name]"
	update_wield_icon()
	update_icon()//Legacy
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	user.visible_message("<span class='warning'>[user] covers the receiver on the [initial(name)].")
	if(wieldsound)
		playsound(loc, wieldsound, 50)
	var/obj/item/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second hand covering the [name]"
	O.weight = 0
	user.put_in_inactive_hand(O)
	return
/obj/item/phone/unwield(mob/user)
	..()
	covered = FALSE
/obj/item/phone/proc/on_holder_moved(mob/user, var/old_loc, var/new_loc)
	var/old_turf = get_turf(old_loc)
	var/new_turf = get_turf(new_loc)
	if(old_turf == new_turf)
		return
	if(!new_turf in range(5, get_turf(linked_phone)))
		linked_phone.icon_state = linked_phone.base_state
		user.remove_from_mob(src)
		src.forceMove(linked_phone)
		linked_phone.phonemounted = TRUE
		GLOB.moved_event.unregister(user, src, /obj/item/phone/proc/on_holder_moved)

/obj/item/phone/proc/tophone(key as text, mob/living/user)
	if(linked_phone)
		linked_phone.inputnumber(key, user)

/obj/item/paper/phonebook
	name = "PHONE BOOK.."
	desc = "A worn piece of paper covered in a series of dots and dashes. It seems to be a technical print out from a computer."
	icon = 'icons/obj/warfare.dmi'
	icon_state = "paper"
	item_state = "paper"

/obj/item/paper/phonebook/Initialize()
	. = ..()
	var/list/Pinfo = "PHONES .. . . <br>"
	// ^^ Too long, make it shorter please // NOTES: REMEMBER: WHEN PUTTING STUFF ON PAPER, IT **HAS** TO BE A LIST!!
	//to_chat(usr,"DEV MESSAGE: [Pinfo]")
	for(var/obj/structure/phone/phone in GLOB.phone_list)
		if(!phone.hiddenphone && phone.fullphonenumber && phone.phonename)
			Pinfo += "<br>[phone.phonename] - [phone.fullphonenumber]<br>"
		else
			continue
	Pinfo += "<br>!HAVE A NICE DAY.!<br>"
	info = Pinfo // THEN you set the obj's info to the list!!
	SetName("Phone book")

/obj/item/phone/rotary
	name = "Rotary phone handset"
	desc = "Black plastic.."
	icon_state = "handsetrotary"

/obj/item/phone/red
	name = "Rotary phone handset"
	desc = "Black plastic.."
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	icon_state = "redmistake"

/obj/item/phone/blue
	name = "Rotary phone handset"
	desc = "Black plastic.."
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	icon_state = "bluemistake"