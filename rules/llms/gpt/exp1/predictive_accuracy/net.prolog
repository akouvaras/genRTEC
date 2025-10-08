
/***********************
 * INSTITUTIONAL FACTS *
 ***********************/

/***************
 *    quote    *
 ***************/

% ----- a quote enables the consumer to create a contract by accepting it
	
initiatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Price), T).

terminatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

% ----- a quote is terminated 5 time-points after initiated
fi(quote(Merch,Cons,GD)=true, quote(Merch,Cons,GD)=false, 5).
p(quote(_M,_C,_GD)=true).

 % *   contract	 *

% ----- accepting a quote initiates a contract 
	
initiatedAt(contract(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD) = true, T),
    \+ holdsAt(suspended(Merch, merchant) = true, T),
    \+ holdsAt(suspended(Cons, consumer) = true, T).
	
% ----- a contract is terminated 10 time-points after initiated 
fi(contract(Merch,Cons,GD)=true, contract(Merch,Cons,GD)=false, 5).

% INSTITUTIONAL POWER
	
holdsFor(pow(accept_quote(Cons,Merch,GD))=true, I) :-
    holdsFor(quote(Merch, Cons, GD) = true, Iq),
    holdsFor(suspended(Merch, merchant) = true, Im),
    holdsFor(suspended(Cons,  consumer) = true, Ic),
    relative_complement_all(Iq, [Im, Ic], I).
	
% ----- we do not define institutional power for the remaining actions

% *     PERMISSION      *

% permitted by default; thus we only model (and ground) prohibitions
	
initiatedAt(per(present_quote(Merch,Cons))=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

initiatedAt(per(present_quote(Merch,Cons))=false, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Price), T).

fi(per(present_quote(Merch,Cons))=false, per(present_quote(Merch,Cons))=true, 10).
p(per(present_quote(_Merch,_Cons))=false).

% *     OBLIGATION      *

% ----- establishing a contract initiates obligations for the contracting parties
	
initiatedAt(obl(send_EPO(Cons,Merch,GD))=true, T1, T, T2) :-
	initiatedAt(contract(_Merch,Cons,GD)=true, T1, T, T2).

	
initiatedAt(obl(send_goods(Merch,Cons,GD))=true, T1, T, T2) :-
	initiatedAt(contract(Merch,_Cons,GD)=true, T1, T, T2).

% ----- discharging the obligations

initiatedAt(obl(send_EPO(Cons,Merch,GD))=false, T) :-
    happensAt(send_EPO(Cons, iServer, GD, Price), T),
	price(GD,Price).

initiatedAt(obl(send_goods(Merch,Cons,GD))=false, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, Key), T),
    decrypt(G, Key, Decrypted_G),
    meets(Decrypted_G, GD).

% ----- the end of the contract terminates the obligations of the contracting parties
initiatedAt(obl(send_EPO(Cons,Merch,GD))=false, T1, T, T2) :-
	initiatedAt(contract(_Merch,Cons,GD)=false, T1, T, T2).
	
initiatedAt(obl(send_goods(Merch,Cons,GD))=false, T1, T, T2) :-
	initiatedAt(contract(Merch,_Cons,GD)=false, T1, T, T2).

%       SANCTION       

% ----- if a merchant sends unsolicited quotes 'too frequently', which is forbidden, 
% ----- then it will be suspended
	
initiatedAt(suspended(Merch, merchant) = true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Price), T),
	holdsAt(per(present_quote(Merch,Cons))=false, T).
	
% ----- failure to discharge the obligation to send an EPO by the end of the contract 
% ----- suspends the merchant 
	
initiatedAt(suspended(Merch,merchant)=true, T1, T, T2) :-
	initiatedAt(contract(Merch,_Cons,GD)=false, T1, T, T2),
	holdsAt(obl(send_goods(Merch,Cons,GD))=true, T).
	
% ----- failure to discharge the obligation to send an EPO by the end of the contract 
% ----- suspends the consumer 

initiatedAt(suspended(Cons,consumer)=true, T1, T, T2) :-
	initiatedAt(contract(_Merch,Cons,GD)=false, T1, T, T2),
	holdsAt(obl(send_EPO(Cons,Merch,GD))=true, T).

% ----- a suspension is terminated 10 time-points after initiated, 
% ----- unless re-initiated in the meantime
fi(suspended(Ag,Role)=true, suspended(Ag,Role)=false, 3).
p(suspended(_Ag,_Role)=true).


% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(person(_)).
dynamicDomain(person_pair(_,_)).

% Grounding of input entities:
grounding(request_quote(C,M,_)):-
	person_pair(M, C).
grounding(present_quote(M,C,_,_)):-
	person_pair(M, C).
grounding(accept_quote(C,M,_)):-
	person_pair(M, C).
grounding(send_EPO(Ag,_,_,_)):-
    person(Ag).
grounding(send_goods(Ag,_,_,_,_)):-
    person(Ag).

% Grounding of output entities:
grounding(suspended(Ag,Role)=true):-
    person(Ag),role_of(Ag,Role).
grounding(suspended(Ag,Role)=false):-
    person(Ag),role_of(Ag,Role).
grounding(quote(M,C,GD)=true):- 
    person_pair(M,C), role_of(C, consumer), role_of(M, merchant), \+ M=C, queryGoodsDescription(GD).
grounding(quote(M,C,GD)=false):- 
    person_pair(M,C), role_of(C, consumer), role_of(M, merchant), \+ M=C, queryGoodsDescription(GD).
grounding(contract(M,C,GD)=true):-
    person_pair(M,C),role_of(M,merchant), role_of(C,consumer), \+ M=C, queryGoodsDescription(GD).
grounding(contract(M,C,GD)=false):-
    person_pair(M,C),role_of(M,merchant), role_of(C,consumer), \+ M=C, queryGoodsDescription(GD).
grounding(pow(accept_quote(C,M,GD))=true):-
    person_pair(M,C),role_of(M,merchant), role_of(C,consumer), \+ C=M, queryGoodsDescription(GD).
grounding(per(present_quote(M,C))=false):-
    person_pair(M,C),role_of(M,merchant), role_of(C,consumer), \+ C=M.
grounding(per(present_quote(M,C))=true):-
    person_pair(M,C),role_of(M,merchant), role_of(C,consumer), \+ C=M.
grounding(obl(send_EPO(C,M,GD))=true):-
    person_pair(M,C),role_of(C,consumer), role_of(M,merchant), queryGoodsDescription(GD).
grounding(obl(send_goods(M,C,GD))=true):-
    person_pair(M,C),role_of(C,consumer), role_of(M,merchant), queryGoodsDescription(GD).
grounding(obl(send_EPO(C,M,GD))=false):-
    person_pair(M,C),role_of(C,consumer), role_of(M,merchant), queryGoodsDescription(GD).
grounding(obl(send_goods(M,C,GD))=false):-
    person_pair(M,C),role_of(C,consumer), role_of(M,merchant), queryGoodsDescription(GD).
