%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(Chair, M), T),
    holdsAt(status(M)=voting, T),
    role_of(Chair, chair).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Chair, M, carried), T),
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Chair, M, not_carried), T),
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).

%-------------- voted ----------------------%

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
    happensAt(declare(Chair, M, carried), T),
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(Chair, M, not_carried), T),
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).

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

holdsFor(pow(Chair, M, close_ballot)=true, I) :-
    holdsFor(status(M)=voting, I),
    role_of(Chair, chair).

holdsFor(pow(Chair, M, declare)=true, I) :-
    holdsFor(status(M)=voted, I),
    role_of(Chair, chair).