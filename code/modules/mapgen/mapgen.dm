/*
$$\      $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$$$$$$$\ $$\   $$\
$$$\    $$$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  _____|$$$\  $$ |
$$$$\  $$$$ |$$ /  $$ |$$ |  $$ |$$ /  \__|$$ |      $$$$\ $$ |
$$\$$\$$ $$ |$$$$$$$$ |$$$$$$$  |$$ |$$$$\ $$$$$\    $$ $$\$$ |
$$ \$$$  $$ |$$  __$$ |$$  ____/ $$ |\_$$ |$$  __|   $$ \$$$$ |
$$ |\$  /$$ |$$ |  $$ |$$ |      $$ |  $$ |$$ |      $$ |\$$$ |
$$ | \_/ $$ |$$ |  $$ |$$ |      \$$$$$$  |$$$$$$$$\ $$ | \$$ |
\__|     \__|\__|  \__|\__|       \______/ \________|\__|  \__|

												- By Plasmatik

The following code is designed for randomly generating areas on a map. It is based on a modified drunk-walk algorithm, along with Prim's maze generation algorithm.
Instead of using a 2D list, it stores coordinates as a string, and keys their value to a define to determine what they become, e.g., WALL, FLOOR, OPEN
By default, FALSE (0) is a floor, and TRUE(1) is a wall. The defines below allow for generating various turf types, though.

Absolutely all of this was written by me, so I'm declaring it completely open use
Anyone who wants to use this code can use it without attributing me, and I don't care if their code is open or closed source.
Go ahead and sell it if you want, I don't give a fuck.


USAGE INSTRUCTIONS

1) Define an area for your map as a child of the type of procedural generator you want to use (like area/procedural_generation/cave/spooky_caverns)
2) Place that area on the map and fill it with wall turfs
3) Optionally tweak the generation parameters by overriding the defaults, seen below

That's it. The area will now be procedurally generated.


*/

#define DIRT 0
#define WALL 1
#define OPEN 2 // pits and water features
#define MUD  3

GLOBAL_LIST_EMPTY(mapgen_areas)

SUBSYSTEM_DEF(mapgen)
	name = "Mapgen"
	wait = 10
	flags = SS_NO_FIRE
	priority = INIT_ORDER_MAPGEN
	runlevels = RUNLEVELS_DEFAULT
	can_fire = 0

	//var/list/fluid_cells = new
	var/list/mimic_turfs = new

/datum/controller/subsystem/mapgen/Initialize(start_timeofday)

	for(var/area/procedural_generation/mapgen_area as anything in GLOB.mapgen_areas)
		mapgen_area.setup_procgen()

	for(var/turf/simulated/open/T as anything in mimic_turfs)
		//T.update_mimic()
		T.update()

	mimic_turfs.Cut()

//just throwing this here.
/proc/get_chebyshev_distance(x1, y1, x2, y2)
    return max(abs(x2 - x1), abs(y2 - y1))

/proc/get_dist_with_coords(x1, y1, x2, y2)
    return sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

/proc/curved_rand(minimum, maximum, iterations = 6)
    var/total = 0
    for(var/i = 1, i <= iterations, i++)
        total += rand(minimum, maximum)
    return round(total / iterations)

/proc/cmp_z(atom/A, atom/B)
    return A.z - B.z

// Parent area type, this should not be placed on the map ever and will probably cause bugs if it is
/area/procedural_generation
	name = "Procedurally Generated Area"
	icon = 'icons/turf/areas.dmi'
	var/list/generation_map = list()
	var/list/entrances = list()
	var/list/entrance_turfs = list()

	// The bounds of the area to generate, this gets set by iterating inward over turfs on each axis using 3 1D list operations instead of 1 3D list operation
	var/low_x
	var/low_y
	var/low_z
	var/high_x
	var/high_y
	var/high_z
