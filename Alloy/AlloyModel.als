
/*------------------------------UTIL---------------------------------*/
sig Date{}
sig Position{}

/*----------------------------PERSON--------------------------------*/
abstract sig Person{}

sig User extends Person{
	userPosition: one Position,
	reservedCar: lone Car,
	inUseCar: lone Car,
	canUnlock: lone Car
}
{
	#reservedCar = 1 implies #inUseCar=0
	#inUseCar = 1 implies #reservedCar = 0
}
// Different users have different cars in use and different reserved cars
fact {
	no disj u1,u2:User | u1.inUseCar = u2.inUseCar and #u1.inUseCar=1
	no disj u1,u2:User | u1.reservedCar=u2.reservedCar and #u1.reservedCar = 1
	
}
// A user can unlock a car if is near that, and has reserved that or is in a pause ride
fact{
	// can unlock only if reserved and same position
	canUnlock = (reservedCar + (rideStatus.Pause).rideUser <: inUseCar) & userPosition.~carPosition
}

sig SuspendedUser extends User{}
{
	#reservedCar = 0
	#inUseCar = 0
}

sig Admin extends Person{}

sig Operator extends Person{
	competenceArea: one CompetenceArea,
	carInMaintenance: set Car
}
{
	all c : Car | c in carInMaintenance iff c.status = UnderMaintenance 
	all c : Car | c in carInMaintenance implies c.carPosition in competenceArea.positions
}
// Different operators have disjoint competence area
fact{
	all disj o1,o2:Operator | o1.competenceArea != o2.competenceArea
}

/*------------------------------CAR---------------------------------*/
sig Car{
	connectedPlug: lone Plug,
	status: one CarStatus,	
	carPosition: one Position, 
}{
	this in User.reservedCar iff status in Reserved
	this in User.inUseCar iff status in Busy
	//this in SafeArea.carsInSafeArea iff status!=Busy
	status = Busy implies this not in SafeArea.carsInSafeArea
	// car can be plugged only if it's in a charging area
	#connectedPlug = 1 implies (connectedPlug.~plugs).safeAreaPosition = carPosition 
	#connectedPlug = 1 implies not status in Busy 
}
// If a car is in a safe area, they have the same position
fact {
	all c : Car, safeArea: SafeArea | c in safeArea.carsInSafeArea iff c.carPosition = safeArea.safeAreaPosition 
}
/*---------------------------CAR STATUS------------------------------*/
abstract sig CarStatus{}

one sig Reserved extends CarStatus{}

one sig Available extends CarStatus{}

one sig Busy extends CarStatus{}

one sig UnderMaintenance extends CarStatus {}

/*-------------------------------AREA-------------------------------*/

sig CompetenceArea{
	positions : set Position
}{
	// each competence area belongs to an operator
	this in Operator.competenceArea
	#positions >0
}
// CompetenceAreas.positions induces a partition on Position
fact {
	// Empty intersection
	all disj c1,c2: CompetenceArea | c1.positions & c2.positions = none
	// There doesn't exist position that are not in a competence area
	all p:Position | p in CompetenceArea.positions 
}

sig SafeArea{
	capacity: Int,
	carsInSafeArea : set Car,
	safeAreaPosition : one Position
}
{
	capacity>0
	#carsInSafeArea <= capacity
}
// There doesn't exist different safe areas with same position
fact {
	no disj s1,s2: SafeArea | s1.safeAreaPosition = s2.safeAreaPosition
}

sig ChargingArea extends SafeArea{
	plugs: set Plug,

}
{
	#plugs>0
	#plugs<=capacity
}

sig Plug{
	carConnected: lone Car
}
{
	all p:Plug | p in ChargingArea.plugs
}
// a plug is only in a one charging area
fact plugUnique{
	no disj c1,c2: ChargingArea | some p:Plug | p in c1.plugs and p in c2.plugs
}
// connectedPlug is the same of caConnected transposed
fact {
	connectedPlug = ~carConnected
}

/*-------------------------------RIDE------------------------------------*/
sig Ride{
	rideCar: Car,
	rideUser: User,
	rideStatus: RideStatus
}
{
	// If the status of the ride is Run, user and his used car have the same position
	rideStatus in Run implies rideCar.carPosition = rideUser.userPosition
}
// Set user and car in Ride like in the relation User.inUseCar
fact {
	(~rideUser).rideCar = inUseCar
	#Ride = #inUseCar
}

/*------------------------------RIDE STATUS------------------------------*/
abstract sig RideStatus{}
one sig Run extends RideStatus{}
one sig Pause extends RideStatus{}

/*--------------------------------PREDICATES-----------------------------*/
pred show{} //dummy predicate

/*------------------DINAMIC MODELING PREDICATES-------------------------*/

//From available to reserved
pred carFromAvailableToReserved [u: User, c: Car, u': User, c': Car] {
	//initial conditions for reserving
	not u in SuspendedUser
	#u.reservedCar = 0
	#u.inUseCar = 0
	c.status in Available
	//informations non involved in reservation don't change
	c'.connectedPlug = c.connectedPlug
	c'.carPosition = c.carPosition
	u'.userPosition = u.userPosition
	u'.inUseCar = u.inUseCar
	//final conditions
	c'.status in Reserved
	u'.reservedCar = c'
}

//From reserved to busy
pred carFromReservedToInUse [u: User, c: Car, u': User, c': Car] {
	//initial conditions
	u.reservedCar = c
	#u.inUseCar = 0
	u.canUnlock = c
	//final contition
	#c'.connectedPlug = 0
	u'.inUseCar = c'
	c'.status in Busy
	all r: Ride | r.rideUser = u' implies r.rideStatus in Run
}

