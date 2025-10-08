%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not suspended(Merch),
    not suspended(Cons).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote(Merch, GD))=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, I1),
    holdsFor(suspended(Merch, merchant)=true, I2),
    relative_complement_all([[0, infinity]], [I2], I_merchant_active),
    holdsFor(suspended(Cons, consumer)=true, I3),
    relative_complement_all([[0, infinity]], [I3], I_consumer_active),
    intersect_all([I1, I_merchant_active, I_consumer_active], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote(Cons, GD), true), T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, present_quote(Cons, GD), true), T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO(iServer, GD, P))=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T),
    price(GD, P).

terminatedAt(obl(Cons, send_EPO(iServer, GD, P))=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, send_EPO(iServer, GD, P))=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(iServer, GD, G, K))=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(iServer, GD, G, K))=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods(iServer, GD, G, K))=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Agent, merchant)=true, T) :-
    happensAt(present_quote(Agent, Cons, GD, _Pr), T),
    not holdsAt(per(Agent, present_quote(Cons, GD), true), T).

initiatedAt(suspended(Agent, merchant)=true, T) :-
    happensAt(end(contract(Agent, Cons, GD)=true), T),
    holdsAt(obl(Agent, send_goods(iServer, GD, _G, _K))=true, T).

initiatedAt(suspended(Agent, consumer)=true, T) :-
    happensAt(end(contract(Merch, Agent, GD)=true), T),
    holdsAt(obl(Agent, send_EPO(iServer, GD, _P))=true, T).