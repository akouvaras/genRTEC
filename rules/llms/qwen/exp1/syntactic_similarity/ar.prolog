/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    not holdsAt(person(Id)=false, T).  

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    not holdsAt(person(Id)=false, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    not holdsAt(person(Id)=false, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    not holdsAt(person(Id)=false, T).

terminatedAt(person(Id), T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    holdsAt(person(Person)=true, T),
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, D), T),
    D =< LeavingObjectThreshold.

terminatedAt(leaving_object(Person, Object), T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    % Person1 \== Person2,
    person(Person1)=true,
    person(Person2)=true,
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, I_close),
    intersect_all([I1, I2, I_close], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    % Person1 \== Person2,
    holdsAt(person(Person1)=true, _),
    holdsAt(person(Person2)=true, _),
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, I_close),
    holdsFor(abrupt(Person1)=true, I_ab1),
    holdsFor(inactive(Person2)=true, I_inact2),
    relative_complement_all(I_ab1, [I_inact2], I_case1),
    intersect_all([I_case1, I_close], I1_final),
    holdsFor(abrupt(Person2)=true, I_ab2),
    holdsFor(inactive(Person1)=true, I_inact1),
    relative_complement_all(I_ab2, [I_inact1], I_case2),
    intersect_all([I_case2, I_close], I2_final),
    union_all([I1_final, I2_final], I).