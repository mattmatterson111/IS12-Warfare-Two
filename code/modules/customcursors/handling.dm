/mob/proc/update_aim_icon()
	if(!client)
		return

	var/obj/item/gun/G = get_active_hand()

	if(istype(G) && !G.safety)
		if(dispersion_mouse_display_number > 0 && dispersion_mouse_display_number < 2)
			client.mouse_pointer_icon = 'icons/effects/standard/weapon_pointer_auto.dmi'
		else if(dispersion_mouse_display_number >= 4)
			client.mouse_pointer_icon = 'icons/effects/standard/weapon_pointer_fuck.dmi'
		else
			if(weapon_readied)
				client.mouse_pointer_icon = 'icons/effects/standard/weapon_pointer.dmi'
			else
				client.mouse_pointer_icon = 'icons/effects/standard/weapon_pointer_auto.dmi'
		if(dispersion_mouse_display_number > 20)
			dispersion_mouse_display_number = 20
			recoil = 20
		if(dispersion_mouse_display_number <= 0)
			dispersion_mouse_display_number = 0
			recoil = 0
		dispersion_mouse_display_number -= 10

	else
		if(client)
			client.mouse_pointer_icon = 'icons/misc/pointer_cursor.dmi'

/client/proc/update_cursor(atom/object)
	mob.update_aim_icon()
	if(!object)
		return
	var/currenthand
	switch(mob.hand)
		if(0)
			currenthand = mob.r_hand
		if(1)
			currenthand = mob.l_hand
	if(object.getCursor(mob, currenthand))
		mouse_pointer_icon = object.getCursor(mob, currenthand)