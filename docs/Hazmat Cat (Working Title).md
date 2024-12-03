## Goal
The goal of the game is to cooperate to bring an item safely to the end of a level, the challenge coming from the fact that the item can take damage if struck or dropped, and that the level consists of a series of rooms that contain obstacles and traps 
## The Item
Should be able to take damage from being struck directly (by one of the traps, or accidentally by a player using a tool), or from falling to the ground. Most of the damage should be based on how hard the physical strike is. The damage should be visible on the item itself, as that will be the only way players can determine the integrity of the item until it is delivered. Breaking the item is the only game-over state
## The Player
The player can walk, run, jump, grab ledges, crouch, dangle off ledges (by crouching near one) pick up objects, use tools, and dive
The player can carry one object at a time, be it The Item, a tool, or just a physics prop
The player can throw whatever they're holding with variable strength
The player can survive most fall distances, but falling even a moderate distance will result in a stun and cause the player to drop anything they're carrying, posing a risk to The Item
If the player dies, they will respawn after a short delay at the start of the room they died in, so long as the item is still intact
## Multiplayer Interaction
Players can take items out of each others hands
I'd like to add more direct interactions like that, but I think most of the cooperation will be from throwing items to each other, making pathways with tools, and catching The Item on the rebound should the current carrier get caught by a trap of some sort
## Tools
This one still has a lot of things up in the air. 
Right now I have a staple gun and a really simple ladder. The staple gun shoots staples that stick into walls and act as platforms. The ladder is a phyiscs object that can be set down and allows the player to 'climb' it. 
Should the players have many odd tools with overlapping uses? Should they have one or two very versatile tools? Would it be fun it the tool selection was also randomized? I think maybe focusing on the game without the tools for now is best. Just safely carrying the box around should be made fun on its own, then tools can add interest and variety to that loop
## The Level
The level consists of a series of rooms filled with obstacles and traps that are designed to make it difficult to navigate without careful consideration of The Item. 
#### Generation
Currently, level generation works as follows:
- The starting room is spawned and set as the 'current' room
- A connection point is randomly selected from the current room
- A new room is randomly selected from the list of possible rooms and instantiated
- A connection point is randomly selected from the new room
- The new room is rotated so that its connection point aligns with the current room's connection point
- The new room is set as the 'current' room, and the process is repeated from the second step, until the desired number of rooms is reached
## Room Design
Rooms should have two or more connection points. 
If possible, and for the sake of gameplay variety, rooms should be challenging to traverse no matter what connection points are randomly selected as the entrance and exit. This is why fall damage is important, as that means climbing up and climbing down both present threats to the item.
Though not currently supported I think it would be easy enough to make a room that has a pre-defined entrance or exit (maybe a room that presents a puzzle, or a choice of paths)
Rooms can be any size
Rooms should be fully enclosed
Rooms should have pre-defined locations for traps to spawn, if desired
## Traps
Similar to lethal company's traps, they can be randomly spawned in rooms at the time of generation. Traps should try to kill the player, but in a way that allows for the item to be thrown by the victim before succumbing , or allow a teammate to grab the item out of the victims hands before they're lost. If the player is killed suddenly, the item should have a physics impulse pop it into the air, both for comedic effect and to allow a teammate time to recover the item safely, potentially