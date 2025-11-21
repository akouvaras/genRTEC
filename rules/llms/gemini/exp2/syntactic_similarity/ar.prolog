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
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T),
    holdsAt(person(Person)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    thresholds(movingThr, MovingThr),
    holdsFor(person(P1)=true, I_p1),
    holdsFor(person(P2)=true, I_p2),
    holdsFor(walking(P1)=true, I_w1),
    holdsFor(walking(P2)=true, I_w2),
    holdsFor(close(P1, P2, MovingThr)=true, I_close),
    intersect_all([I_p1, I_p2, I_w1, I_w2, I_close], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(person(P1)=true, I_p1),
    holdsFor(person(P2)=true, I_p2),
    holdsFor(close(P1, P2, FightingThr)=true, I_close),
    holdsFor(abrupt(P1)=true, I_a1),
    holdsFor(inactive(P2)=true, I_i2),
    complement_all([I_i2], I_ni2),
    intersect_all([I_a1, I_ni2], I_caseA),
    holdsFor(abrupt(P2)=true, I_a2),
    holdsFor(inactive(P1)=true, I_i1),
    complement_all([I_i1], I_ni1),
    intersect_all([I_a2, I_ni1], I_caseB),
    union_all([I_caseA, I_caseB], I_logic),
    intersect_all([I_p1, I_p2, I_close, I_logic], I).