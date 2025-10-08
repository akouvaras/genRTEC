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
	holdsAt(closeSymmetric_30(Person, Object)=true, T),
    holdsAt(person(Person)=true, T).

% ----- terminate leaving_object: pick up object

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1,P2)=true, MI) :-
	holdsFor(walking(P1)=true, WP1),
	holdsFor(walking(P2)=true, WP2),
	intersect_all([WP1,WP2], WI),
	holdsFor(close_34(P1,P2)=true, CI),
	intersect_all([WI,CI], MI).
	
holdsFor(moving(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(walking(Person1)=true, IWalking1),
    holdsFor(person(Person2)=true, IPerson2),
    holdsFor(walking(Person2)=true, IWalking2),
	holdsFor(close_34(Person1,Person2)=true, IClose),
    intersect_all([IPerson1, IWalking1, IPerson2, IWalking2, IClose], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/
	
holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    holdsFor(person(Person1)=true, IPerson1),
    holdsFor(person(Person2)=true, IPerson2),
	holdsFor(close_34(Person1,Person2)=true, IClose),
    holdsFor(abrupt(Person1)=true, IAbrupt1),
    holdsFor(inactive(Person2)=true, IInactive2),
    relative_complement_all(IPerson2, [IInactive2], INotInactive2),
    intersect_all([IPerson1, IClose, IAbrupt1, INotInactive2], IScenarioA),
    holdsFor(abrupt(Person2)=true, IAbrupt2),
    holdsFor(inactive(Person1)=true, IInactive1),
    relative_complement_all(IPerson1, [IInactive1], INotInactive1),
    intersect_all([IPerson2, IClose, IAbrupt2, INotInactive1], IScenarioB),
    union_all([IScenarioA, IScenarioB], I).

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