//From available to under maintenance
pred carFromAvailableToUnderMaintenance [c: Car, c': Car] {
	//initial conditions
	c.status in Available
	//not involved informations don't change
	c'.connectedPlug = c.connectedPlug
	c'.carPosition = c.carPosition
	//final condition
	c'.status in UnderMaintenance
}

// From busy to available
pred carFromBusyToAvailable [c: Car, c': Car, u:User, u':User]{
	// initial condition
	c.status in Busy
	c in u.inUseCar
	// not involved information don't change
	u'.userPosition = u.userPosition
	c'.carPosition = c.carPosition
	not u' in SuspendedUser
	#u'.inUseCar = 0
	// final condition
	c'.status in Available
}

//Plugging a car
pred pluggingCar [c: Car, c': Car, u': User] { //the user is required to ensure that car.~reservedCar does not change
	//initial condition
	#c.connectedPlug = 0
	c in ChargingArea.carsInSafeArea
	//not involved informations don't change
	c'.carPosition = c.carPosition
	c'.status = c.status
	c in User.reservedCar implies (all u: User | u.reservedCar = c implies (
									   u'.userPosition = u.userPosition and
									   u'.inUseCar = u.inUseCar and
									   u'.reservedCar = c' and
									   u' not in SuspendedUser))
	//final condition
	#c'.connectedPlug = 1
}

//Stopping a run (to pause status)
pred rideFromRunToPause [r: Ride, r': Ride, u: User, u': User, c: Car, c': Car] {
	//initial condition
	r.rideStatus in Run
	r.rideUser = u
	r.rideCar = c
	//informations that do not change
	r'.rideCar = c'
	r'.rideUser = u'
	c'.connectedPlug = c.connectedPlug
	c'.status = c.status
	c'.carPosition = c.carPosition
	u'.userPosition = u.userPosition
	//final condition
	r'.rideStatus in Pause
}

// Restart a run
pred rideFromPauseToRun [r: Ride, r': Ride, u: User, u': User, c: Car, c': Car] {
	//initial condition
	r.rideStatus in Pause
	r.rideUser = u
	r.rideCar = c
	//informations that do not change
	r'.rideCar = c'
	r'.rideUser = u'
	c'.connectedPlug = c.connectedPlug
	c'.status = c.status
	c'.carPosition = c.carPosition
	u'.userPosition = u.userPosition
	//final condition
	r'.rideStatus in Run
}
/*------------------------------ASSERTIONS-----------------------------------*/

// RESERVATION
// Two different user can't reserve the same car
assert noTwoUserSameReservedCar {
	no c: Car, disj u1,u2: User | c in u1.reservedCar and c in u2.reservedCar
}
// A user can't reserve more than one car
assert noUserTwoReservedCar {
	no u: User | #u.reservedCar > 1
}

// If it exists a user that has reserved a car, that car status is reserved
assert reservedStatus {
	all c: Car | (some u: User | u.reservedCar = c) implies c.status in Reserved
}

// A suspended user can't reserve a car
assert noReservationBySususpended {
	no c: Car | (some u: SuspendedUser | u.reservedCar = c)
}

// A suspended user can't use a car
assert noUsedBySususpended {
	no c: Car | (some u: SuspendedUser | u.inUseCar = c)
}

// UNLOCK
// Users can unlock cars iff the car is in their paused ride, or if they have reserved it, and they are near it
assert canUnlockAssert {
	all u : User, c : Car | (u.userPosition = c.carPosition and u.reservedCar = c) implies u.canUnlock = c
	all r: Ride, u: User, c: Car | (r.rideStatus = Pause and r.rideUser = u and u.userPosition = c.carPosition and r.rideCar = c) implies u.canUnlock = c        
}

// UTILIZATION OF CARS
// A user can't use two machine
assert noUserUseTwoCar {
	no u: User | #u.inUseCar > 1
}

// A user can't use a car reserved by another user
assert noUseOfReservedCar {
	no u: User, c: Car | u.reservedCar = c and c.status in Busy
}

//A user can't use a car that is under maintenance
assert noUseCarInMaintenance {
	no u: User, c: Car | u.inUseCar = c and c.status in UnderMaintenance
}

// If exist a user that is using a car, that car status is Busy
assert busyStatus {
	all c: Car | (some u: User | u.inUseCar = c) implies c.status in Busy
}

// A car is busy iff exists a ride with that car
assert busyCarInARIde {
	all c: Car | c.status = Busy iff (some r: Ride | r.rideCar = c)
}

//MAINTENANCE OF CARS
// If a car is under maintenance, there exists an operator that is repairing it
assert inMaintenanceImpliesExistOperator{
	all c: Car | (c.status in UnderMaintenance) implies (some o: Operator | c in o.carInMaintenance)
}

/*--------------------------------------------------------------------------*/

run carFromAvailableToReserved
run carFromReservedToInUse
run pluggingCar
run carFromAvailableToUnderMaintenance
run carFromBusyToAvailable
run rideFromRunToPause
run rideFromPauseToRun
run show
check canUnlockAssert
check inMaintenanceImpliesExistOperator
check busyCarInARIde
check noTwoUserSameReservedCar
check noUserTwoReservedCar
check reservedStatus
check noReservationBySususpended
check noUsedBySususpended
check noUserUseTwoCar
check noUseOfReservedCar
check busyStatus




