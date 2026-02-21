## damage types
- physical
	- sharp
		- penetrating
		- slicing
	- blunt
		- kinetic
		- concussive
- fire
- majiя (magic)

## hit calculation
damage scales with elements of physics:
- heft
- severity
- durity; adds resistance pen for sharp attacks
- counterbalance

- penetrating damage is mostly based on severity, and slightly weight. weight slows the attack speed. counterbalance might affect attack speed
- slicing damage is based on severity and counterbalance. counterbalance also increases attack speed
- kinetic damage is based on heft and counterbalance, and durity
- concussive damage is based way more on heft and counterbalance

though these factors can also be overridden by the weapon class type

fire and majiя damage have a different system and just directly do damage minus their direct resistance stat

## attacks / movesets
- programmed in a syntax based on what kind of attack and what kind of timing; it's a combo that essentially loops
	- eg [1, 0, 0, 1, 0, 2, 0] representing game ticks of it doing damage and which attack mode used
	- some can have multiple combos that are just randomly selected
- different weapon types have a pre-set moveset, generally, unless said otherwise
	- i.e. staves have a light attack and a heavy attack that has different modifiers on the ratio of damage types
	- attack types are also indexed for attack pattern storage

## item modifiers
material mods:
- condition
	- ratio from 0 to 1
- alloy (each affects the physical stats)
	- bell-metal
	- bronze
	- slag iron
	- bog iron (phosphoric)
	- grey iron
	- cementite
	- wootz
- reach

magical mods:
- rare
- we will think of these later

## other combat flow
speed control / range control
- weight and range affect delay before first hit (combo loops also might have a wind up delay)
- each combat will start under the same circumstances for now

## armors / defenses
have a similar class system with defense spreads. won't mention it now
- tensile
- shear
- fire resistance
- majiя resistance

these ultimately determine resistance to the damage types but it's all obfuscated
armors will also have classes to make it easy to generate them just with different base stats

## interaction with hitpoints
main HP bars are mettle and blood. total armor stat has a mettle = all defense ratings types combined

physical attacks against most things will cause bleeding. bleeding is = X% of the damage per tick.
sharp vs blunt do internal vs external bleeding. internal can be stopped but is also exacerbated by each additional attack you do. 

when you reach a certain level of blood you can have reduced stats