/*
	// Parameters related to water feature generation
	var/min_lake_size = 16
	var/max_lake_size = 64
	var/min_lakes = 3
	var/max_lakes = 6

	var/generate_water = FALSE // Turns on/off generating rivers and lakes, should probably be turned off for any area that doesn't have walls under it. Currently only works for caves
*/
// Initialize the area by adding it to the list of mapgen areas, setting its boundaries and filling the generation map with initial values

/area/procedural_generation/Initialize()
	. = ..()
	ADD_SORTED(GLOB.mapgen_areas, src, GLOBAL_PROC_REF(cmp_z)) // We start generating areas from the top down to avoid placing features on top of each other

/area/procedural_generation/proc/setup_procgen()
	// Build our boundary first, this lets us do three 1D operations instead of 1 3D operation, which will break early independently upon hitting the area's bounds
	low_x = world.maxx
	low_y = world.maxy
	low_z = world.maxz
	high_x = 1
	high_y = 1
	high_z = 1 // For future use, in case multiz generation is ever added... for some horrible reason

	for(var/turf/T in src)
		if(T.x < low_x)
			low_x = T.x
		if(T.y < low_y)
			low_y = T.y
		if(T.z < low_z)
			low_z = T.z
		if(T.x > high_x)
			high_x = T.x
		if(T.y > high_y)
			high_y = T.y
		if(T.z > high_z)
			high_z = T.z

	for(var/x = low_x, x <= high_x, x++)
		for(var/y = low_y, y <= high_y, y++)
			var/turf/current_turf = locate(x, y, src.z)
			if(iswall(current_turf))
				// We use a string key for uniqueness, we don't need to worry about memory use
				// Because this will get deallocated immediately after we finish the mapgen
				generation_map["[x]-[y]"] = TRUE

/area/procedural_generation/proc/in_bounds(check_x, check_y)
	return check_x >= low_x && check_x <= high_x && check_y >= low_y && check_y <= high_y

/area/procedural_generation/proc/final_pass() // Override this
	return

/area/procedural_generation/proc/apply_generation_map()
	for(var/key in generation_map)
		var/list/coords = splittext(key, "-")
		var/x_coord = text2num(coords[1])
		var/y_coord = text2num(coords[2])
		if(in_bounds(x_coord, y_coord))
			var/turf/destination_turf = locate(x_coord, y_coord, src.z)
			switch(generation_map[key]) // If the coordinate is set to something other than TRUE (1), it means we've carved out a space there, so we change the turf
				if(DIRT) // FALSE
					if(destination_turf && iswall(destination_turf))
						destination_turf.ChangeTurf(/turf/simulated/floor/dirty)

				if(OPEN)
					destination_turf.ChangeTurf(/turf/simulated/open)
					SSmapgen.mimic_turfs += destination_turf

				if(MUD)
					if(destination_turf && iswall(destination_turf))
						destination_turf.ChangeTurf(/turf/simulated/floor/dirty)

/area/procedural_generation/proc/update_mimics(list/mimics)
	for(var/turf/simulated/open/T as anything in mimics)
		//T.update_mimic()
		T.update()

/area/procedural_generation/proc/generate_probes() // This is for creating sound probes to tell clients what sound environments to apply when they recieve playsound calls. It should be overridden based on the mapgen type.
	return
/*
   ____
  / ___|__ ___   _____  ___
 | |   / _` \ \ / / _ \/ __|
 | |__| (_| |\ V /  __/\__ \
  \____\__,_| \_/ \___||___/

These are cave systems generated using a series of tuned drunk-walk algorithms. Generator variables will greatly impact the layout of the resulting area.
It starts by creating a series of caverns, then creating a series of tunnels that may or may not branch off of the caverns.
It then does a second pass to ensure there is a navigable path through the cave and that all entrances are connected to the nearest cavern.

These notes should help get the map to generate in a shape you want:

- The generator will remain constrained to the area's bounds, so if you set the maxes too high for the size of the area, you'll get very inconsistent terrain features
- The default numbers are tuned to generate caverns that are slightly larger than the viewport within a 100x100 tile area
- Fewer, larger caverns will create big open areas with fewer intersections
- Many, smaller caverns will leave more room for tunnels to generate and create more complex intersections
- Tunnel width causes the drunk walk to meander around while carving out tunnels, but may not ensure that tunnels will have a certain width. It just makes it more likely. Set the minimum and maximum to the same amount to reduce the variation
- Tunnels, entrance paths and branches appear similar and are designed to intersect, so it may be unclear what pathways were generated by what proc (just experiment or something idk)
- If generating lakes, they will use caverns as their centers - you want to have more caverns than lakes, or the cave might be mostly water
*/

