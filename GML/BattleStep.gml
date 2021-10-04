/// @description Insert moves into the event log

/*
A script written for Antiem. Is the "step" event for an object, executing every frame. This object runs a turn-based battle system.

Section 1, immediately below, is full of transitions and and incrementing of various progress variables. Many of these are
simple linear interpolations used elsewhere in this object for draw events. For example, the position and size of a player
portrait is dependent on their TRANSITION variable, which is kept independently for each battler in the battleblock, which 
is a ds_grid.
*/

//DEBUG FEATURE: doubles/halves speed of combat transitions
if (obj_master.leftoption_pressed) {
	transpeed /= 2;
} else if (obj_master.rightoption_pressed) {
	transpeed *= 2;	
}

//if you're currently in STANDBY mode, and you're going to CHOOSING mode, increment S2C.
//	otherwise, decrement it.
if (standbytochoosingup) {
	standbytochoosing = min(standbytochoosing + 0.1 * transpeed, 1);	
} else {
	standbytochoosing = max(standbytochoosing - 0.1 * transpeed, 0);	
}


//if you're currently in CHOOSING mode, and you're going to CHOOSINGATTACK mode, increment C2A.
//	otherwise, decrement it. Perform special functions when C2A hits zero.
if (choosingtoattackup) {
	choosingtoattack = min(choosingtoattack + 0.1 * transpeed, 1);	
} else {
	var becamezero = choosingtoattack != 0 && max(choosingtoattack - 0.1 * transpeed, 0) == 0;//if choosingtoattack just hit zero
	choosingtoattack = max(choosingtoattack - 0.1 * transpeed, 0);
	if (becamezero) {
		if (state == CHOOSINGTARGET) {//if you press confirm on choosingtarget, this will happen
			//go to the next battler's CHOOSING mode, and go to STANDBY in the meantime.
			actionstep++;
			state = STANDBY;
		} else if (state == CHOOSINGATTACK) {//if you press cancel on choosingattack, this will happen
			//go back to choosing
			state = CHOOSING;
		}
	}
}

//if you're currently in CHOOSINGATTACK mode, and you're going to CHOOSINGTARGET mode, increment A2T.
//	otherwise, decrement it.
if (attacktotargetup) {
	attacktotarget = min(attacktotarget + 0.1 * transpeed, 1);	
} else {
	attacktotarget = max(attacktotarget - 0.1 * transpeed, 0);	
}

//if you're currently in CHOOSING mode, and you're going to CHOOSINGITEM mode, increment C2I.
//	otherwise, decrement it. Perform special functions when C2I hits zero.
if (choosingtoitemup) {
	choosingtoitem = min(choosingtoitem + 0.1 * transpeed, 1);	
} else {
	var becamezero = choosingtoitem != 0 && max(choosingtoitem - 0.1 * transpeed, 0) == 0;//if choosingtoattack just hit zero
	choosingtoitem = max(choosingtoitem - 0.1 * transpeed, 0);	
	if (becamezero) {
		if (state == CHOOSINGTARGET) {//if you press confirm on choosingtarget, this will happen
			//go to the next battler's CHOOSING mode, and go to STANDBY in the meantime.
			actionstep++;
			state = STANDBY;
		} else if (state == CHOOSINGITEM) {//if you press cancel on choosingitem, this will happen
			//go back to choosing
			state = CHOOSING;
		}
	}
}

//if you're currently in CHOOSING mode, and you're going to CHOOSINGTACTICS mode, increment C2T.
//	otherwise, decrement it.
if (choosingtotacticsup) {
	choosingtotactics = min(choosingtotactics + 0.1 * transpeed, 1);	
} else {
	choosingtotactics = max(choosingtotactics - 0.1 * transpeed, 0);	
}

