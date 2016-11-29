Introduction
============

Description of the given problem
--------------------------------

The purpose of this document is to support the development of
PowerEnJoy, a software that manages a car sharing service for electric
cars. The aim of this software is to make simple and quick the
reservation of cars. So the system should provide users with real time
information about availability of cars, their status and their
positions. Users, after the reservation, can directly get their car in
pre-defined parking areas.\
The service will be accessible only to registered users, giving some
personal information and data needed to the payment. The price of the
ride is computed with a fixed amount of money per minute, displayed by
the car, and finally charged. To avoid useless reservation, where a user
doesn’t pick up the car, the reservation expires after a fixed time, the
car returns available, and the user is charged with a fee. Cars must be
locked in the safe areas, and only users that have made the reservation
can unlock them.\
The software has to provide also management functionality for
administrators and operators in order to ensure a simple managing of the
system.

Glossary and abbreviations
--------------------------

-   Virtuous behaviour:

    -   Behaviour that makes simple the maintance of the cars and
        reservation areas.

    -   Behaviour helps to reduce the traffic impact.

    -   To park in defined safe areas.

-   Car status, that can assume the following meanings:

    -   Free: it can be reserved.

    -   Reserved: has alreasy been reserved.

    -   Busy: a user is driving the car.

    -   Under maintenance: an operator is fixing some car problem.

    -   In charge: the car is plugged in a charging station.

-   Car information: technical information about car, useful
    for mantainance.

-   Safe area: special, pre-defined parking area where cars can be
    parked. It can be also a charging area.

-   Charging area: an area where cars can be recharged. It is always a
    Safe Area.

-   Malfunction: the car has some problems that can be repaired by
    an operator.

-   Damage: it’s like a malfunction but caused by the user.

-   Ride: when a user unlocks the car and then use it to go from a place
    to another.

-   Ride Status:

    -   Active: the user is driving the car.

    -   Paused: the user has paused the ride and so he can maintain the
        reservation paying a certain amount of money per minute.

-   Payment method: a method of payment the user can use in order to pay
    Power EnJoy services.

-   API: Application Programming Interfaces, a set of methods accessible
    from an external system.

Actors
------

These are the people that will be involved in the use cases of the
software to be:

-   GUEST: a person that isn’t registered to the system.

-   USER: a person that has already registered to the system.

-   OPERATOR: an employee of the company that takes maintenance of cars
    and charging area.

-   ADMIN: a person that can manage system status with
    privileged actions.

Goals
-----

The objectives of the software to be are the following:

-   <span>\[</span>G1<span>\]</span> Users should be able to reserve a
    car and use it.

    -   <span>\[</span>G1.1<span>\]</span> Users should be able to
        reserve a car.

    -   <span>\[</span>G1.2<span>\]</span> Users should be able to
        unlock reseved car when they are close to it.

    -   <span>\[</span>G1.3<span>\]</span> Users should be aware of how
        much they are going to pay during the ride.

    -   <span>\[</span>G1.4<span>\]</span> If reserved car pass under
        maintenance, the User that made the reservation must be notified
        and the reservation should be deleted.

    -   <span>\[</span>G1.5<span>\]</span> User should be able to set
        Pause status during a ride.

    -   <span>\[</span>G1.6<span>\]</span> User should be able to
        restart a paused ride.

-   <span>\[</span>G2<span>\]</span> The reservation of two (or more)
    cars at a time must be forbidden.

-   <span>\[</span>G3<span>\]</span> Users and Guests must be able to
    search cars.

    -   <span>\[</span>G3.1<span>\]</span> Users and Guests should be
        able to search cars near his position.

    -   <span>\[</span>G3.2<span>\]</span> Users and Guests should be
        able to search cars near a selected position.

-   <span>\[</span>G4<span>\]</span> Induce users to keep a
    virtuous behaviour.

    -   <span>\[</span>G4.1<span>\]</span> A discount of 10% should be
        applied to rides with at least two passengers.

    -   <span>\[</span>G4.2<span>\]</span> If a car is left with no more
        than 50% battery empty, a discount of 20% should be applied to
        the last ride.

    -   <span>\[</span>G4.3<span>\]</span> If a car is left at more than
        3 km from the nearest charging area, the system should charges
        30% more on the last ride.

    -   <span>\[</span>G4.4<span>\]</span> If a car is left with more
        than 80% battery empty, the system should charges 30% more on
        the last ride.

    -   <span>\[</span>G4.5<span>\]</span> If a car is left in a
        charging area and the user plugs the car into the power grid, a
        discount of 30% should be applied to the last ride.

    -   <span>\[</span>G4.6<span>\]</span> If a car is not picked up
        within one hour from the reservation, the user should pay a fee
        of 1 EUR.

    -   <span>\[</span>G4.7<span>\]</span> If a payment fails because of
        insufficient money availability of the user, the user should be
        suspended from the service until the payment is done.

    -   <span>\[</span>G4.8<span>\]</span> If a user parks in an area
        that is not a safe area, the user should pay a fee.

-   <span>\[</span>G5<span>\]</span> Users have to pay an amount of
    money based on the ride’s duration.

-   <span>\[</span>G6<span>\]</span> Guarantee a ready maintenance
    of cars.

    -   <span>\[</span>G6.1<span>\]</span> Operators should be able to
        do car mantainance, knowing their position and status.

    -   <span>\[</span>G6.2<span>\]</span> Users should be able to
        comunicate to the system cars damages and malfunctions.

-   <span>\[</span>G7<span>\]</span> Admins must be able to manage
    the system.

    -   <span>\[</span>G7.1<span>\]</span> Admins must be able to manage
        safe areas.

    -   <span>\[</span>G7.2<span>\]</span> Admins must be able to
        manage operators.

Stakeholders identification
---------------------------

The principal stakeholder is the customer, a company that offers a car
sharing service and needs a platform to manage it and make it easy for
possible users. Other involved people are the employees of the company,
who will work with the software. Evidently also the users of the
application are stakeholders.\
In the end, related to more technical purposes, other possible
developers that will consult the software documentation are
stakeholders.

Document overview
-----------------

The document is structured in the following four parts:

-   Introduction: this is the introduction of the document, where is
    given a general view of the problem, and are exposed the fundaental
    purposes of the software to be developed

-   Overall description: it describes the assumptions made on the domain
    in wich the software will work, and its dependecies with the used
    interfaces

-   Requirements: it describes the functional and non functional
    requirements, and their relation with the goals and the domain
    assumptions

-   Scenario: it describes some possible situations that involve the
    system

-   UML model

-   Alloy modeling


