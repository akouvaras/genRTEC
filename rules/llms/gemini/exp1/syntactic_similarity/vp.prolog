%--------------- status -----------%

initially(status(_M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, Outcome), T),
    role_of(C, chair),
    member(Outcome, [carried, not_carried]),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Ag, M)=V, T) :-
    happensAt(vote(Ag, M, V), T),
    member(V, [aye, nay]),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(Ag, M)=V, T) :-
    happensAt(start(status(M)=null), T),
    member(V, [aye, nay]).

%------------ outcome -------------%

initiatedAt(outcome(M)=Outcome, T) :-
    happensAt(declare(C, M, Outcome), T),
    member(Outcome, [carried, not_carried]),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Outcome, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(_Ag, propose, M)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(_Ag, second, M)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(_Ag, vote, M)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, close_ballot, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, declare, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voted, I).