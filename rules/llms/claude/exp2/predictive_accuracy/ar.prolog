/*********************************** CAVIAR CE DEFINITIONS *************************************/

/****************************************
 *		  CLOSE 		*
 ****************************************/

holdsFor(close_24(Id1,Id2)=true, I) :-
	holdsFor(distance(Id1,Id2,24)=true, I).

holdsFor(close_25(Id1,Id2)=true, I) :-
	holdsFor(close_24(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,25)=true, I2),
	union_all([I1,I2], I).

holdsFor(close_30(Id1,Id2)=true, I) :-
	holdsFor(close_25(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,30)=true, I2),
	union_all([I1,I2], I).

holdsFor(close_34(Id1,Id2)=true, I) :-
	holdsFor(close_30(Id1,Id2)=true, I1),
	holdsFor(distance(Id1,Id2,34)=true, I2),
	union_all([I1,I2], I).

holdsFor(close_34(Id1,Id2)=false, I) :-
	holdsFor(close_34(Id1,Id2)=true, I1),
	complement_all([I1], I).

holdsFor(closeSymmetric_30(Id1,Id2)=true, I) :-
	holdsFor(close_30(Id1,Id2)=true, I1),
	holdsFor(close_30(Id2,Id1)=true, I2),
	union_all([I1,I2], I).

/****************************************************************
 *		     PERSON					*
 ****************************************************************/
	
initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    \+ holdsAt(person(Id)=disappeared, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    \+ holdsAt(person(Id)=disappeared, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    \+ holdsAt(person(Id)=disappeared, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    \+ holdsAt(person(Id)=disappeared, T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    holdsAt(person(Person)=true, T),
    holdsAt(closeSymmetric_30(Person, Object)=true, T).

% ----- terminate leaving_object: pick up object

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    holdsAt(person(Person1)=true, _),
    holdsAt(person(Person2)=true, _),
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    holdsFor(close_34(Person1,Person2)=true, Ic),
    intersect_all([I1, I2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/
	
holdsFor(fighting(Person1, Person2)=true, I) :-
    holdsAt(person(Person1)=true, _),
    holdsAt(person(Person2)=true, _),
    holdsFor(close_34(Person1,Person2)=true, Ic),
    holdsFor(abrupt(Person1)=true, Ia1),
    holdsFor(abrupt(Person2)=true, Ia2),
    union_all([Ia1, Ia2], Iabrupt),
    holdsFor(inactive(Person1)=true, Ii1),
    holdsFor(inactive(Person2)=true, Ii2),
    relative_complement_all(Iabrupt, [Ii1], Icheck1),
    relative_complement_all(Iabrupt, [Ii2], Icheck2),
    union_all([Icheck1, Icheck2], Iactive),
    intersect_all([Ic, Iactive], I).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(id(_P)).

% Grounding of input entities:
grounding(appear(P)):-
	id(P).
grounding(disappear(P)):-
	id(P).
grounding(orientation(P)=_):-
	id(P).
grounding(appearance(P)=_):-
	id(P).
grounding(coord(P,_,_)=_):-
	id(P).
grounding(walking(P)=_):-
	id(P).
grounding(active(P)=_):-
	id(P).
grounding(inactive(P)=_):-
	id(P).
grounding(running(P)=_):-
	id(P).
grounding(abrupt(P)=_):-
	id(P).

grounding(close_24(P1,P2)=true) :- id(P1), id(P2), P1@<P2.
grounding(close_25(P1,P2)=true) :- id(P1), id(P2), P1@<P2.	
grounding(close_30(P1,P2)=true) :- id(P1), id(P2), P1@<P2.	
grounding(close_34(P1,P2)=true) :- id(P1), id(P2), P1@<P2.
% we are only interesting in caching close=false with respect to the 34 threshold
% we don't need any other thresholds for this fluent in the CAVIAR event description
grounding(close_34(P1,P2)=false) :-	id(P1), id(P2), P1@<P2.
% similarly we are only interesting in caching closeSymmetric=true with respect to the 30 threshold
grounding(closeSymmetric_30(P1,P2)=true) :- id(P1), id(P2), P1@<P2.
grounding(walking(P)=true) :- id(P). 
grounding(active(P)=true) :- id(P). 
grounding(inactive(P)=true) :- id(P).
grounding(abrupt(P)=true) :- id(P).
grounding(running(P)=true) :- id(P).
grounding(person(P)=true) :- id(P).
grounding(leaving_object(P,O)=true) :- id(P), id(O), P@<O.
grounding(moving(P1,P2)=true) :- id(P1), id(P2), P1@<P2.
grounding(fighting(P1,P2)=true) :- id(P1), id(P2), P1@<P2.

% For input entities expressed as statically determined fluents, state whether 
% the fluent instances will be reported as time-points (points/1) or intervals.
% By default, RTEC assumes that fluent instances are reported as intervals
% (in this case no declarations are necessary).
% This part of the declarations is used by the data loader.

points(orientation(_)=_).
points(appearance(_)=_).
points(coord(_,_,_)=true).
points(walking(_)=true).
points(active(_)=true).
points(inactive(_)=true).
points(running(_)=true).
points(abrupt(_)=true).


% For input entities expressed as statically determined fluents, state whether 
% the list of intervals of the input entity will be constructed by 
% collecting individual intervals (collectIntervals/1), or built from 
% time-points (buildFromPoints/1). If no declarations are provided for some,
% input entity, then the input entity may not participate in the specification of 
% output entities. 	 

buildFromPoints(walking(_)=true).
buildFromPoints(active(_)=true).
buildFromPoints(inactive(_)=true).
buildFromPoints(running(_)=true).
buildFromPoints(abrupt(_)=true).



