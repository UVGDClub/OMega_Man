class_name StateEntity2D extends CharacterBody2D

#shared resources
const ITEM_PICKUP = preload("res://General/objects/item_pickup.tscn")

#shared variables

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ignore_gravity = false;

#region STATE MACHINE BACK END
#STATE DRIVERS
var state = func(): return
var onEnter = func(): return
var main = func(): return
var onLeave = func(): return
var exitConditions = func(): return
var state_log = true;

#working variables
var stateNext = func(): return
var stateChanged: bool = false
var stateTime: int = 0
var _stateID: String = "NULL";
var _statePrevID: String = "NULL";

## Runs the onEnter Lambda exactly once 
func state_run_onEnter_once(stateTimeNew):
	if(_stateID != _statePrevID): #FIXME this prevents the same state from executing again
		stateChanged = true
		_statePrevID = _stateID;
		stateTime = stateTimeNew
		onEnter.call()
		if(state_log): print("--STATE--: "+str(self.name)+"--"+_stateID);

## Runs the onLeave Lambda only when the stateTime reaches 0, or the state force exits.		
func state_run_onLeave_whenStateDone():
	if(stateTime == -1): return
	if(stateChanged): return
	if(stateTime == 0):
		onLeave.call()
		_statePrevID = _stateID;
		state = stateNext;
		stateChanged = true;
		state.call() # update the enter, main, leave and exit funcs
		#state_onEnter(stateTime) # force onEnter changes?
	else:
		stateTime -= 1;

## Constantly checks the defined exit conditions of the current state.
func state_check_ExitConditions():
	if(!stateChanged): 
		exitConditions.call()
		
## Changes the state immediately to the provided state
func state_forceExit(stateNextOverride):
	if(stateNextOverride == state): return #FIXME this prevents the state going back to itself.
	onLeave.call();
	_statePrevID = _stateID;
	state = stateNextOverride;
	stateChanged = true;
	state.call(); #update enter, main, leave and exit funcs
	state_run_onEnter_once(stateTime) # force onEnter changes

## Reruns the state	
func state_forceRestart():
	state.call(); #must do this to update statetime... pretty lame because nothing else really changes
	onEnter.call();

## Runs the state "Sandwich"
func stateDriver():
	state_run_onEnter_once(stateTime)
	main.call() 
	state_check_ExitConditions() #NOTE doesnt run if stateTime == 0
	state_run_onLeave_whenStateDone()
	stateChanged = false #NOTE this is the only occurance where its changed to false

## Itializes the state machine with the first state
func state_initialize(firstState):
	state = firstState;
	state.call();

#endregion
