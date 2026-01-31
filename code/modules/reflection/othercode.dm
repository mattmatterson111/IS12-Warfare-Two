/proc/copy_appearance_filter_overlays(appearance_to_copy)
	return new /mutable_appearance(appearance_to_copy)

/atom
	var/mutable_appearance/total_reflection_mask
	var/shine = SHINE_MATTE

/atom/proc/make_shiny(_shine = SHINE_REFLECTIVE)
	if(total_reflection_mask)
		if(shine != _shine)
			overlays.Remove(total_reflection_mask)
		else
			return
	total_reflection_mask = mutable_appearance('icons/turf/overlays.dmi', "whiteFull", plane = REFLECTIVE_DISPLACEMENT_PLANE)
	overlays.Add(total_reflection_mask)
	shine = _shine

/atom/proc/make_unshiny()
	if(total_reflection_mask)
		overlays.Remove(total_reflection_mask)
	shine = SHINE_MATTE

/mob/
	var/has_reflection = TRUE
	var/mutable_appearance/reflective_icon

/mob/observer/ghost
	has_reflection = FALSE

/mob/living/Initialize()
	. = ..()
	if(has_reflection)
		create_reflection()

/mob/living/update_icons()
	. = ..()
	update_reflection()

/mob/living/proc/create_reflection()
	if(!has_reflection)
		return
	reflective_icon = copy_appearance_filter_overlays(appearance)
	if(render_target)
		reflective_icon.render_source = render_target
	reflective_icon.plane = REFLECTION_PLANE
	reflective_icon.pixel_y = -32
	reflective_icon.transform = matrix().Scale(1, -1)
	reflective_icon.vis_flags = VIS_INHERIT_DIR
	
	var/icon/I = icon('icons/turf/overlays.dmi', "whiteOverlay")
	I.Flip(NORTH)
	reflective_icon.filters += filter(type = "alpha", icon = I)
	overlays.Add(reflective_icon)

/mob/living/proc/update_reflection()
	if(!has_reflection)
		return
	if(!reflective_icon)
		create_reflection()
	overlays.Remove(reflective_icon)
	reflective_icon = copy_appearance_filter_overlays(appearance)
	if(render_target)
		reflective_icon.render_source = render_target
	reflective_icon.plane = REFLECTION_PLANE
	reflective_icon.pixel_y = -32
	reflective_icon.transform = matrix().Scale(1, -1)
	reflective_icon.vis_flags = VIS_INHERIT_DIR
	var/icon/I = icon('icons/turf/overlays.dmi', "whiteOverlay")
	I.Flip(NORTH)
	reflective_icon.filters += filter(type = "alpha", icon = I)
	overlays.Add(reflective_icon)

/obj/screen/wet_overlay
	name = "wetness overlay"
	icon = 'icons/turf/overlays.dmi'
	icon_state = "whiteFull"
	mouse_opacity = 0
	globalscreen = 1

/obj/screen/wet_overlay/reflection
	name = "reflection revealer"
	icon_state = "raintest"
	plane = REFLECTIVE_DISPLACEMENT_PLANE
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/obj/screen/wet_overlay/ground
	name = "ground wetness"
	icon_state = "raintest"
	plane = WET_PLANE
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	color = "#222222" // Darken the ground
