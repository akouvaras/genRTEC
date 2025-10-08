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

holdsFor(pow(Cons, accept_quote, Merch, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, IQuote),
    holdsFor(suspended(Merch, merchant)=true, ISusMerch),
    holdsFor(suspended(Cons, consumer)=true, ISusCons),
    relative_complement_all(IQuote, [ISusMerch, ISusCons], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote, Cons)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, present_quote, Cons)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO(IServer), Merch, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO(IServer), Merch, GD)=true, T) :-
    happensAt(send_EPO(Cons, IServer, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, send_EPO(_IServer), Merch, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(IServer), Cons, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(IServer), Cons, GD)=true, T) :-
    happensAt(send_goods(Merch, IServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods(_IServer), Cons, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T),
    \+ holdsAt(per(Merch, present_quote, Cons)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods(_IServer), Cons, GD)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO(_IServer), Merch, GD)=true, T).