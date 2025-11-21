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
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, I_p1),
    holdsFor(person(P2)=true, I_p2),
    holdsFor(walking(P1)=true, I_walk1),
    holdsFor(walking(P2)=true, I_walk2),
    thresholds(movingThr, MovingThr),
    holdsFor(close(P1, P2, MovingThr)=true, I_close),
    intersect_all([I_p1, I_p2, I_walk1, I_walk2, I_close], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, I_p1),
    holdsFor(person(P2)=true, I_p2),
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, I_close),
    holdsFor(abrupt(P1)=true, I_abrupt1),
    holdsFor(inactive(P2)=true, I_inactive2),
    relative_complement_all(I_abrupt1, [I_inactive2], I_condA),
    holdsFor(abrupt(P2)=true, I_abrupt2),
    holdsFor(inactive(P1)=true, I_inactive1),
    relative_complement_all(I_abrupt2, [I_inactive1], I_condB),
    union_all([I_condA, I_condB], I_complex_condition),
    intersect_all([I_p1, I_p2, I_close, I_complex_condition], I).