/area/procedural_generation/cave
	var/list/cavern_centers = list()

// Various tuning knobs for different things in cave generation
// Keep in mind that min_counts and max_counts for individual terrain features are not entirely accurate here
// This is because the total number of terrain features in the generation map is limited by the size of the area to prevent overlapping
// Caverns generate first, followed by tunnels, then branches, so if you create more / larger caverns you will get fewer tunnels and branches

	var/smooth_edges = FALSE // Turns on/off edge smoothing, which carves out tiles that don't have enough neighbors to give caves a rounder appearance
	var/smooth_amount = 1 // Determines how many times the edge smoothing algorithm gets run, more times means smoother caves but may result in boring layouts

	// Tuning branches, these allow for connecting pathways from entrances to occasionally intersect with tunnels and tend to create three-way intersections (fun for gameplay, either combat or exploration)

	var/branch_chance = 15
	var/max_branches = 20
	var/max_branch_length = 8
	var/min_branch_length = 2

	// Tuning caverns, these are larger spaces created with a recursive drunk-walking algorithm that walks around in a circle. Caverns are used as nodes for tunnels and connecting paths.

	var/min_caverns = 1
	var/max_caverns = 10
	var/max_cavern_size = 32
	var/min_cavern_size = 12

	// Tuning tunnels, these are long, narrow cave sections that use a biased drunk walk algorithm that makes random turns. They use caverns as starting nodes and randomly intersect with other caverns or tunnels.
	// Depending on the generation settings, these will create more or less dead ends.

	var/max_tunnels = 64
	var/min_tunnels = 12
	var/max_tunnel_length = 20
	var/min_tunnel_length = 3
	var/max_tunnel_width = 3
	var/min_tunnel_width = 2

/area/procedural_generation/cave/setup_procgen()
	..()
	// Generate separate caverns and winding passages
	generate_caverns()
	generate_tunnels()
	// Ensure there is a path connecting the entrance to every cavern center
	setup_connections()
	// Post process to clean up things we don't want or add things we do
	final_pass()
	// Actually apply our generation map
	apply_generation_map()
	// Generate sound probes
	generate_probes()

	// Empty everything from memory now that we don't need it anymore
	generation_map.Cut()
	cavern_centers.Cut()

/area/procedural_generation/cave/final_pass()
	if(smooth_edges == TRUE)
		for(var/i = 1, i >= smooth_amount, i++)
			for(var/turf/T in src)
				if(iswall(T))
					var/ortho_walls = 0
					var/diag_walls = 0
					for(var/dir in GLOB.cardinal)
						var/turf/neighbor = get_turf(get_step(T, dir))
						if(iswall(neighbor))
							ortho_walls++
					for(var/dir in GLOB.cornerdirs)
						var/turf/neighbor = get_turf(get_step(T, dir))
						if(iswall(neighbor))
							diag_walls++
					if(ortho_walls == 0 && diag_walls == 1 || ortho_walls == 0 && diag_walls == 0)
						generation_map["[T.x]-[T.y]"] = FALSE

	//if(generate_water == TRUE)
	//	generate_water()
	//	smooth_lakes()
	//	muddy_shorelines()
/*
/area/procedural_generation/cave/generate_probes()
	for(var/coord in cavern_centers)
		var/turf/soundturf = locate(coord[1], coord[2], src.z)
		var/obj/effect/landmark/sound_probe/probe = new(soundturf, 8)
		probe.sound_env = 8
*/

