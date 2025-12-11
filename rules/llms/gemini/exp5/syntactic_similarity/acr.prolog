/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(P)=true, T) :-
    happensAt(start(walking(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(running(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(active(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(abrupt(P)=true), T).

terminatedAt(person(P)=true, T) :-
    happensAt(disappear(P), T).

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
    thresholds(movingThr, MovingThr),
    holdsFor(person(P1)=true, I_person1),
    holdsFor(person(P2)=true, I_person2),
    holdsFor(walking(P1)=true, I_walk1),
    holdsFor(walking(P2)=true, I_walk2),
    holdsFor(close(P1, P2, MovingThr)=true, I_close),
    intersect_all([I_person1, I_person2, I_walk1, I_walk2, I_close], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(person(P1)=true, I_p1),
    holdsFor(person(P2)=true, I_p2),
    holdsFor(close(P1, P2, FightingThr)=true, I_close),
    holdsFor(abrupt(P1)=true, I_abrupt1),
    holdsFor(inactive(P2)=true, I_inactive2),
    holdsFor(abrupt(P2)=true, I_abrupt2),
    holdsFor(inactive(P1)=true, I_inactive1),
    intersect_all([I_p1, I_p2, I_close, I_abrupt1], I_base1),
    relative_complement_all(I_base1, [I_inactive2], I_sit1),
    intersect_all([I_p1, I_p2, I_close, I_abrupt2], I_base2),
    relative_complement_all(I_base2, [I_inactive1], I_sit2),
    union_all([I_sit1, I_sit2], I).
