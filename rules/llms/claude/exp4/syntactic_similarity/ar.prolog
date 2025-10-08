/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    not holdsAt(disappeared(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    not holdsAt(disappeared(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    not holdsAt(disappeared(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    not holdsAt(disappeared(Id)=true, T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

initiatedAt(disappeared(Id)=true, T) :-
    happensAt(disappear(Id), T).

terminatedAt(disappeared(Id)=true, T) :-
    happensAt(appear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    holdsAt(person(Person)=true, T),
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, LeavingObjectThreshold)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, Ic),
    intersect_all([I1, I2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, Ic),
    holdsFor(abrupt(Person1)=true, Ia1),
    holdsFor(abrupt(Person2)=true, Ia2),
    union_all([Ia1, Ia2], Iabrupt),
    holdsFor(inactive(Person1)=true, Ii1),
    holdsFor(inactive(Person2)=true, Ii2),
    relative_complement_all(Iabrupt, [Ii1], Iabrupt_not_inactive1),
    relative_complement_all(Iabrupt, [Ii2], Iabrupt_not_inactive2),
    union_all([Iabrupt_not_inactive1, Iabrupt_not_inactive2], Iabrupt_valid),
    intersect_all([Ic, Iabrupt_valid], I).