// Customized drunk-walk algorithm for cavern generation
/area/procedural_generation/cave/proc/generate_caverns()
	var/current_x, current_y
	for(var/i in min_caverns to max_caverns)
		current_x = rand(low_x, high_x)
		current_y = rand(low_y, high_y)

		var/cavern_size = rand(min_cavern_size, max_cavern_size)
		for(var/j in 1 to cavern_size)
			for(var/rx in -1 to 1)
				for(var/ry in -1 to 1)
					var/nx = clamp(current_x + rx, low_x, high_x)
					var/ny = clamp(current_y + ry, low_y, high_y)
					var/adjacent_key = "[nx]-[ny]"
					generation_map[adjacent_key] = FALSE

			// Randomly move to a new position to continue generating the cavern
			current_x = clamp(current_x + rand(-2, 2), low_x, high_x)
			current_y = clamp(current_y + rand(-2, 2), low_y, high_y)

		// Add the center to the cavern_centers list
		cavern_centers += list(list(current_x, current_y))

// Customized tunneling algorithm for... tunnel generation
/area/procedural_generation/cave/proc/generate_tunnels()
	var/current_x, current_y
	var/tunnels = rand(min_tunnels, max_tunnels)
	for(var/i in 1 to tunnels)
		// Start at a random position, preferably on an existing cavern to ensure connectivity
		var/start_position = length(cavern_centers) ? pick(cavern_centers) : list(rand(low_x, high_x), rand(low_y, high_y))
		current_x = start_position[1]
		current_y = start_position[2]

		var/tunnel_length = rand(min_tunnel_length, max_tunnel_length)
		var/tunnel_width = rand(min_tunnel_width, max_tunnel_width)
		for(var/j in 1 to tunnel_length)
			// Choose a direction weighted towards uncarved spaces
			var/chosen_direction = pick(GLOB.cardinal)

			// Carve the tunnel by setting the map location to FALSE, considering the width
			for(var/w = -Floor(tunnel_width/2); w <= Floor(tunnel_width/2); w++)
				var/width_x = current_x
				var/width_y = current_y

				// Apply width offset based on the direction
				switch(chosen_direction)
					if(NORTH)
						width_x += w
					if(SOUTH)
						width_x += w
					if(EAST)
						width_y += w
					if(WEST)
						width_y += w

				var/key = "[width_x]-[width_y]"
				generation_map[key] = FALSE

			// Move in the chosen direction
			switch(chosen_direction)
				if(NORTH)
					if((current_y + 1) <= high_y)
						current_y++
				if(SOUTH)
					if((current_y - 1) >= low_y)
						current_y--
				if(EAST)
					if((current_x + 1) <= high_x)
						current_x++
				if(WEST)
					if((current_x - 1) >= low_x)
						current_x--

// This checks to make sure the entrance turf is accessible
/area/procedural_generation/cave/proc/setup_connections()
	for(var/list/entrance as anything in entrances)
		var/turf/entrance_turf = locate(entrance[1], entrance[2], entrance[3])
		entrance_turfs += entrance_turf
		if(iswall(entrance))
			entrance_turf.ChangeTurf(/turf/simulated/floor/dirty)

	// Now connect the entrances to the nearest cavern
	connect_entrances()
	// And connect caverns to each other
	connect_caverns()

/area/procedural_generation/cave/proc/connect_entrances()
	for(var/list/entrance as anything in entrances)
		var/start_x = entrance[1]
		var/start_y = entrance[2]
		var/min_distance = INFINITY
		var/list/nearest_cavern_center
		for(var/list/cavern_center as anything in cavern_centers)
			var/distance = get_chebyshev_distance(start_x, start_y, cavern_center[1], cavern_center[2])
			if(distance < min_distance)
				min_distance = distance
				nearest_cavern_center = cavern_center

		generate_path(start_x, start_y, nearest_cavern_center[1], nearest_cavern_center[2])

