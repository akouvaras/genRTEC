/****************************************************************
 *		     PERSON					*
 ****************************************************************/

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
    holdsAt(person(Person)=true, T),
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, LeavingObjectThreshold)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T),
    holdsAt(leaving_object(Person, Object)=true, T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    thresholds(moving, MovingThreshold),
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(person(Person2)=true, IPerson2),
    holdsFor(walking(Person1)=true, IWalk1),
    holdsFor(walking(Person2)=true, IWalk2),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, IClose),
    intersect_all([IPerson1, IPerson2, IWalk1, IWalk2, IClose], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(aggressor_victim(Aggressor, Victim)=true, I) :-
    holdsFor(abrupt(Aggressor)=true, IAbrupt),
    holdsFor(inactive(Victim)=true, IInactive),
    relative_complement_all(IAbrupt, [IInactive], I).

holdsFor(fight_interaction(Person1, Person2)=true, I) :-
    holdsFor(aggressor_victim(Person1, Person2)=true, I_AV_12),
    holdsFor(aggressor_victim(Person2, Person1)=true, I_AV_21),
    union_all([I_AV_12, I_AV_21], I).

holdsFor(fighting(Person1, Person2)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(person(Person2)=true, IPerson2),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, IClose),
    holdsFor(fight_interaction(Person1, Person2)=true, IFightInteraction),
    intersect_all([IPerson1, IPerson2, IClose, IFightInteraction], I).
