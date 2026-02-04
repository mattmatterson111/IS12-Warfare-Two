/atom
	var/light_power = 1 // intensity of the light
	var/light_range = 0 // range in tiles of the light
	var/light_color		// Hexadecimal RGB string representing the colour of the light
	var/light_shape = null

	var/datum/light_source/light
	var/list/light_sources
	var/tmp/obj/effect/light/light_new

// Nonsensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE, var/small = FALSE, var/directional = FALSE, var/animated = FALSE)
	. = 0 //make it less costly if nothing's changed

	if(l_power != null && l_power != light_power)
		light_power = l_power
		. = 1

	if(l_range != null && l_range != light_range)
		light_range = l_range
		. = 1

	if(l_color != NONSENSICAL_VALUE && l_color != light_color)
		light_color = l_color
		. = 1

	if(.)
		update_light(small, directional)


#undef NONSENSICAL_VALUE

/atom/proc/update_light(var/small = FALSE, var/directional = FALSE)
	set waitfor = FALSE

	if(light_range)
		if(!(light_new in src:vis_contents))
			light_new = new()
			if(directional)
				var/matrix/M = matrix()
				M.Scale(20)
				light_new.transform = M
				light_new.dir = src.dir

			else if(light_shape)
				light_new.icon_state = light_shape

			else if(light_range > 10) // fine
				var/matrix/M = matrix()
				M.Scale(light_range)
				light_new.transform = M

			else if(light_range > 2)
				var/matrix/M = matrix()
				M.Scale(10)
				light_new.transform = M

			else if(light_range < 0)
				var/matrix/M = matrix()
				M.Scale(0.5)
				light_new.transform = M

			else
				var/matrix/M = matrix()
				M.Scale(4)
				light_new.transform = M
			src:vis_contents += light_new

	if(light_range == 0)//No range, no light. However you can have negative range, which will make your light really small, so it's best just check for 0 instead.
		src:vis_contents -= light_new

	if(light_color)
		light_new?.color = light_color

	/*
	if(light_power)
		//light_new.transform = matrix(1,0,SCALE_NUMBER,0,1,SCALE_NUMBER)
		if(light_power != 1)
			light_new.transform = matrix(SCALE_NUMBER, MATRIX_SCALE) * light_new.transform
	*/



	/*
	if(!light_power || !light_range)
		if(light)
			light.destroy()
			light = null
	else
		if(!istype(loc, /atom/movable))
			. = src
		else
			. = loc

		if(light)
			light.update(.)
		else
			light = new /datum/light_source(src, .)
	*/

/atom/Destroy()
	if(light)
		light.destroy()
		light = null
	return ..()

/atom/set_opacity()
	. = ..()
	if(.)
		var/turf/T = loc
		if(istype(T))
			T.handle_opacity_change(src)

#define LIGHT_MOVE_UPDATE \
var/turf/old_loc = loc;\
. = ..();\
if(loc != old_loc) {\
	for(var/datum/light_source/L in light_sources) {\
		L.source_atom.update_light();\
	}\
}

/atom/movable/Move()
	LIGHT_MOVE_UPDATE

/atom/movable/forceMove()
	LIGHT_MOVE_UPDATE

#undef LIGHT_MOVE_UPDATE

/obj/item/update_light()
	. = ..()
	if(istype(loc, /atom/movable))
		var/atom/movable/M = loc
		if(light_range)
			M.vis_contents |= light_new
			vis_contents -= light_new
		else
			M.vis_contents -= light_new
			M.update_light()


/mob/update_light()
	. = ..()
	for(var/obj/item/A in src.contents)
		if(A.light_range && A.light_new)
			vis_contents |= A.light_new
		else if(A.light_new)
			vis_contents -= A.light_new


/obj/item/equipped(mob/user)
	. = ..()
	if(light_range && light_new)
		user.vis_contents |= light_new
		user.update_light()


/obj/item/pickup(mob/user)
	. = ..()
	if((light_new in vis_contents))
		user.vis_contents |= light_new
		user.update_light()


/mob/drop_from_inventory(var/obj/item/W, var/atom/target = null)
	..()
/*
	if(W && W.light_new)
		for(W.light_new in src.vis_contents)//We have no light already, so get rid of it.
			src.vis_contents -= W.light_new
			qdel(W.light_new)
			update_light()
*/
	if(W && W.light_new && W.light_new in src.vis_contents)
		src.vis_contents -= W.light_new
		qdel(W.light_new)
		update_light()


/obj/item/dropped(mob/user)
	. = ..()
	if(light_new)
		user.vis_contents -= light_new
		user.update_light()
	update_light()
