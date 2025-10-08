%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(Ag, M), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Ag, M, carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Ag, M, not_carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(status(M), T) :-
    happensAt(propose(_, M), T),
    holdsAt(status(M)=null, T).  

terminatedAt(status(M), T) :-
    happensAt(second(_, M), T),
    holdsAt(status(M)=proposed, T).  

terminatedAt(status(M), T) :-
    happensAt(close_ballot(Ag, M), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voting, T).  

terminatedAt(status(M), T) :-
    happensAt(declare(Ag, M, carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).  

terminatedAt(status(M), T) :-
    happensAt(declare(Ag, M, not_carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initially(voted(Ag, M)=null).

initiatedAt(voted(Ag, M)=aye, T) :-
    happensAt(vote(Ag, M, aye), T),
    holdsAt(status(M)=voting, T),
    not holdsAt(voted(Ag, M)=aye, T). 

initiatedAt(voted(Ag, M)=nay, T) :-
    happensAt(vote(Ag, M, nay), T),
    holdsAt(status(M)=voting, T),
    not holdsAt(voted(Ag, M)=nay, T). 

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T),  
    holdsAt(voted(Ag, M)=aye, _);         
    holdsAt(voted(Ag, M)=nay, _).

terminatedAt(voted(Ag, M), T) :-
    happensAt(vote(Ag, M, aye), T),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(Ag, M), T) :-
    happensAt(vote(Ag, M, nay), T),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(Ag, M), T) :-
    happensAt(start(status(M)=null), T).

%------------ outcome -------------%

initiatedAt(outcome(M)=carried, T) :-
    happensAt(declare(Ag, M, carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(Ag, M, not_carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M), T) :-
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