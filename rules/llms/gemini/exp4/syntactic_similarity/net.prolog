%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD, Pr)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, Pr), T).

terminatedAt(quote(Merch, Cons, GD, _Pr)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD, _Pr)=true, T),
    \+ holdsAt(suspended(Merch)=true, T),
    \+ holdsAt(suspended(Cons)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, Merch, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD, _Pr)=true, IQuote),
    holdsFor(suspended(Merch)=true, ISuspendedMerch),
    holdsFor(suspended(Cons)=true, ISuspendedCons),
    relative_complement_all(IQuote, [ISuspendedMerch, ISuspendedCons], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO(GD, Pr), iServer)=true, T) :-
    happensAt(start(contract(_Merch, Cons, GD)=true), T),
    price(GD, Pr).

terminatedAt(obl(Cons, send_EPO(GD, Pr), iServer)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, Pr), T).

terminatedAt(obl(Cons, send_EPO(GD, _Pr), iServer)=true, T) :-
    happensAt(end(contract(_Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(start(contract(Merch, _Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, _G, _K), T).

terminatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(end(contract(Merch, _Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T),
    \+ holdsAt(per(Merch, Cons, present_quote)=true, T).

initiatedAt(suspended(Merch)=true, T) :-
    happensAt(end(contract(Merch, _Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods(GD), _iServer)=true, T).

initiatedAt(suspended(Cons)=true, T) :-
    happensAt(end(contract(_Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO(GD, _Pr), _iServer)=true, T).