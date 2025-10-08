%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
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

%-------------- voted ----------------------%

initially(voted(Ag, M)=null).

initiatedAt(voted(Ag, M)=aye, T) :-
    happensAt(vote(Ag, M, aye), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=nay, T) :-
    happensAt(vote(Ag, M, nay), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=null, T) :-
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

terminatedAt(outcome(M)=carried, T) :-
    happensAt(start(status(M)=proposed), T).

terminatedAt(outcome(M)=not_carried, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(Ag, M, propose)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(Ag, M, second)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(Ag, M, vote)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, M, close_ballot)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, M, declare)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voted, I).