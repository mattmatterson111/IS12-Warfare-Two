// Redo this shitcode and add glowing fx to the primed c4

/obj/structure/key_relay
	name = "/obj/structure/key_relay"
	desc = "Not supposed to see this."
	var/obj/host = null// ???????

/obj/structure/key_relay/New(var/obj/owner)
	. = ..()
	host = owner
	icon = owner.icon
	name = owner.name
	desc = owner.desc

/obj/structure/key_relay/keyPress(key, user)
	return host.keyPress(key, user)

/obj/structure/key_relay/plastique
	name = "plastic explosives"
	desc = "You've got a bad feeling about this.." // icky VV..
	plane = ABOVE_OBJ_PLANE
	layer = ABOVE_DOOR_LAYER
	var/obj/item/plastique/keypad/plastic_explosive = null //?????????????
	var/target

/obj/structure/key_relay/plastique/proc/add_glow()
	var/image/addon = image(icon = src.icon, icon_state = "[src.icon_state]_glow") // Bright fringe
	addon.layer = ABOVE_LIGHTING_LAYER
	addon.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	overlays += addon
	return TRUE

/obj/structure/key_relay/plastique/keyPress(key, mob/user)
	if(plastic_explosive.active)
		if(user.Adjacent(target))
			if(!CanPhysicallyInteract(user))
				return FALSE
			return plastic_explosive.keyPress(key, user)

/obj/structure/key_relay/plastique/attack_hand(mob/user)
	if(!plastic_explosive.active)
		if(do_after(user,5 SECONDS))
			user.put_in_active_hand(plastic_explosive)
			plastic_explosive.relay = null
			plastic_explosive = null
			qdel(src)
			return TRUE
		else
			return FALSE

/obj/item/plastique/keypad
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	var/stored_numbers = ""
	var/current_numbers = ""
	var/max_length = 4
	var/can_input = TRUE
	var/active = FALSE
	var/obj/structure/key_relay/plastique/relay = null
	var/defused_state = "plastic-explosive0"

/obj/item/plastique/keypad/red
	icon_state = "red4"
	item_state = "red4"
	worldicons = "red4_world"
	primed_state = "red4_primed"
	defused_state = "red4_world"

/obj/item/plastique/keypad/blue
	icon_state = "blue4"
	item_state = "blue4"
	worldicons = "blue4_world"
	primed_state = "blue4_primed"
	defused_state = "blue4_world"
/*
/obj/item/plastique/New()
	wires = new(src)
	image_overlay = image('icons/obj/assemblies.dmi', "plastic-explosive2")
	..()

/obj/item/plastique/Destroy()
	qdel(wires)
	wires = null
	return ..()
*/

/*
/obj/item/plastique/attackby(var/obj/item/I, var/mob/user)
	if(isScrewdriver(I))
		open_panel = !open_panel
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")
	else if(isWirecutter(I) || isMultitool(I) || istype(I, /obj/item/device/assembly/signaler ))
		wires.Interact(user)
	else
		..()
*/
/*
/obj/item/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_hand() == src)
		newtime = Clamp(newtime, 10, 60000)
		timer = newtime
		to_chat(user, "Timer set for [timer] seconds.")
*/
/obj/item/plastique/keypad/proc/set_code(var/numbers, var/mob/user)
	if(numbers)
		to_chat(user, SPAN_DANGER("It is set.."))
		stored_numbers = numbers
		current_numbers = ""
		can_input = FALSE
		spawn(2 SECONDS)
			can_input = TRUE
		return TRUE
	else
		return FALSE

/obj/item/plastique/keypad/proc/reset_code(var/mob/user)
	current_numbers = ""
	stored_numbers = ""
	return TRUE

