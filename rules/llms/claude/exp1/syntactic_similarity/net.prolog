%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD) = true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, Merch, GD, accept_quote) = true, I) :-
    holdsFor(quote(Merch, Cons, GD) = true, I1),
    holdsFor(suspended(Merch, merchant) = true, I2),
    holdsFor(suspended(Cons, consumer) = true, I3),
    union_all([I2, I3], I_suspended),
    relative_complement_all(I1, [I_suspended], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote) = true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote) = true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay, iServer) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl(Cons, pay, iServer) = true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, pay, iServer) = true, T) :-
    happensAt(end(contract(_Merch, Cons, _GD) = true), T).

initiatedAt(obl(Merch, send_goods, iServer) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl(Merch, send_goods, iServer) = true, T) :-
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods, iServer) = true, T) :-
    happensAt(end(contract(Merch, _Cons, _GD) = true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T),
    not holdsAt(per(Merch, Cons, present_quote) = true, T).

initiatedAt(suspended(Merch, merchant) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl(Merch, send_goods, iServer) = true, T).

initiatedAt(suspended(Cons, consumer) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl(Cons, pay, iServer) = true, T).