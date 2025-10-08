%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=very_warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id, VehicleType)=warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, warm), T).

initiatedAt(internal_temperature(Id, VehicleType)=normal, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, normal), T).

initiatedAt(internal_temperature(Id, VehicleType)=cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, cold), T).

initiatedAt(internal_temperature(Id, VehicleType)=very_cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_cold), T).

terminatedAt(internal_temperature(Id, VehicleType)=_Prev, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _New), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType)=_Prev, T) :-
    happensAt(noise_level_change(Id, VehicleType, _New), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType)=_Prev, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _New), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType)=_Prev, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, _Status), T).

terminatedAt(punctuality(Id, VehicleType)=_Prev, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, _Status), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe) :-
    holdsFor(sharp_turn(Id,VehicleType)=very_sharp, It_vs),
    holdsFor(abrupt_acceleration(Id,VehicleType)=very_abrupt, Ia_va),
    holdsFor(abrupt_deceleration(Id,VehicleType)=very_abrupt, Id_vd),
    union_all([It_vs, Ia_va, Id_vd], I_unsafe).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf) :-
    holdsFor(sharp_turn(Id,VehicleType)=very_sharp, It_vs),
    holdsFor(abrupt_acceleration(Id,VehicleType)=very_abrupt, Ia_va),
    holdsFor(abrupt_deceleration(Id,VehicleType)=very_abrupt, Id_vd),
    union_all([It_vs, Ia_va, Id_vd], I_unsafe),
    holdsFor(sharp_turn(Id,VehicleType)=sharp, It_s),
    relative_complement_all(It_s, [Ia_va, Id_vd, It_vs], I_A),
    holdsFor(abrupt_acceleration(Id,VehicleType)=abrupt, Ia_a),
    holdsFor(abrupt_deceleration(Id,VehicleType)=abrupt, Id_ad),
    union_all([Ia_a, Id_ad], I_B_raw),
    union_all([I_A, I_B_raw], I_uncomf0),
    relative_complement_all(I_uncomf0, [I_unsafe], I_uncomf).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I_high) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    union_all([Iu, Iuc], Ibad),
    relative_complement_all(Ip, [Ibad], I_high).

holdsFor(driving_quality(Id, VehicleType)=medium, I_med) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    intersect_all([Ip, Iuc], I_med).

holdsFor(driving_quality(Id, VehicleType)=low, I_low) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    union_all([Inp, Iu], I_low).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, I_pd_high),
    holdsFor(noise_level(Id, VehicleType)=high, I_noise_high),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_vwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_vcold),
    union_all([ I_uncomf
              , I_unsafe
              , I_pd_high
              , I_noise_high
              , I_temp_vwarm
              , I_temp_vcold
              ], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(noise_level(Id, VehicleType)=high, I_noise_high),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_vwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_vcold),
    union_all([ I_uncomf
              , I_unsafe
              , I_noise_high
              , I_temp_vwarm
              , I_temp_vcold
              ], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Ipc),
    union_all([Inp, Ipc], I).