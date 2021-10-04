/// @description Insert moves into the event log

if (obj_master.leftoption_pressed) {
	transpeed /= 2;
} else if (obj_master.rightoption_pressed) {
	transpeed *= 2;	
}

if (standbytochoosingup) {
	standbytochoosing = min(standbytochoosing + 0.1 * transpeed, 1);	
} else {
	standbytochoosing = max(standbytochoosing - 0.1 * transpeed, 0);	
}

if (choosingtoattackup) {
	choosingtoattack = min(choosingtoattack + 0.1 * transpeed, 1);	
} else {
	var becamezero = choosingtoattack != 0 && max(choosingtoattack - 0.1 * transpeed, 0) == 0;//if choosingtoattack just hit zero
	choosingtoattack = max(choosingtoattack - 0.1 * transpeed, 0);
	if (becamezero) {
		if (state == CHOOSINGTARGET) {//if you press confirm on choosingtarget, this will happen
			actionstep++;
			state = STANDBY;
		} else if (state == CHOOSINGATTACK) {//if you press cancel on choosingattack, this will happen
			state = CHOOSING;
		}
	}
}

if (attacktotargetup) {
	attacktotarget = min(attacktotarget + 0.1 * transpeed, 1);	
} else {
	attacktotarget = max(attacktotarget - 0.1 * transpeed, 0);	
}

if (choosingtoitemup) {
	choosingtoitem = min(choosingtoitem + 0.1 * transpeed, 1);	
} else {
	var becamezero = choosingtoitem != 0 && max(choosingtoitem - 0.1 * transpeed, 0) == 0;//if choosingtoattack just hit zero
	choosingtoitem = max(choosingtoitem - 0.1 * transpeed, 0);	
	if (becamezero) {
		if (state == CHOOSINGTARGET) {//if you press confirm on choosingtarget, this will happen
			actionstep++;
			state = STANDBY;
		} else if (state == CHOOSINGITEM) {//if you press cancel on choosingitem, this will happen
			state = CHOOSING;
		}
	}
}

if (choosingtotacticsup) {
	choosingtotactics = min(choosingtotactics + 0.1 * transpeed, 1);	
} else {
	choosingtotactics = max(choosingtotactics - 0.1 * transpeed, 0);	
}

for (var i = 0; i < ds_grid_height(battleblock); i++) {//iterate through all battlers
	if (battleblock[# ID, i] >= ASTER) {//if this is a hero.
		if (actionstep == i && state < EXECUTING) {
			battleblock[# TRANSITION, i] = min(battleblock[# TRANSITION, i] + 0.09 * transpeed, 1);	
		} else {
			battleblock[# TRANSITION, i] = max(battleblock[# TRANSITION, i] - 0.1 * transpeed, 0);	
		}
	}
}

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
			show_message("Death is not a hunter unbeknownst to its prey.\n...\nJust kidding. I'll be honest, you aren't meant to lose here. If you did--good job! You get a cookie. Anyway, I don't actually have a proper \"losing\" behavior programmed, so just head on back to the main menu, okay?");
			room_goto(rm_main_screen);//go to the main menu
			exit;//need to include this so the loop doesn't continue after the deletion of the instance. For some reason.
		}
	}
}

if (state == EXECUTING) {
	executingvalue = min(executingvalue + 0.1 * transpeed, 1);
} else {
	executingvalue = max(executingvalue - 0.1 * transpeed, 0);
}

scr_fetch_special_dialog(obj_master.special, state);

//STATES BELOW. TRANSITIONS ABOVE

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
		if (scanning) {
			var navran = floor(obj_master.statblock[# LEADERSHIP, obj_master.navigator] / 10);
			
			for (var i = 0; i < navran; i++) {
				var rand = irandom(11) + 1;
				if (!obj_master.discoveredstats[# selectedscan, rand]) {
					scr_instant(scr_fetch_portrait(obj_master.navigator, obj_master.dreaming, 1), scr_fetch_navitalk(obj_master.navigator, YESSCAN));
					obj_master.discoveredstats[# selectedscan, rand] = true;
				}
			}
			scr_instant(scr_fetch_portrait(obj_master.navigator, obj_master.dreaming, 0.1), scr_fetch_navitalk(obj_master.navigator, NOSCAN));//won't happen if Yessscan happened even once.		
		}
		state = EXECUTING;
		executing = true;
		actionstep = 0;
		turn++;//keeps track of the number of turns that have elapsed. Starts at 1 on the first turn.
	}
} else if (state == CHOOSING) {//if in the choosing state
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
			instance_create_depth(0, 0, -3, obj_inventory);
			state = CHOOSINGITEM;
			choosingtoitemup = true;
		} else if (option == TACTICS) {
			instance_create_depth(0, 0, -3, obj_battletactics);
			state = CHOOSINGTACTICS;
			choosingtotacticsup = true;
		}
	} else if (obj_master.cancel_pressed && actionstep != firsthero) {
		audio_play_sound(snd_cancel, 0, false);
		actionstep--;//move back one step, canceling the last action.
		while (battleblock[# ID, actionstep] < ASTER) {//if the previous step was not a player's choice...
			actionstep--;//go back another step
		}
	}
} else if (state == CHOOSINGATTACK) {
	if (instance_exists(battleblock[# OBJID, actionstep])) {//if the instance currently being executed exists--
		scr_scrolloptions("attackoption", 2, 4, battleblock[# OBJID, actionstep].lastx, battleblock[# OBJID, actionstep].lasty,//scroll through the two by four menu, starting the cursor where it was last chosen
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
} else if (state == CHOOSINGTARGET) {
	var xmodifier = 0//how offset the targeting for the previous target ought to be
	var ymodifier = 0;//how offset the targeting for the previous target ought to be
	var nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
	if (obj_master.left_pressed) {//if you press left
		while(nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			xmodifier += -100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.right_pressed) {//if you press right
		while(nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			xmodifier += 100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.up_pressed) {//if you press up, look up and slightly to the right for your next target
		while(nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
			ymodifier += -100;
			nearest = instance_nearest(battleblock[# OBJID, targetoption].x + xmodifier, battleblock[# OBJID, targetoption].y + ymodifier, obj_battler);
		}
	} else if (obj_master.down_pressed) {//if you press down, look down and slightly to the left for your next target
		while(nearest == battleblock[# OBJID, targetoption]) {//as long as the new targetoption is the same as the last one
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
		} else {//if  the itemoption is not zero, then...
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
	scr_execute_action(actionlist[# SOURCE, executestep], actionlist[# MOVE, executestep], actionlist[# TARGET, executestep]);
} else if (state == CHOOSINGITEM) {
	if (obj_master.cancel_pressed) {
		audio_play_sound(snd_cancel, 0, false);
		choosingtoitemup = false;
	} else if (obj_master.confirm_pressed && (obj_master.inventory[# CATEGORY, obj_inventory.selection] == "Consumable" || obj_master.inventory[# CATEGORY, obj_inventory.selection] == "Healing")) {
		audio_play_sound(snd_confirm, 0, false);
		attacktotargetup = true;
		state = CHOOSINGTARGET;
	}
} else if (state == WINNING) {
	if (!wonmessage) {
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
	} else if (wonmessage && wintime <= 1) {
		wintime += obj_master.special == 0 ? 0.004 : 0.003;
	} else if (!instance_exists(obj_experience)) {
		with (instance_create_depth(0, 0, 0, obj_dummy)) {
			fullscreen = true;
			sprite_index = spr_black;
		}
		instance_create_depth(0, 0, 0, obj_experience);
	}
}
