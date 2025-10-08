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
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, LeavingObjectThreshold)=true, T),
    holdsAt(person(Person)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    P1 @< P2,
    thresholds(moving, MovingThreshold),
    holdsFor(person(P1)=true, IPerson1),
    holdsFor(person(P2)=true, IPerson2),
    holdsFor(walking(P1)=true, IWalk1),
    holdsFor(walking(P2)=true, IWalk2),
    holdsFor(close(P1, P2, MovingThreshold)=true, IClose),
    intersect_all([IPerson1, IPerson2, IWalk1, IWalk2, IClose], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting_candidate(Agitator, Other)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(person(Agitator)=true, IPerson1),
    holdsFor(person(Other)=true, IPerson2),
    holdsFor(close(Agitator, Other, FightingThreshold)=true, IClose),
    holdsFor(abrupt(Agitator)=true, IAbrupt),
    intersect_all([IPerson1, IPerson2, IClose, IAbrupt], ICandidate),
    holdsFor(inactive(Other)=true, IInactive),
    relative_complement_all(ICandidate, [IInactive], I).

holdsFor(fighting(P1, P2)=true, I) :-
    P1 @< P2,
    holdsFor(fighting_candidate(P1, P2)=true, ICase1),
    holdsFor(fighting_candidate(P2, P1)=true, ICase2),
    union_all([ICase1, ICase2], I).