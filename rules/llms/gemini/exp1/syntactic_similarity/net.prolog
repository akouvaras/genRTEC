%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    \+ holdsAt(suspended(Merch)=true, T),
    \+ holdsAt(suspended(Cons)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, Merch, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, IQuote),
    holdsFor(suspended(Merch, merchant)=true, ISusMerch),
    holdsFor(suspended(Cons, consumer)=true, ISusCons),
    relative_complement_all(IQuote, [ISusMerch, ISusCons], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, GD)=true, T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO(iServer, GD, P), Merch)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T),
    price(GD, P).

terminatedAt(obl(Cons, send_EPO(iServer, GD, P), Merch)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, SentP), T),
    price(GD, P),
    SentP == P.

terminatedAt(obl(Cons, send_EPO(_iServer, GD, _P), Merch)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(iServer, GD), Cons)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(iServer, GD), Cons)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods(_iServer, GD), Cons)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T),
    \+ holdsAt(per(Merch, Cons, GD)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods(_iServer, GD), Cons)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO(_iServer, GD, _P), Merch)=true, T).