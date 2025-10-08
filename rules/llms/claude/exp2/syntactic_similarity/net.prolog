%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, Merch, GD, accept_quote)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, Iq),
    holdsFor(suspended(Merch, merchant)=true, Ism),
    holdsFor(suspended(Cons, consumer)=true, Isc),
    union_all([Ism, Isc], Isuspended),
    relative_complement_all(Iq, [Isuspended], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, pay, iServer, GD)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, pay, iServer, GD)=true, T) :-
    happensAt(end(contract(_Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, deliver, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, deliver, iServer, GD)=true, T) :-
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD),
    happensAt(send_goods(Merch, iServer, GD, G, K), T).

terminatedAt(obl(Merch, deliver, iServer, GD)=true, T) :-
    happensAt(end(contract(Merch, _Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T),
    not holdsAt(per(Merch, Cons)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, deliver, iServer, GD)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, pay, iServer, GD)=true, T).