for (var i = 0; i < ds_grid_height(battleblock); i++) {//iterate through all battlers
	if (battleblock[# ID, i] >= ASTER) {//if this is a hero... 
		//(ASTER is a macro equal to 101. All heroes have IDs higher than 101--all villains have ids lower.)
		if (actionstep == i && state < EXECUTING) {//if you are the active battler, and we're not executing moves, then...
			//increment up your transition variable, used in smooth transitions of gui displays
			battleblock[# TRANSITION, i] = min(battleblock[# TRANSITION, i] + 0.09 * transpeed, 1);	
		} else {
			//decrement down your transition variable, used in smooth transitions of gui displays
			battleblock[# TRANSITION, i] = max(battleblock[# TRANSITION, i] - 0.1 * transpeed, 0);	
		}
	}
}

//if characters have any damage, deal it to heroes slowly, and deal it to villains instantly.
//	damage is dealt to egos before it's dealt to health.
for (var i = 0; i < ds_grid_height(battleblock); i++) {
	if (battleblock[# PENDING, i] > 0) {//if the character has any pending damage, deal it to them.
		battleblock[# PENDING, i] -= 1;
		if (battleblock[# EGO, i] > 0) {//if the target in question has any EGO left...
			battleblock[# EGO, i] -= 1;//deal damage to their ego
		} else {//otherwise...
			battleblock[# HEALTH, i] -= 1;//deal damage to their health	
		}
		if (battleblock[# HEALTH, i] <= 0) {//if a player character drops to zero because of pending damage...
			instance_destroy();//destroy this object
			//FIX THIS: Haven't implemented proper game over behavior, yet.
			show_message("Death is not a hunter unbeknownst to its prey.\n" +
				     "...\n" +
				     "Just kidding. I'll be honest, you aren't meant to lose here. If you did--good job! You get a cookie.\n" +
				     "Anyway, I don't actually have a proper \"losing\" behavior programmed, so just head on back to the main menu, okay?");
			room_goto(rm_main_screen);//go to the main menu
			exit;//need to include this so the loop doesn't continue after the deletion of the instance.
		}
	}
}


//if you're currently in any of the CHOOSING modes, and you're going to EXECUTING mode, increment EV.
//	otherwise, decrement it.
if (state == EXECUTING) {
	executingvalue = min(executingvalue + 0.1 * transpeed, 1);
} else {
	executingvalue = max(executingvalue - 0.1 * transpeed, 0);
}

scr_fetch_special_dialog(obj_master.special, state);

//STATES BELOW. TRANSITIONS ABOVE

/*
Section 2, immediately below, is used to receive player input as to how player characters should act, and also determine how enemies will act. 
actions and such are recorded very simply. We have a 2d array, 3 wide and x tall. The source of an action is stored at 0, the action is stored
at 1, and the target is stored at 2. Targets, sources, and actions are all represented by unique ID numbers, which are used to look up data in
internal databases that are read from JSON files. Some of these databases are the battleblock, statsblock, moveblock, etc. All these databases
are store in the obj_master.
*/

if (state == STANDBY) {//if in the standby phase, which is the default
	for (var i = actionstep; i < ds_grid_height(battleblock); i++) {//set which character's actionstep is currently being decided		
		if (battleblock[# ID, i] < ASTER) {//if this unit is an enemy.
			actionlist[# SOURCE, i] = i;//this unit's position in the turn order
			actionlist[# MOVE, i] = scr_pick_move(i);//the moveid of this move
			actionlist[# TARGET, i] = scr_pick_target();//the position of the target of this move.
		} else {//if this unit is a hero...
			actionstep = i;//set the resume point to be one more along the battleblock.
			standbytochoosingup = true;
			state = CHOOSING;
			break;//break out of the loop to retrieve input from the player
		}
	}
	if (i >= ds_grid_height(battleblock)) {//if all battler's actions have been selected
		if (scanning) {//if a player, through the tactics menu, has instructed the navigator to scan the foes
			//navigators get as many chances to scan the foe as their LEADERSHIP, divided by 10
			var navran = floor(obj_master.statblock[# LEADERSHIP, obj_master.navigator] / 10);
			
			for (var i = 0; i < navran; i++) {
				//select a random stat out of the twelve
				var rand = irandom(11) + 1;
				if (!obj_master.discoveredstats[# selectedscan, rand]) {//if this stat hasn't been discovered before...
					//discover it, and create a navigator message saying you've done so
					scr_instant(scr_fetch_portrait(obj_master.navigator, obj_master.dreaming, 1), scr_fetch_navitalk(obj_master.navigator, YESSCAN));
					obj_master.discoveredstats[# selectedscan, rand] = true;
				}
			}
			//won't happen if Yessscan happened even once.
			scr_instant(scr_fetch_portrait(obj_master.navigator, obj_master.dreaming, 0.1), scr_fetch_navitalk(obj_master.navigator, NOSCAN));
		}
		//move onto the executing state
		state = EXECUTING;
		executing = true;
		actionstep = 0;
		turn++;//keeps track of the number of turns that have elapsed. Starts at 1 on the first turn.
	}
	
} else if (state == CHOOSING) {//if choosing whether to attack, use items, or use tactics
	//scr_scrolloptions scrolls through a 1-by-3 list of options, which are ATTACK, ITEM, and TACTICS. Will return one of these
	options = scr_scrolloptions("option", 3, 1, options[0], options[1],
	ATTACK, 
	ITEM, 
	TACTICS);
	
	if (obj_master.confirm_pressed) {
		audio_play_sound(snd_confirm, 0, false);
		if (option == ATTACK) {
			attacks = scr_scrolloptions("attackoption", 2, 4, battleblock[# OBJID, actionstep].lastx, battleblock[# OBJID, actionstep].lasty, 
			ATTACK1, ATTACK2, ATTACK3, ATTACK4, 
			ATTACK5, ATTACK6, ATTACK7, ATTACK8);//running this one time before switching to CHOOSINGATTACK so that you don't see the flicker when the options switch
			state = CHOOSINGATTACK;
			choosingtoattackup = true;
		} else if (option == ITEM) {
			//inventory controls are handled in obj_inventory, not obj_battle
			instance_create_depth(0, 0, -3, obj_inventory);
			state = CHOOSINGITEM;
			choosingtoitemup = true;
		} else if (option == TACTICS) {
			//tactics controls are handled in obj_battletactics, not obj_battle
			instance_create_depth(0, 0, -3, obj_battletactics);
			state = CHOOSINGTACTICS;
			choosingtotacticsup = true;
		}
		
	//allow players to undo previous actions made this round
	} else if (obj_master.cancel_pressed && actionstep != firsthero) {
		audio_play_sound(snd_cancel, 0, false);
		actionstep--;//move back one step, canceling the last action.
		while (battleblock[# ID, actionstep] < ASTER) {//if the previous step was not a player's choice...
			actionstep--;//go back another step
		}
	}
	
} else if (state == CHOOSINGATTACK) {//if choosing which attack to make
	if (instance_exists(battleblock[# OBJID, actionstep])) {//if the instance currently being executed exists--
		//scroll through the two by four menu, starting the cursor where it was last chosen
		scr_scrolloptions("attackoption", 2, 4, battleblock[# OBJID, actionstep].lastx, battleblock[# OBJID, actionstep].lasty,
		ATTACK1, ATTACK2, ATTACK3, ATTACK4, 
		ATTACK5, ATTACK6, ATTACK7, ATTACK8);
	}
	if (obj_master.cancel_pressed) {
		audio_play_sound(snd_cancel, 0, false);
		choosingtoattackup = false;
	} else if (obj_master.confirm_pressed) {
		audio_play_sound(snd_confirm, 0, false);
		attacktotargetup = true;
		state = CHOOSINGTARGET;
	}
	
} else if (state == CHOOSINGTARGET) {//if choosing who to target with your item/attack
	var xmodifier = 0//how offset the targeting for the previous target ought to be
	var ymodifier = 0;//how offset the targeting for the previous target ought to be
	var nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
	if (obj_master.left_pressed) {//if you press left
		while (nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			xmodifier += -100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.right_pressed) {//if you press right
		while (nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			xmodifier += 100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.up_pressed) {//if you press up
		while (nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			ymodifier += -100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.down_pressed) {//if you press down
		while (nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			ymodifier += 100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	}
	targetoption = nearest.blockid;
		
	if (obj_master.cancel_pressed) {
		audio_play_sound(snd_cancel, 0, false);
		attacktotargetup = false;
		if (option == ATTACK) {
			state = CHOOSINGATTACK;
		} else if (option == ITEM) {
			instance_create_depth(0, 0, -3, obj_inventory);
			state = CHOOSINGITEM;	
		}
	} else if (obj_master.confirm_pressed) {
		audio_play_sound(snd_heavyconfirm, 0, false);
		actionlist[# SOURCE, actionstep] = actionstep;//this unit's position in the turn order
		if (itemoption == 0) {//if the itemoption is 0, meaning we're not selecting an option
			actionlist[# MOVE, actionstep] = battleblock[# attackoption, actionstep];//the moveid of this move
			choosingtoattackup = false;//causes the state to go into standby, and increases actionstep
		} else {//if  the itemoption is not zero, meaning we're selecting an option, then...
			actionlist[# MOVE, actionstep] = itemoption;//the moveid of this move
			itemoption = 0;
			choosingtoitemup = false;
		}
		actionlist[# TARGET, actionstep] = targetoption;//the target's position in the turn order
		attacktotargetup = false;
	}
	
} else if (state == EXECUTING && executing) {//if the state is EXECUTING, and the execution variable is turned on...
	standbytochoosingup = false;//hide the battle menu for a more cinematic experience
	executing = false;//stop executing until execution is set to true again by a move
	//actual damage/animations/etc. is handled in this script
	scr_execute_action(actionlist[# SOURCE, executestep], actionlist[# MOVE, executestep], actionlist[# TARGET, executestep]);
	
} else if (state == CHOOSINGITEM) {//if you're selecting an item to use, use it only if it's able to be used here
	if (obj_master.cancel_pressed) {
		audio_play_sound(snd_cancel, 0, false);
		choosingtoitemup = false;
	} else if (obj_master.confirm_pressed && 
		   (obj_master.inventory[# CATEGORY, obj_inventory.selection] == "Consumable" 
			|| obj_master.inventory[# CATEGORY, obj_inventory.selection] == "Healing")) {
		audio_play_sound(snd_confirm, 0, false);
		attacktotargetup = true;
		state = CHOOSINGTARGET;
	}
	
} else if (state == WINNING) {//if all the foes are indisposed
	if (!wonmessage) {//run this only once, since wonmessage is set to true in here
		attacktotargetup = false;
		choosingtoitemup = false;
		choosingtotacticsup = false;
		choosingtoattackup = false;
		audio_sound_gain(snd_battle, 0, 3000);
		audio_sound_gain(snd_victory_intro, 1, 0);
		audio_sound_gain(snd_victory_loop, 1, 0);
		with (instance_create_depth(0, 0, 0, obj_jukebox)) {
			intro = snd_victory_intro;
			sound = snd_victory_loop;
			looping = true;
		}
		wonmessage = true;
		if (obj_master.navigator != -1) {
			if (obj_master.special == 0) {
				instance_destroy(obj_instant_text);
			}
			scr_instant(scr_fetch_portrait(obj_master.navigator, obj_master.dreaming, 1), scr_fetch_navitalk(obj_master.navigator, WON));
		}
	} else if (wonmessage && wintime <= 1) {//if this was a special fight--so the special variable != 0--make the post-battle transition take longer
		wintime += obj_master.special == 0 ? 0.004 : 0.003;
	} else if (!instance_exists(obj_experience)) {//show the experience screen
		with (instance_create_depth(0, 0, 0, obj_dummy)) {
			fullscreen = true;
			sprite_index = spr_black;
		}
		instance_create_depth(0, 0, 0, obj_experience);
	}
}
