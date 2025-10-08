/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    not happensAt(disappear(Id), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

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
    holdsFor(close(Person1, Person2, MovingThreshold)=true, I3),
    intersect_all([I1, I2, I3], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, I1),
    holdsFor(abrupt(Person1)=true, I2),
    holdsFor(abrupt(Person2)=true, I3),
    union_all([I2, I3], I4),
    holdsFor(inactive(Person1)=true, I5),
    holdsFor(inactive(Person2)=true, I6),
    union_all([I5, I6], I7),
    intersect_all([I1, I4], I8),
    relative_complement_all(I8, [I7], I).