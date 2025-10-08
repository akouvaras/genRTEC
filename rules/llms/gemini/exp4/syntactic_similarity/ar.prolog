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
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(Person, Object, LeavingObjectThreshold)=true, T),
    holdsAt(person(Person)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    thresholds(moving, MovingThreshold),
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(walking(Person1)=true, IWalking1),
    holdsFor(person(Person2)=true, IPerson2),
    holdsFor(walking(Person2)=true, IWalking2),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, IClose),
    intersect_all([IPerson1, IWalking1, IPerson2, IWalking2, IClose], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    thresholds(fighting, FightingThreshold),
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(person(Person2)=true, IPerson2),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, IClose),
    holdsFor(abrupt(Person1)=true, IAbrupt1),
    holdsFor(inactive(Person2)=true, IInactive2),
    relative_complement_all(IPerson2, [IInactive2], INotInactive2),
    intersect_all([IPerson1, IClose, IAbrupt1, INotInactive2], IScenarioA),
    holdsFor(abrupt(Person2)=true, IAbrupt2),
    holdsFor(inactive(Person1)=true, IInactive1),
    relative_complement_all(IPerson1, [IInactive1], INotInactive1),
    intersect_all([IPerson2, IClose, IAbrupt2, INotInactive1], IScenarioB),
    union_all([IScenarioA, IScenarioB], I).