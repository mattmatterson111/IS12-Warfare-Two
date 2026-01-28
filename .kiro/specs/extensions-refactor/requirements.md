# Extensions Module Refactor - Requirements

## Overview
Refactor the `code/modules/lorepaper` module into `code/modules/extensions` with a focus on code quality, organization, and maintainability. The primary goal is to eliminate technical debt, improve code clarity, and establish a solid foundation for future expansions. Additionally, implement a fully functional cargo train system and expand ERT capabilities.

## Scope
- **Rename module**: `lorepaper` → `extensions`
- **Refactor**: All code except `random_mid.dm` and `special_unit_spawn.dm`
- **Focus areas**: ERT system, war lore, cargo extensions, medical expansion, artillery, screen alerts, atom HUD, location system, more endings, and cargo train implementation

## User Stories

### 1. Module Organization
**As a** developer
**I want** the extensions module to have a clear, logical folder structure
**So that** I can easily find and maintain related functionality

**Acceptance Criteria:**
- [ ] 1.1 Module renamed from `lorepaper` to `extensions`
- [ ] 1.2 Each major feature has its own subdirectory (e.g., `ert/`, `war_lore/`, `cargo/`, `medical/`, etc.)
- [ ] 1.3 Shared utilities are in a `_common/` or `_shared/` directory
- [ ] 1.4 All files follow consistent naming conventions (no "shitcode" or vague names)
- [ ] 1.5 README.md documents the module structure and purpose of each subdirectory

### 2. ERT System Cleanup
**As a** developer
**I want** the ERT (Emergency Response Team) system to be well-organized and maintainable
**So that** I can easily add new squad types, customize behaviors, and debug issues

**Acceptance Criteria:**
- [ ] 2.1 ERT code is organized into logical files: `squad_base.dm`, `squad_templates.dm`, `squad_members.dm`, `squad_commands.dm`, `squad_waypoints.dm`
- [ ] 2.2 All "shitcode" comments are removed and code is refactored to be clear
- [ ] 2.3 Submarine transport system is extracted into `transport/` subdirectory with clear separation of concerns
- [ ] 2.4 Admin commands are consolidated and documented
- [ ] 2.5 Squad member spawning logic is simplified and well-commented
- [ ] 2.6 All variable declarations use modern DM syntax (no unnecessary `var/` keywords)

### 3. War Lore System
**As a** developer
**I want** the war lore generation system to be modular and extensible
**So that** I can easily add new name generators, structures, and lore elements

**Acceptance Criteria:**
- [ ] 3.1 War lore code is extracted into `war_lore/` subdirectory
- [ ] 3.2 Name generation logic is separated into `name_generator.dm`
- [ ] 3.3 Terminal interface is in `war_terminal.dm`
- [ ] 3.4 Lore data (prefixes, suffixes, structures) is in `lore_data.dm`
- [ ] 3.5 System is documented with examples of how to extend it

### 4. Feature Modules Cleanup
**As a** developer
**I want** each feature module (cargo, medical, artillery, etc.) to be self-contained and well-documented
**So that** I can maintain and extend them independently

**Acceptance Criteria:**
- [ ] 4.1 Cargo extension is in `cargo/` with clear structure
- [ ] 4.2 Medical expansion is in `medical/` with clear structure
- [ ] 4.3 Artillery system is in `artillery/` with clear structure
- [ ] 4.4 Screen alerts system is in `screen_alerts/` with clear structure
- [ ] 4.5 Atom HUD text system is in `atom_hud/` with clear structure
- [ ] 4.6 Location system is in `location/` with clear structure
- [ ] 4.7 More endings system is in `endings/` with clear structure
- [ ] 4.8 Each module has a README or inline documentation explaining its purpose

### 5. Code Quality
**As a** developer
**I want** all code to follow best practices and be free of technical debt
**So that** the codebase is maintainable and performant

**Acceptance Criteria:**
- [ ] 5.1 All syntax warnings are resolved (e.g., unnecessary `var/` keywords)
- [ ] 5.2 All commented-out code is removed or properly documented
- [ ] 5.3 All proc names are descriptive and follow naming conventions
- [ ] 5.4 All global variables are properly documented
- [ ] 5.5 Code is formatted consistently throughout the module
- [ ] 5.6 No debug code or admin-only buttons left in production code

