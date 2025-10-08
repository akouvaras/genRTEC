%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not holdsAt(suspended(Merch, merchant)=true, T),
    not holdsAt(suspended(Cons, consumer)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, Merch, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, Iq),
    holdsFor(suspended(Merch, merchant)=true, Is_m),
    holdsFor(suspended(Cons, consumer)=true, Is_c),
    relative_complement_all(Iq, [Is_m, Is_c], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote, Cons)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, present_quote, Cons)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay, Merch, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, pay, Merch, GD)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, Pr),
    P =:= Pr.

terminatedAt(obl(Cons, pay, Merch, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, deliver_goods, Cons, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, deliver_goods, Cons, GD)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, D),
    meets(D, GD).

terminatedAt(obl(Merch, deliver_goods, Cons, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Ag, merchant)=true, T) :-
    happensAt(present_quote(Ag, Cons, _GD, _Pr), T),
    not holdsAt(per(Ag, present_quote, Cons)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, deliver_goods, Cons, GD)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, pay, Merch, GD)=true, T).