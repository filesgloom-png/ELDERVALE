# ELDERVALE — Long-Term Feature Roadmap

This roadmap is part of the project so future development keeps these ideas in scope.

## Core direction
- Dark-fantasy top-down action RPG for Android, Godot 4.5.1, ARM64.
- Keep the offline single-player foundation stable first. Do not add networking until the gameplay systems are ready and the user explicitly moves the project into its multiplayer phase.
- Preserve the existing 10 classes / 30 specializations direction, combat, talents, equipment, crafting, bosses, dungeons, raids, and progression toward level 100.

## Life skills and world activities
Planned for a later dedicated implementation stage:
- Fishing with distinct species and rarity tiers.
- Fishing spots with location-specific catches; time, weather, season, and world events can influence the catch table once those world systems exist.
- Fishing loot is useful: cooking ingredients, alchemy materials, trade goods, rare relics, clues, and occasional discoveries.
- Additional professions and activities: cooking, alchemy, gathering, hunting, material processing, crafting, trading, and collecting.
- These systems should connect to progression and the economy rather than become isolated minigames.

## Distinctive feature: Echoes of the World
The world should reveal secrets through evidence left by creatures, locations, and events.
- Echo fragments can be discovered through combat and exploration.
- Collections of echoes can temporarily resonate with the player and later unlock codex entries, recipes, hidden routes, and story fragments.
- Rare catches, unusual enemy drops, environmental clues, and boss encounters can combine into multi-step discoveries.
- Example: a strange fish carries a sigil; the sigil points to flooded ruins; the ruins reveal a unique encounter or crafting recipe.
- Discoveries should reward observation and experimentation, not only raw grinding. Avoid making every clue a simple waypoint marker.

## Implementation order
1. Keep verifying the current Android export and save/load behavior.
2. Expand combat rewards and gear progression with careful balance.
3. Establish the first Echoes of the World loop as a small, testable mechanic.
4. Add fishing after the map has a real water area and interaction flow.
5. Connect fishing, cooking, alchemy, crafting, exploration, and the codex.
6. Build more zones, quests, dungeons, and bosses.
7. Revisit authoritative multiplayer/server architecture only after the offline gameplay foundation is dependable.

## Engineering constraints
- Work through GitHub and GitHub Actions only; the user does not use Termux or edit code manually.
- Check branch HEAD and recent CI before each implementation step.
- Keep the Android ARM64 workflow green; diagnose and fix the exact failing step if it fails.
- Never claim physical-device testing unless the user confirms it.