### 6. Documentation
**As a** developer
**I want** the extensions module to be well-documented
**So that** I can understand how to use and extend each system

**Acceptance Criteria:**
- [ ] 6.1 Module-level README.md exists with overview and structure
- [ ] 6.2 Each subdirectory has a README or inline documentation
- [ ] 6.3 Complex systems (ERT, war lore) have usage examples
- [ ] 6.4 All public procs are documented with purpose and parameters
- [ ] 6.5 Integration points with other modules are documented

### 7. Cargo Train System
**As a** game designer
**I want** a cargo train system that delivers supplies between respawn waves
**So that** players have access to random supplies and the game feels more dynamic

**Acceptance Criteria:**
- [ ] 7.1 Cargo train arrives every 2 respawn waves (between respawn wave timing)
- [ ] 7.2 Cargo train arrives immediately after passenger train leaves
- [ ] 7.3 Cargo train contains 3-8 random crates from a whitelisted set of crate types
- [ ] 7.4 Clicking on cargo train carriage extracts one crate and places it below the player
- [ ] 7.5 Carriage updates visually when empty (icon/state changes)
- [ ] 7.6 Cargo train leaves early if all crates are removed
- [ ] 7.7 Cargo train leaves when passenger train arrives (even if crates remain)
- [ ] 7.8 Remaining crates are cleared when train leaves to make space for next delivery
- [ ] 7.9 Cargo train has distinct visual appearance from passenger train
- [ ] 7.10 Sound effects play when train arrives, stops, and departs
- [ ] 7.11 Whitelisted crate types are configurable and include: wooden crates, grenade crates, club crates, pickaxe crates, hardhat crates

### 8. ERT System Expansions
**As a** admin/game designer
**I want** expanded ERT functionality for more dynamic squad management
**So that** I can create more varied and interesting squad scenarios

**Acceptance Criteria:**
- [ ] 8.1 Squad loadout customization system (allow different equipment per squad type)
- [ ] 8.2 Squad skill presets (combat, medical, engineering, etc.)
- [ ] 8.3 Enhanced waypoint system with 10+ waypoint types
- [ ] 8.4 Squad communication system (squad-specific radio channel)
- [ ] 8.5 Squad statistics tracking (kills, deaths, objectives completed)
- [ ] 8.6 Mission briefing system (display objectives on spawn)
- [ ] 8.7 Squad loadout presets for different mission types
- [ ] 8.8 Admin command to view squad status and statistics
- [ ] 8.9 Admin command to customize squad appearance/loadout on the fly
- [ ] 8.10 Squad morale/cohesion system affecting performance

## Suggested Expansions & Ideas

### ERT System Enhancements
- **Advanced Squad AI**: Create AI-controlled squad members for testing or solo missions
- **Squad Loadout Marketplace**: Allow squads to purchase equipment upgrades
- **Faction Relationships**: Different factions have different equipment and abilities
- **Squad Specializations**: Sniper teams, assault teams, support teams with unique abilities
- **Persistent Squad Data**: Save squad performance across rounds

### Cargo Train Enhancements
- **Dynamic Crate Contents**: Crates contain random items based on rarity tiers
- **Cargo Train Customization**: Different cargo trains for different factions
- **Cargo Manifest System**: Admin can see what's in the train before it arrives
- **Cargo Insurance**: Damaged crates have reduced value
- **Cargo Auctions**: Players bid on cargo before it arrives

### War Lore Enhancements
- **Dynamic Lore Events**: Generate random lore events that affect gameplay
- **Faction System**: Expand faction system with more detailed faction histories and relationships
- **Lore Terminals**: Add more terminal types with different lore generation styles
- **Lore Persistence**: Save generated lore to database for consistency across rounds

### General Improvements
- **Configuration System**: Create a centralized config file for all extensions module settings
- **Event System**: Implement event hooks for squad spawning, directive changes, cargo arrival, etc.
- **Logging**: Add comprehensive logging for admin actions, squad activities, and cargo deliveries
- **Testing**: Create unit tests for critical systems (name generation, squad spawning, cargo distribution)

## Non-Goals
- Do not modify `random_mid.dm`
- Do not modify `special_unit_spawn.dm`
- Do not change core gameplay mechanics
- Do not break existing admin commands or functionality