/obj/item/plastique/keypad/keyPress(key, user)
	if(!key && user)
		return TRUE
	if(can_input)
		if(!active && !isworld(loc))
			if(!CanPhysicallyInteract(user))
				return FALSE
			if(length(current_numbers) >= max_length && stored_numbers)
				// reset code
				to_chat(user, "You reset the code.")
				return reset_code(user)
			current_numbers += key
			playsound(get_turf(src), "keypad", 25, 0)
			to_chat(user, "You input [SPAN_DANGER(current_numbers)]..")
			if(length(current_numbers) == max_length)
				set_code(current_numbers, user)
				return TRUE
			return TRUE
		else if(active)
			current_numbers += key
			playsound(get_turf(src), "keypad", 25, 0)
			to_chat(user, "You input [SPAN_DANGER(current_numbers)]..")
			if(length(current_numbers) >= max_length)
				if(current_numbers == stored_numbers)
					reset_code()
					active = FALSE
					playsound(get_turf(src), 'sound/effects/keypad/correct.ogg', 45, 0)
					relay.icon_state = defused_state
					relay.overlays.Cut()
					return TRUE
				else
					current_numbers = ""
					playsound(get_turf(src), 'sound/effects/keypad/deny.ogg', 45, 0)
					return FALSE
		else return FALSE
	else
		return FALSE

/obj/item/plastique/keypad/afterattack(atom/movable/target, mob/user, flag, params)
	if (!flag)
		return
	if(!istype(target, /obj/machinery/door) && !iswall(target))
		return
	if(!stored_numbers)
		to_chat(user, "It doesn't have a code!")
		return
	to_chat(user, "Planting explosives...")
	user.do_attack_animation(target)

	if(do_after(user, 50, target) && in_range(user, target))
		user.remove_from_mob(src)
		src.target = target

		if (ismob(target))
			admin_attack_log(user, target, "Planted \a [src] with a [timer] second fuse.", "Had \a [src] with a [timer] second fuse planted on them.", "planted \a [src] with a [timer] second fuse on")
			user.visible_message("<span class='danger'>[user.name] finished planting an explosive on [target.name]!</span>")
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")

		else
			log_and_message_admins("planted \a [src] with a [timer] second fuse on \the [target].")


		playsound(get_turf(src), "military_rustle_light", 50, 0.5)

		//target.overlays += image_overlay

		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/direction = get_dir(user, target)
		switch(direction)
			if(NORTH)
				pixel_y_diff = 32
			if(SOUTH)
				pixel_y_diff = -32
			if(EAST)
				pixel_x_diff = 32
			if(WEST)
				pixel_x_diff = -32
			if(NORTHEAST)
				pixel_x_diff = 32
				pixel_y_diff = 32
			if(NORTHWEST)
				pixel_x_diff = -32
				pixel_y_diff = 32
			if(SOUTHEAST)
				pixel_x_diff = 32
				pixel_y_diff = -32
			if(SOUTHWEST)
				pixel_x_diff = -32
				pixel_y_diff = -32

		//var/list/mouse_control = params2list(params)
		//var/mouse_x = text2num(mouse_control["icon-x"])
		//var/mouse_y = text2num(mouse_control["icon-y"])

		relay = new/obj/structure/key_relay/plastique(src)

		relay.pixel_y = pixel_y_diff
		relay.pixel_x = pixel_x_diff
		relay.target = src.target

		relay.host = src

		relay.forceMove(get_turf(src))
		forceMove(relay)

		active = TRUE

		relay.icon_state = primed_state
		relay.add_glow()

		to_chat(user, "Bomb has been planted. Timer counting down from [timer].")
		spawn(timer*10)
			if(active)
				explode(get_turf(target))

/obj/item/plastique/keypad/explode(location)
	if(!target)
		target = get_atom_on_turf(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 2, 3, particles = TRUE, autosize = TRUE)

	if(target)
		if (istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else if(istype(target, /mob/living))
			target.ex_act(2) // c4 can't gib mobs anymore.
		else
			target.ex_act(1)
	if(target)
		target.overlays -= image_overlay
	qdel(relay)
	relay = null
	qdel(src)

/obj/item/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/plastique/red
	icon_state = "red4"
	item_state = "red4"
	worldicons = "red4_world"
	primed_state = "red4_primed"

/obj/item/plastique/blue
	icon_state = "blue4"
	item_state = "blue4"
	worldicons = "blue4_world"
	primed_state = "blue4_primed"