#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_perks;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
		/* caso não funcione o código, use os scripts a baixo
		if the code doesn't work, use the scripts below
	replacefunc(scripts\zm\zm_prison\PHD_FLOPPER\divetonuke_perk::divetonuke_level, scripts\zm\zm_prison\bsm_prison_perk_phd::divetonuke_level);
	scripts\zm\zm_prison\PHD_FLOPPER\divetonuke_perk::divetonuke_level();
	*/

	thread divetonuke_level();
}

divetonuke_level()
{
	maps\mp\zombies\_zm_perks::register_perk_basic_info( "specialty_flakjacket", "divetonuke", 2000, &"ZOMBIE_PERK_DIVETONUKE", "zombie_perk_bottle_jugg" ); //Caso coloque esse código para rodar em um ff custom com itens do Phd troque zombie_perk_bottle_jugg por zombie_perk_bottle_nuke
	maps\mp\zombies\_zm_perks::register_perk_machine( "specialty_flakjacket", ::divetonuke_perk_machine_setup, ::divetonuke_perk_machine_think ); //Case you put this code to run in a custom ff with Phd items change zombie_perk_bottle_jugg for zombie_perk_bottle_nuke
}

init_divetonuke() //checked matches cerberus output
{
	level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
	set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
	set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
	set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );
}

divetonuke_explode( attacker, origin )
{
	radius = level.zombie_vars[ "zombie_perk_divetonuke_radius" ];
	min_damage = level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ];
	max_damage = level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ];
	radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	attacker playsound( "zmb_phdflop_explo" );
	fx = loadfx("explosions/fx_default_explosion");
	playfx( fx, origin );
}

divetonuke_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision ) //checked matches cerberus output
{
	use_trigger.script_sound = "mus_perks_phd_jingle";
	use_trigger.script_string = "divetonuke_perk";
	use_trigger.script_label = "mus_perks_phd_sting";
	use_trigger.target = "vending_divetonuke";
	perk_machine.script_string = "divetonuke_perk";
	perk_machine.targetname = "vending_divetonuke";
	if ( isDefined( bump_trigger ) )
	{
		bump_trigger.script_string = "divetonuke_perk";
	}
}

divetonuke_perk_machine_think() //checked changed to match cerberus output
{
	init_divetonuke();
	while ( 1 )
	{
		machine = getentarray( "vending_divetonuke", "targetname" );
		machine_triggers = getentarray( "vending_divetonuke", "target" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "divetonuke" ].off_model );
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level thread do_initial_power_off_callback( machine, "divetonuke" );
		level waittill( "divetonuke_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "divetonuke" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "divetonuke_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_flakjacket_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "divetonuke" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "divetonuke" ].power_on_callback );
		}
		level waittill( "divetonuke_off" );
		if ( isDefined( level.machine_assets[ "divetonuke" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "divetonuke" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}