// This connects the entrance to the nearest cavern, then connects that cavern to the cavern closest to it, and so on, until every cavern is connected
/area/procedural_generation/cave/proc/connect_caverns()
	var/list/local_cavern_centers = src.cavern_centers.Copy()
	var/list/start = local_cavern_centers[1]
	var/start_x = start[1]
	var/start_y = start[2]

	// Loop through all cavern centers to connect them
	var/overloops = 0
	while(length(local_cavern_centers))
		overloops++
		var/min_distance = INFINITY
		var/list/nearest_cavern_center
		var/nearest_cavern_index

		// Find the nearest cavern center to the current point (entrance or last connected center)
		for(var/i in 1 to length(local_cavern_centers))
			var/list/center = local_cavern_centers[i]
			var/distance = get_chebyshev_distance(start_x, start_y, center[1], center[2])
			if(distance < min_distance)
				min_distance = distance
				nearest_cavern_center = center
				nearest_cavern_index = i

		generate_path(start_x, start_y, nearest_cavern_center[1], nearest_cavern_center[2])

		for(var/list/center as anything in local_cavern_centers)
			if(prob(branch_chance))
				var/branch_length = rand(min_branch_length, max_branch_length)
				create_branch(center[1], center[2], pick(GLOB.cardinal), branch_length)
		// Update the starting point to the last connected cavern center
		start_x = nearest_cavern_center[1]
		start_y = nearest_cavern_center[2]

		// Remove the connected cavern center from the list
		local_cavern_centers.Cut(nearest_cavern_index, nearest_cavern_index + 1)

		if(overloops > 1000)
			throw EXCEPTION("Infinite loop detected in procedural_generation/connect_entrances_and_caverns!")

/area/procedural_generation/cave/proc/create_branch(start_x, start_y, direction, length)
	for(var/i in 1 to length)
		var/key = "[start_x]-[start_y]"
		generation_map[key] = FALSE  // Carve out the path

		// Move in the chosen direction
		switch(direction)
			if(NORTH)
				start_y++
			if(SOUTH)
				start_y--
			if(EAST)
				start_x++
			if(WEST)
				start_x--

		// Randomly change the direction slightly to create a more natural branch
		if(prob(30))
			direction = pick(GLOB.cardinal)

// The actual path generation for connections is a modified drunk-walk algorithm
/area/procedural_generation/proc/generate_path(start_x, start_y, end_x, end_y, randomness = 40)
	while(start_x != end_x || start_y != end_y)
		var/key = "[start_x]-[start_y]"
		generation_map[key] = FALSE  // Carve the path

		// Calculate the direction vector towards the goal
		var/delta_x = end_x - start_x
		var/delta_y = end_y - start_y
		var/step_x = delta_x ? delta_x / abs(delta_x) : 0  // Normalize the step to be 1, -1, or 0
		var/step_y = delta_y ? delta_y / abs(delta_y) : 0

		if(prob(randomness))
			// Random direction
			var/chosen_direction = pick(GLOB.cardinal)
			switch(chosen_direction)
				if(NORTH)
					if((start_y + 1) <= high_y)
						start_y++
				if(SOUTH)
					if((start_y - 1) >= low_y)
						start_y--
				if(EAST)
					if((start_x + 1) <= high_x)
						start_x++
				if(WEST)
					if((start_x - 1) >= low_x)
						start_x--
		else
			// Biased movement towards the goal
			var/move_x = rand() < abs(delta_x) / (abs(delta_x) + abs(delta_y))
			if(move_x)
				start_x += step_x
			else
				start_y += step_y
/*
  __  __    _     __________ ____
 |  \/  |  / \   |__  / ____/ ___|
 | |\/| | / _ \    / /|  _| \___ \
 | |  | |/ ___ \  / /_| |___ ___) |
 |_|  |_/_/   \_\/____|_____|____/

These are mazes generated using Prim's algorithm. This creates perfect mazes instead of complex mazes, which means they have only one solution and all other branches lead to dead ends.
This is an evil "get fucked" type of maze and should be placed in relatively small areas unless you want to make someone suffer.
*/

