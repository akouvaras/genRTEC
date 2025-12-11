/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
	\+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
	\+ happensAt(disappear(Id), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    Person \= Object,
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T).
	
terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    thresholds(movingThr, MovingThr),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(close(P1, P2, MovingThr)=true, Ic),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    intersect_all([Iw1, Iw2, Ic, Ip1, Ip2], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(close(P1, P2, FightingThr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, In1),
    holdsFor(inactive(P2)=true, In2),
    intersect_all([Ip1, Ip2, Ic, Ia1], IbaseA),
    relative_complement_all(IbaseA, [In2], IA),
    intersect_all([Ip1, Ip2, Ic, Ia2], IbaseB),
    relative_complement_all(IbaseB, [In1], IB),
    union_all([IA, IB], I).
