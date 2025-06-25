#define SCALE_NUMBER ((32 - 250) / 2)

/obj/plane/darkness
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0.05,0.05,0.05,1)
	mouse_opacity = 0
	screen_loc = "CENTER"
	New()
		..()
		vis_contents += new/obj/backdrop

	// Now for the darkness, we set atom.color to a pure black with about 10% alpha
	// And mouse_opacity has 0 so your lights and darkness don't capture mouse events.
	// We're also adding a pure black backdrop to the player's screen using this plane and the backdrop object.
	// We set blend_mode to BLEND_MULTIPLY here because we want it to multiply the color of anything behind it.
	// Which means most everything behind it (on plane 0, the default) is going to blend darker.
	// This way when you add the BLEND_ADD of the lights on the same plane you start pushing backwards towards the base coloring.
	// This accomplishes a darkness/lighting effect nicely.
	// Some prototypes to turn into objects so we can manipulate the planes and light after creation.
			// You don't actually need to store them in variables if you don't plan to do anything with them later.

/obj/backdrop
	icon = 'icons/mob/screen1.dmi'
	icon_state = "black"
	layer = BACKGROUND_LAYER
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	New()
		..()
		transform = matrix(world.view*2+5, MATRIX_SCALE)

/obj/effect/light
	mouse_opacity = 0
	icon = 'icons/effects/lighting_types.dmi'
	icon_state = "light"
	plane = LIGHTING_PLANE // We want it on the same plane as the darkness master (1)
	blend_mode = BLEND_ADD // The light will be added to anything behind it
	appearance_flags = RESET_ALPHA | RESET_TRANSFORM | LONG_GLIDE | KEEP_APART  // We generally don't want the light being touched by the transform/alpha of the attached object.
	var/scale_amount = 1



/mob
	var/tmp/obj/screen/plane_master/master_plane
	var/tmp/obj/plane/darkness/darkness_plane

/mob/proc/update_lighting()
	client?.screen.Remove(master_plane,darkness_plane)
	darkness_plane = new()
	client?.screen.Add(master_plane,darkness_plane)

/mob/Login()
	..()
	// First we create the two planes, then the light object.
	// And throw the planes onto the screen

	darkness_plane = new()
	master_plane = new()
	client.screen.Add(master_plane,darkness_plane)
	// I was using vis_contents here, but that requires complicating the code needlessly with extra appearance flags, so we'll stick to client.screen for simplicity.
	// As long as a PLANE_MASTER is visible to the client in someway (either via client.screen, on the map, a visible /image, etc) it'll do its thing.
	// Now we add the light to vis_contents, which is effectively like an overlay in this case without the extra overhead.