/area/procedural_generation/maze
	sound_env = 13 // STONE CORRIDOR

/area/procedural_generation/maze/setup_procgen()
	..()
	generate_maze()
	apply_generation_map()
	generation_map.Cut()

/area/procedural_generation/maze/proc/generate_maze()
	var/list/entrance = entrances[1]
	var/entrance_x = entrance[1]
	var/entrance_y = entrance[2]
	var/entrance_key = "[entrance_x]-[entrance_y]"
	generation_map[entrance_key] = FALSE
	var/list/frontier = list()

	// Initialize frontier using the entrance
	for(var/dx = -1, dx <= 1, dx += 1)
		for(var/dy = -1, dy <= 1, dy += 1)
			if(abs(dx) != abs(dy))  // Exclude diagonals and self
				var/wall_x = entrance_x + dx
				var/wall_y = entrance_y + dy
				var/wall_key = "[wall_x]-[wall_y]"
				if(in_bounds(wall_x, wall_y) && generation_map[wall_key] == TRUE)
					frontier += wall_key

	// While there are frontiers, continue to carve out the maze
	while(length(frontier))
		var/random_index = rand(1, length(frontier))
		var/wall_key = frontier[random_index]
		frontier.Cut(random_index, random_index + 1)
		var/list/wall_coords = splittext(wall_key, "-")
		var/wall_x = text2num(wall_coords[1])
		var/wall_y = text2num(wall_coords[2])

		// Determine the cell that this wall divides from the maze
		var/list/directions = list("NORTH" = list(0, -1), "SOUTH" = list(0, 1), "EAST" = list(1, 0), "WEST" = list(-1, 0))
		var/visited_cells = 0
		for(var/dir in directions)
			var/modifier = directions[dir]
			var/check_x = wall_x + modifier[1]
			var/check_y = wall_y + modifier[2]
			var/check_key = "[check_x]-[check_y]"
			if(in_bounds(check_x, check_y))
				if(generation_map[check_key] == FALSE)
					visited_cells++

		if(visited_cells == 1)  // Only if exactly one of the two cells divided by the wall is visited
			generation_map[wall_key] = FALSE // Carve the wall
			// Add the neighboring walls of the newly added cell to the frontier
			for(var/dx = -1, dx <= 1, dx += 1)
				for(var/dy = -1, dy <= 1, dy += 1)
					if(abs(dx) != abs(dy))  // Exclude diagonals and self
						var/new_x = wall_x + dx
						var/new_y = wall_y + dy
						var/new_wall_key = "[new_x]-[new_y]"
						if(in_bounds(new_x, new_y) && generation_map[new_wall_key] == TRUE)
							frontier += new_wall_key  // Add to frontier if it's a wall

		// Repeat the process for the exit, ensuring it's connected to the maze.
		var/list/exit = entrances[2]
		var/exit_x = exit[1]
		var/exit_y = exit[2]
		var/exit_key = "[exit_x]-[exit_y]"
		if(generation_map[exit_key] == TRUE)  // If the exit is not carved out, connect it
			var/list/adjacent_cells = list()
			for(var/dx = -1, dx <= 1, dx += 1)
				for(var/dy = -1, dy <= 1, dy += 1)
					if(abs(dx) != abs(dy))  // Exclude diagonals and self
						var/adj_x = exit_x + dx
						var/adj_y = exit_y + dy
						var/adj_key = "[adj_x]-[adj_y]"
						if(in_bounds(adj_x, adj_y) && generation_map[adj_key] == TRUE)
							adjacent_cells += adj_key

			if(length(adjacent_cells))
				var/connecting_cell_key = adjacent_cells[rand(1, length(adjacent_cells))]
				var/list/connecting_wall_coords = splittext(connecting_cell_key, "-")
				var/connecting_wall_x = text2num(connecting_wall_coords[1])
				var/connecting_wall_y = text2num(connecting_wall_coords[2])
				var/connecting_wall_key = "[connecting_wall_x]-[connecting_wall_y]"
				// Carve out the wall between the exit and the maze
				generation_map[connecting_wall_key] = FALSE

				// Add the neighboring walls of the exit cell to the frontier
				for(var/dx = -1, dx <= 1, dx += 1)
					for(var/dy = -1, dy <= 1, dy += 1)
						if(abs(dx) != abs(dy))  // Exclude diagonals and self
							var/new_x = connecting_wall_x + dx
							var/new_y = connecting_wall_y + dy
							var/new_wall_key = "[new_x]-[new_y]"
							if(in_bounds(new_x, new_y) && generation_map[new_wall_key] == TRUE && (new_wall_key in frontier))
								frontier |= new_wall_key  // Add to frontier if it's a wall
