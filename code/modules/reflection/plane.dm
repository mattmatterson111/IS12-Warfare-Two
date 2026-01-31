/// Displays reflections
#define REFLECTIVE_DISPLACEMENT_PLANE_RENDER_TARGET "*REFLECTIVE_DISPLACEMENT_RENDER_TARGET"

#define FLOOR_PLANE_RENDER_TARGET "FLOOR_PLANE_RENDER_TARGET"

/obj/screen/plane_master/reflective
	name = "reflective plane master"
	plane = REFLECTION_PLANE
	appearance_flags = PLANE_MASTER
	mouse_opacity = FALSE

/obj/screen/plane_master/reflective/New(mapload)
	. = ..()
	filters += filter(type="motion_blur", y=0.7)
	filters += filter(type="alpha", render_source="*REFLECTIVE_DISPLACEMENT_RENDER_TARGET")

/obj/screen/plane_master/wet
	name = "wet plane master"
	plane = WET_PLANE
	appearance_flags = PLANE_MASTER
	mouse_opacity = FALSE

/obj/screen/plane_master/wet/New(mapload)
	. = ..()
	filters += filter(type="alpha", render_source="*WEATHER_MASK_RT")

/obj/screen/plane_master/reflective_cutter
	name = "reflective displacement plane master"
	plane = REFLECTIVE_DISPLACEMENT_PLANE
	render_target = "*REFLECTIVE_DISPLACEMENT_RENDER_TARGET"
	appearance_flags = PLANE_MASTER

/obj/screen/plane_master/reflective_cutter/New()
	..()
	filters += filter(type="alpha", render_source="*WEATHER_MASK_RT")
