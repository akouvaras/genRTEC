%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

terminatedAt(status(M)=null, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

terminatedAt(status(M)=proposed, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

terminatedAt(status(M)=voting, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, not_carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(status(M)=voted, T) :-
    happensAt(declare(C, M, _Outcome), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initially(voted(Ag, M)=null).

initiatedAt(voted(Ag, M)=aye, T) :-
    happensAt(vote(Ag, M, aye), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=nay, T) :-
    happensAt(vote(Ag, M, nay), T),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(Ag, M)=_Prev, T) :-
    happensAt(vote(Ag, M, _Choice), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T).

terminatedAt(voted(Ag, M)=_Prev, T) :-
    happensAt(start(status(M)=null), T).

%------------ outcome -------------%

initiatedAt(outcome(M)=carried, T) :-
    happensAt(declare(C, M, carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(C, M, not_carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Prev, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(Ag, propose, M)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(Ag, second, M)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(Ag, vote, M)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(Ag, close_ballot, M)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(Ag, declare, M)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(M)=voted, I).