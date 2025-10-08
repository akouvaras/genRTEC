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
    holdsFor(quote(Merch, Cons, GD)=true, I1),
    holdsFor(suspended(Merch, merchant)=true, I2),
    holdsFor(suspended(Cons, consumer)=true, I3),
    union_all([I2, I3], I4),
    relative_complement_all(I1, [I4], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(end(contract(_Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(end(contract(Merch, _Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Agent, merchant)=true, T) :-
    happensAt(present_quote(Agent, _Cons, _GD, _Pr), T),
    not holdsAt(per(Agent, _Cons)=true, T).

initiatedAt(suspended(Agent, merchant)=true, T) :-
    happensAt(end(contract(Agent, _Cons, GD)=true), T),
    holdsAt(obl(Agent, send_goods, iServer, GD)=true, T).

initiatedAt(suspended(Agent, consumer)=true, T) :-
    happensAt(end(contract(_Merch, Agent, GD)=true), T),
    holdsAt(obl(Agent, send_EPO, iServer, GD)=true, T).