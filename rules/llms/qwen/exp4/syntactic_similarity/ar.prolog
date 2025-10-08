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
    holdsAt(close(Person, Object, _Distance)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    thresholds(moving, MovingThreshold),
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    holdsFor(close(Person1, Person2, MovingThreshold)=true, Ic),
    intersect_all([I1, I2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 \= Person2,
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold)=true, Ic),
    Ic \= [],
    holdsFor(abrupt(Person1)=true, Ia1),
    holdsFor(abrupt(Person2)=true, Ia2),
    holdsFor(inactive(Person1)=true, Ii1),
    holdsFor(inactive(Person2)=true, Ii2),
    relative_complement_all(Ic, [Ii1], I1_active),
    relative_complement_all(Ic, [Ii2], I2_active),
    intersect_all([Ic, Ia1, I2_active], I_case1),
    intersect_all([Ic, Ia2, I1_active], I_case2),
    union_all([I_case1, I_case2], I),
    I \= [].