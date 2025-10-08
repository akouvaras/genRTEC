/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(present(Id)=true, T) :-
    happensAt(appear(Id), T).

terminatedAt(present(Id)=true, T) :-
    happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    holdsAt(present(Id)=true, T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, LeavingObjectThreshold)=true, T),
    holdsAt(person(Person)=true, T),
    \+ holdsAt(person(Object)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T),
    holdsAt(leaving_object(Person, Object)=true, T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    holdsFor(walking(Person1)=true, I_walk1),
    holdsFor(walking(Person2)=true, I_walk2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, I_close),
    intersect_all([I_walk1, I_walk2, I_close], I),
    Person1 @< Person2.

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, I_close),
    holdsFor(abrupt(Person1)=true, I_abrupt1),
    holdsFor(abrupt(Person2)=true, I_abrupt2),
    holdsFor(inactive(Person1)=true, I_inactive1),
    holdsFor(inactive(Person2)=true, I_inactive2),
    intersect_all([I_close, I_abrupt1], I_intersect_A),
    relative_complement_all(I_intersect_A, [I_inactive2], I_case_A),
    intersect_all([I_close, I_abrupt2], I_intersect_B),
    relative_complement_all(I_intersect_B, [I_inactive1], I_case_B),
    union_all([I_case_A, I_case_B], I),
    Person1 @< Person2.