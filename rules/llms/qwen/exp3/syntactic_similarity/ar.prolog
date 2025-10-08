/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(walking(Entity)=true), T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(running(Entity)=true), T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(active(Entity)=true), T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(abrupt(Entity)=true), T).

terminatedAt(person(Entity)=true, T) :-
    happensAt(disappear(Entity), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    person(Person) = true,
    thresholds(leavingObject, MaxDist),
    close(Person, Object, MaxDist) = true.

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, I_prox),
    intersect_all([I1, I2, I_prox], I),
    I \= [].

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    person(Person1) = true,
    person(Person2) = true,
    Person1 \= Person2,
    thresholds(fighting, FightDist),
    holdsFor(close(Person1, Person2, FightDist)=true, I_prox),
    holdsFor(abrupt(Person1)=true, I_ab1),
    holdsFor(abrupt(Person2)=true, I_ab2),
    holdsFor(inactive(Person1)=true, I_inact1),
    holdsFor(inactive(Person2)=true, I_inact2),
    relative_complement_all(I_prox, [I_inact1], I_not_inact1),
    relative_complement_all(I_prox, [I_inact2], I_not_inact2),
    intersect_all([I_prox, I_ab1, I_not_inact2], I_case1),
    intersect_all([I_prox, I_ab2, I_not_inact1], I_case2),
    union_all([I_case1, I_case2], I),
    I \= [].