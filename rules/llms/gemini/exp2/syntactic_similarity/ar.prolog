/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    holdsAt(person(Person)=true, T),
    thresholds(leavingObject, Threshold),
    holdsAt(close(Person, Object, Threshold)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    thresholds(moving, Threshold),
    holdsFor(walking(Person1)=true, I_Walk1),
    holdsFor(walking(Person2)=true, I_Walk2),
    holdsFor(close(Person1, Person2, Threshold)=true, I_Close),
    intersect_all([I_Walk1, I_Walk2, I_Close], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    holdsFor(person(Person1)=true, I_P1),
    holdsFor(person(Person2)=true, I_P2),
    thresholds(fighting, Threshold),
    holdsFor(close(Person1, Person2, Threshold)=true, I_Close),
    holdsFor(abrupt(Person1)=true, I_Abrupt1),
    holdsFor(abrupt(Person2)=true, I_Abrupt2),
    holdsFor(inactive(Person1)=true, I_Inactive1),
    holdsFor(inactive(Person2)=true, I_Inactive2),
    intersect_all([I_P1, I_P2, I_Close, I_Abrupt1], I_A_Positive),
    relative_complement_all(I_A_Positive, [I_Inactive2], I_ScenarioA),
    intersect_all([I_P1, I_P2, I_Close, I_Abrupt2], I_B_Positive),
    relative_complement_all(I_B_Positive, [I_Inactive1], I_ScenarioB),
    union_all([I_ScenarioA, I_ScenarioB], I).