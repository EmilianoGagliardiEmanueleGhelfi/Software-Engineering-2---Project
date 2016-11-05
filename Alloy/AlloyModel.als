sig Car{
	connectedPlug: lone Plug,
	status: one CarStatus,	
	carPosition: one Position, 
	//capacity: Int,
	//batteryLevel: Int
}{
	this in User.reservedCar iff status in Reserved
	this in User.inUseCar iff status in Busy
	this in SafeArea.carsInSafeArea iff status!=Busy
	// car can be plugged only if it's in a charging area
	#connectedPlug = 1 implies (connectedPlug.~plugs).safeAreaPosition = carPosition 
	#connectedPlug = 1 implies not status in Busy 
}



sig Position{
}


//CAR STATUS

abstract sig CarStatus{}

one sig Reserved extends CarStatus{}

one sig Available extends CarStatus{}

one sig Busy extends CarStatus{}

one sig UnderMaintainance extends CarStatus {}

sig Date{}


/*


sig Ride{
	cost: Int,
	duration: Int,
	passengers: Int
}
// passengers < capacity


sig Guest extends Person{}
*/

// PERSON

abstract sig Person{}

sig User extends Person{
	//usedCars: set Car,
	userPosition: one Position,
	reservedCar: lone Car,
	inUseCar: lone Car,
	canUnlock: lone Car
}
{
	#reservedCar = 1 implies #inUseCar=0
	#inUseCar = 1 implies #reservedCar = 0
	// se macchine in uso hanno la stessa posizione
	#inUseCar = 1 implies userPosition = inUseCar.carPosition
}

sig SuspendedUser extends User{}
{
	#reservedCar = 0
	#inUseCar = 0
}

sig Admin extends Person{}

// OPERATOR
sig CompetenceArea{
	positions : set Position
}{
	// tutte competence appartengono ad op
	this in Operator.competenceArea
	#positions >0
}

sig Operator extends Person{
	competenceArea: one CompetenceArea,
	carInMaintainance: set Car
}
{
	all c : Car | c in carInMaintainance iff c.status = UnderMaintainance 
	all c : Car | c in carInMaintainance implies c.carPosition in competenceArea.positions
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



// CHARGING AREA
sig Plug{
	carConnected: lone Car
}
{
	all p:Plug | p in ChargingArea.plugs
}

sig ChargingArea extends SafeArea{
	plugs: set Plug,

}
{
	#plugs>0
	#plugs<=capacity
}
//prese <= capacità

// a plug is only in a one charging area
fact plugUnique{
	no disj c1,c2: ChargingArea | some p:Plug | p in c1.plugs and p in c2.plugs
}

// connectedPlug is the same of caConnected transposed
fact {
		connectedPlug = ~carConnected
}

fact {
		all c : Car, safeArea: SafeArea | c in safeArea.carsInSafeArea iff c.carPosition = safeArea.safeAreaPosition 
}

// non esistono safe area con stessa pos
fact {
	no disj s1,s2: SafeArea | s1.safeAreaPosition = s2.safeAreaPosition
}


// car di ut diversi reserved e in uso diverse
fact {
	no disj u1,u2:User | u1.inUseCar = u2.inUseCar and #u1.inUseCar=1
	no disj u1,u2:User | u1.reservedCar=u2.reservedCar and #u1.reservedCar = 1
	
}



fact {
	// partizione 
	all disj c1,c2: CompetenceArea | c1.positions & c2.positions = none
	// tutte posizioni sono in competence 
	all p:Position | p in CompetenceArea.positions 
}

// operator diversi hanno competence diverse
fact{
	all disj o1,o2:Operator | o1.competenceArea != o2.competenceArea
}

//Can unlock
fact{
	// can unlock only if reserved and same position
	canUnlock = (reservedCar & userPosition.~carPosition)
}



pred show(){}

assert canUnlockAssert{
	all u : User, c : Car | (u.userPosition = c.carPosition and u.reservedCar = c) implies u.canUnlock = c
	
}


run show for 3 but 4 Operator

check canUnlockAssert


