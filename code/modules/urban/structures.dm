// DOOR FUCK

/obj/machinery/door/unpowered/simple/doubledoor
	icon = 'icons/obj/urban/doubledoor.dmi'
	icon_state = "door"
	icon_base = "door"
	opacity = 1
	density = 1
	color = null

/obj/machinery/door/unpowered/simple/doubledoor/New(var/newloc,var/material_name,var/complexity)
	..(newloc, "wood", complexity)
	color = null

// LIGHTS


/obj/item/device/flashlight/lamp/captain/urban_streetlamp
	desc = "A lamp with a.. very.. bright bulb.."
	icon = 'icons/obj/urban/32x64.dmi'
	icon_state = "lamp0"
	plane = ABOVE_HUMAN_PLANE
	anchored = TRUE
	on = TRUE
	brightness_on = 8
	light_power = 4
	light_range = 16
	light_color = "#e6d8ba"

/obj/item/device/flashlight/lamp/captain/urban_streetlamp/attack_hand(mob/user)
	return FALSE

/*
	if(CanPhysicallyInteract(user))
		on = !on
		if(activation_sound)
			playsound(src.loc, activation_sound, 75, 1)
		update_icon()
		return
*/

//[[-- Windows --]]

/obj/structure/window_frame/urban_crete
	icon = 'icons/obj/urban/32x32windows.dmi'
	icon_state = "sc_alt1"
	maxhealth = 50 // Changed the health so that bullets instantly break windows. More satisfying this way.

/obj/structure/window_frame/urban_crete/perspective
	icon_state = "urbanpersp1"

/obj/structure/window_frame/urban_crete/perspective/update_icon()
	var/state = copytext(icon_state, 1, length(icon_state))
	if(glass)
		if(health <= HALF_HEALTH)
			icon_state = state+"2"
		else
			icon_state = state+"1"
	else
		if(shattered)
			icon_state = state+"3"
		else
			icon_state = state+"4"
		overlays.Cut()
		var/image/I = image(icon=src.icon, icon_state = "[state]_over", dir = src.dir)
		I.plane = ABOVE_HUMAN_PLANE
		I.layer = ABOVE_HUMAN_LAYER
		overlays += I

/obj/structure/window_frame/urban_crete/eastwest
	icon_state = "sc_direw1"

/obj/structure/window_frame/urban_crete/northsouth
	icon_state = "sc_dirns1"


//[[-- Deco --]]

// railings

/obj/structure/railing/urban
	icon = 'icons/obj/urban/32x32deco.dmi'
	icon_state = "urban_railing_1"

/obj/structure/railing/urban/update_icon()
	return FALSE

/obj/structure/railing/urban/NeighborsCheck()
	return FALSE

/obj/structure/railing/urban/alt
	icon_state = "urban_railing_2"

/obj/structure/railing/urban/corner
	icon_state = "urban_railing_c"

/obj/structure/railing/urban/ending
	icon_state = "urban_railing_c"
	density = FALSE


/obj/structure/effect/urban
	icon = 'icons/obj/urban/32x32deco.dmi'
	icon_state = ""
	mouse_opacity = FALSE
	anchored = TRUE
	density = FALSE


// drains

/obj/structure/effect/urban/drain
	icon_state = "drainage"

/obj/structure/effect/urban/oldpipe
	icon_state = "oldpipe"

// trash

/obj/structure/effect/urban/trashcan
	icon_state = "trashcan"

/obj/structure/effect/urban/trash
	icon_state = "trash_single"

/obj/structure/effect/urban/trash_decal
	icon_state = "trash_decal"

/obj/structure/effect/urban/trash_decal/alt
	icon_state = "trash_decal_alt"

// grafitti

/obj/structure/effect/urban/graf_red
	icon = 'icons/obj/urban/32x32deco.dmi'
	icon_state = "red_grafitti_1"


// grille

/obj/structure/grille/sewer
	icon = 'icons/obj/urban/32x32deco.dmi'
	health = 75 // tough.

/obj/structure/vague_statue
	name = "Statue of.. whoever it was."
	desc = "A statue, it could be anything really."
	icon = 'icons/obj/urban/the_statue.dmi'
	icon_state = "statue_ambiguous"
	plane = ABOVE_HUMAN_PLANE

/obj/structure/vague_statue/ex_act(severity)
	return FALSE

/obj/structure/vague_statue/bullet_act(obj/item/projectile/P, def_zone)
	return FALSE

/obj/structure/vague_statue/red
	icon_state = "statue_red"

/obj/structure/vague_statue/blue
	icon_state = "statue_blue"

/obj/structure/vague_statue/random/New()
	. = ..()
	icon_state = "statue_[pick("ambiguous","red","blue")]"

/obj/structure/bed/chair/torture
	icon_state = "torturechair_preview"
	color = "#FFFFFF"
	base_icon = "torturechair"