/*
 __        ___  _____ _____ ____
 \ \      / / \|_   _| ____|  _ \
  \ \ /\ / / _ \ | | |  _| | |_) |
   \ V  V / ___ \| | | |___|  _ <
	\_/\_/_/   \_\_| |_____|_| \_\

This is for generating terrain features that have water in them, like lakes or rivers.

Lakes are generated by scattering a random number of seeds around a center point and drunk walking around each of them.
Gaps between the scattered points are then filled in to ensure that they are contiguous.

Notes about water generation:

- Due to the second pass that connects the scatter points, the wider your scatter_range and the higher your scatter_points in create_lake_at, the bigger your lakes will be, regardless of lake_size
- Since scatter variables get randomized, they are not defined as variables of the area. Just modify the numbers in the proc itself, or create an override for your specific area if you'd prefer (sorry)
- Lake generation will tend to skip caverns that are too small, so if you set the mins too high, you will end up with small caverns of land and huge caverns of water
- Rivers are not yet implemented, as I have concerns about needlessly hogging performance; this will be addressed at some point, but for now, I'm planning to fake it if I can
- Water feature generation for different types of areas should be handled differently, so the procs are designed as parent overrides. Currently though, only caves are implemented

*/
// WIP stuff

/area/procedural_generation/cave/proc/generate_circular_caverns()
	var/current_x, current_y
	for(var/i in 1 to max_caverns)
		current_x = rand(low_x, high_x)
		current_y = rand(low_y, high_y)

		// Define the center of the cavern for reference
		var/center_x = current_x
		var/center_y = current_y

		var/cavern_size = rand(min_cavern_size, max_cavern_size)

		// Calculate the radius of the cavern based on cavern_size
		// This is a simple approximation and may need tweaking
		var/cavern_radius = sqrt(cavern_size / M_PI)

		for(var/j in 1 to cavern_size)
			for(var/rx in -1 to 1)
				for(var/ry in -1 to 1)
					var/nx = clamp(current_x + rx, low_x, high_x)
					var/ny = clamp(current_y + ry, low_y, high_y)

					// Check if the new point is within the radius of the cavern center
					if(get_dist_with_coords(center_x, center_y, nx, ny) <= cavern_radius)
						var/adjacent_key = "[nx]-[ny]"
						generation_map[adjacent_key] = FALSE

			// Randomly move to a new position to continue generating the cavern
			// Make sure the new position is still within the cavern radius
			var/new_x, new_y
			do
				new_x = clamp(current_x + rand(-2, 2), low_x, high_x)
				new_y = clamp(current_y + rand(-2, 2), low_y, high_y)
			while(get_dist_with_coords(center_x, center_y, new_x, new_y) > cavern_radius)

			current_x = new_x
			current_y = new_y

		// Add the center to the cavern_centers list
		cavern_centers += list(list(center_x, center_y))

/area/procedural_generation/cave/undertrench

#undef DIRT
#undef WALL
#undef OPEN
#undef MUD