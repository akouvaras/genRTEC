/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(visible(Id)=true, T) :-
    happensAt(appear(Id), T).

terminatedAt(visible(Id)=true, T) :-
    happensAt(disappear(Id), T).
	
initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    holdsAt(visible(Id)=true, T).	

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

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    thresholds(movingThr, MovingThr),
    holdsFor(close(P1, P2, MovingThr)=true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Ii1),
    complement_all([Ii1], I_not_inactive1),
    holdsFor(inactive(P2)=true, Ii2),
    complement_all([Ii2], I_not_inactive2),
    intersect_all([Ia1, I_not_inactive2], I_CaseA),
    intersect_all([Ia2, I_not_inactive1], I_CaseB),
    union_all([I_CaseA, I_CaseB], I_logic),
    intersect_all([Ip1, Ip2, Ic, I_logic], I).