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
    holdsFor(suspended(Merch, merchant)=true, Is1),
    holdsFor(suspended(Cons, consumer)=true, Is2),
    union_all([Is1, Is2], Is),
    relative_complement_all(Iq, [Is], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay, iServer)=true, T) :-
    happensAt(start(contract(_Merch, Cons, _GD)=true), T).

terminatedAt(obl(Cons, pay, iServer)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, pay, iServer)=true, T) :-
    happensAt(end(contract(_Merch, Cons, _GD)=true), T).

initiatedAt(obl(Merch, send_goods, iServer)=true, T) :-
    happensAt(start(contract(Merch, _Cons, _GD)=true), T).

terminatedAt(obl(Merch, send_goods, iServer)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods, iServer)=true, T) :-
    happensAt(end(contract(Merch, _Cons, _GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Ag, merchant)=true, T) :-
    happensAt(present_quote(Ag, _Cons, _GD, _Pr), T),
    not holdsAt(per(Ag, _Cons, present_quote)=true, T).

initiatedAt(suspended(Ag, merchant)=true, T) :-
    happensAt(end(contract(Ag, _Cons, _GD)=true), T),
    holdsAt(obl(Ag, send_goods, iServer)=true, T).

initiatedAt(suspended(Ag, consumer)=true, T) :-
    happensAt(end(contract(_Merch, Ag, _GD)=true), T),
    holdsAt(obl(Ag, pay, iServer)=true, T).