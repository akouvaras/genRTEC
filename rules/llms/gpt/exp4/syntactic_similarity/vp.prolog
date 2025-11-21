%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
	happensAt(propose(_P,M), T), 
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
	happensAt(second(_S,M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
	happensAt(declare(C,M,_), T), 
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(status(M)=V1, T) :-
    initiatedAt(status(M)=V2, T),
    V1 \= V2.

%-------------- voted ----------------------%

initiatedAt(voted(V, M)=aye, T) :-
    happensAt(vote(V, M, aye), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(V, M)=nay, T) :-
    happensAt(vote(V, M, nay), T),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(V, M)=V1, T) :-
    initiatedAt(voted(V, M)=V2, T),
    V1 \= V2.

terminatedAt(voted(V, M)=aye, T) :-
    happensAt(start(status(M)=null), T).

terminatedAt(voted(V, M)=nay, T) :-
    happensAt(start(status(M)=null), T).

holdsFor(voted(V, M)=null, I) :-
    holdsFor(voted(V, M)=aye, Ia),
    holdsFor(voted(V, M)=nay, In),
    complement_all([Ia, In], I).

%------------ outcome -------------%

initiatedAt(outcome(M)=carried, T) :-
    happensAt(declare(C, M, carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(C, M, not_carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_O, T) :-
    happensAt(start(status(M)=proposed), T).

terminatedAt(outcome(M)=V1, T) :-
    initiatedAt(outcome(M)=V2, T),
    V1 \= V2.

%-------------- institutional power ---------------%

holdsFor(pow(propose(_P,M))=true, I) :-
	holdsFor(status(M)=null, I).

holdsFor(pow(second(_S,M))=true, I) :-
	holdsFor(status(M)=proposed, I).

holdsFor(pow(vote(_V,M))=true, I) :-
	holdsFor(status(M)=voting, I).

holdsFor(pow(close_ballot(_C,M))=true, I) :-
	role_of(C,chair),
	holdsFor(status(M)=voting, I).

holdsFor(pow(declare(_C,M))=true, I) :-
	role_of(C,chair),
	holdsFor(status(M)=voted, I).