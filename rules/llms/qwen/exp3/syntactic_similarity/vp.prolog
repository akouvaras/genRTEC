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
    happensAt(declare(C, M, not_carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initially(voted(Ag, M)=null).

initiatedAt(voted(Ag, M)=aye, T) :-
    happensAt(vote(Ag, M, aye), T),
    holdsAt(status(M)=voting, T),
    holdsAt(voted(Ag, M)=null, T).

initiatedAt(voted(Ag, M)=nay, T) :-
    happensAt(vote(Ag, M, nay), T),
    holdsAt(status(M)=voting, T),
    holdsAt(voted(Ag, M)=null, T).

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T),
    voted(Ag, M)=_.

%------------ outcome -------------%

initiatedAt(outcome(M)=carried, T) :-
    happensAt(declare(C, M, carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(C, M, not_carried), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_CurrentResult, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

initiatedAt(pow(Ag, M, propose)=true, T) :-
    happensAt(start(status(M)=null), T).

terminatedAt(pow(_Ag, M, propose)=true, T) :-
    happensAt(start(status(M)=proposed), T).

initiatedAt(pow(Ag, M, second)=true, T) :-
    happensAt(start(status(M)=proposed), T).

terminatedAt(pow(_Ag, M, second)=true, T) :-
    happensAt(start(status(M)=voting), T).

initiatedAt(pow(Ag, M, vote)=true, T) :-
    happensAt(start(status(M)=voting), T).

terminatedAt(pow(_Ag, M, vote)=true, T) :-
    happensAt(start(status(M)=voted), T).

initiatedAt(pow(C, M, close_ballot)=true, T) :-
    happensAt(start(status(M)=voting), T),
    role_of(C, chair).

terminatedAt(pow(C, M, close_ballot)=true, T) :-
    happensAt(start(status(M)=voted), T).

initiatedAt(pow(C, M, declare)=true, T) :-
    happensAt(start(status(M)=voted), T),
    role_of(C, chair).

terminatedAt(pow(C, M, declare)=true, T) :-
    happensAt(start(status(M)=proposed), T).