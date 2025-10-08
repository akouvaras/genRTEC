%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id)=very_warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id)=warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, warm), T).

initiatedAt(internal_temperature(Id)=normal, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, normal), T).

initiatedAt(internal_temperature(Id)=cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, cold), T).

initiatedAt(internal_temperature(Id)=very_cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_cold), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id)=low, T) :-
    happensAt(noise_level_change(Id, _VehicleType, low), T).

initiatedAt(noise_level(Id)=normal, T) :-
    happensAt(noise_level_change(Id, _VehicleType, normal), T).

initiatedAt(noise_level(Id)=high, T) :-
    happensAt(noise_level_change(Id, _VehicleType, high), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id)=low, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, low), T).

initiatedAt(passenger_density(Id)=normal, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, normal), T).

initiatedAt(passenger_density(Id)=high, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, high), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id)=true, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id)=true, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id)=false, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id)=false, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(sharp_turn(Vehicle, _Type)=very_sharp), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(sharp_turn(Vehicle, _Type)=very_sharp), T).

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(abrupt_acceleration(Vehicle, _Type)=very_abrupt), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(abrupt_acceleration(Vehicle, _Type)=very_abrupt), T).

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(abrupt_deceleration(Vehicle, _Type)=very_abrupt), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(abrupt_deceleration(Vehicle, _Type)=very_abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(abrupt_acceleration(Vehicle, _Type)=abrupt), T),
    not holdsAt(abrupt_acceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(abrupt_acceleration(Vehicle, _Type)=abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(abrupt_deceleration(Vehicle, _Type)=abrupt), T),
    not holdsAt(abrupt_deceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(abrupt_deceleration(Vehicle, _Type)=abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(sharp_turn(Vehicle, _Type)=sharp), T),
    not holdsAt(sharp_turn(Vehicle, _Type)=very_sharp, T),
    not holdsAt(abrupt_acceleration(Vehicle, _Type)=very_abrupt, T),
    not holdsAt(abrupt_deceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(sharp_turn(Vehicle, _Type)=sharp), T).

%-------------- driving_quality ----------------%

initiatedAt(driving_quality(Vehicle)=low, T) :-
    happensAt(start(punctuality(Vehicle)=false), T).

initiatedAt(driving_quality(Vehicle)=low, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driving_quality(Vehicle)=medium, T) :-
    happensAt(start(punctuality(Vehicle)=true), T),
    holdsAt(punctuality(Vehicle)=true, T),
    happensAt(start(driving_style(Vehicle)=uncomfortable), T),
    not holdsAt(driving_style(Vehicle)=unsafe, T).

initiatedAt(driving_quality(Vehicle)=medium, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T),
    holdsAt(punctuality(Vehicle)=true, T),
    not holdsAt(driving_style(Vehicle)=unsafe, T).

initiatedAt(driving_quality(Vehicle)=high, T) :-
    happensAt(start(punctuality(Vehicle)=true), T),
    not holdsAt(driving_style(Vehicle)=unsafe, T),
    not holdsAt(driving_style(Vehicle)=uncomfortable, T).

initiatedAt(driving_quality(Vehicle)=high, T) :-
    happensAt(end(driving_style(Vehicle)=uncomfortable), T),
    holdsAt(punctuality(Vehicle)=true, T),
    not holdsAt(driving_style(Vehicle)=unsafe, T).

%------------ passenger_comfort -------------%

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(passenger_density(Vehicle)=high), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    not holdsAt(driving_style(Vehicle)=uncomfortable, T),
    not holdsAt(passenger_density(Vehicle)=high, T),
    not holdsAt(noise_level(Vehicle)=high, T),
    not holdsAt(internal_temperature(Vehicle)=very_warm, T),
    not holdsAt(internal_temperature(Vehicle)=very_cold, T).

%--------------- driver_comfort -----------------%

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    not holdsAt(driving_style(Vehicle)=uncomfortable, T),
    not holdsAt(noise_level(Vehicle)=high, T),
    not holdsAt(internal_temperature(Vehicle)=very_warm, T),
    not holdsAt(internal_temperature(Vehicle)=very_cold, T).

%---------------- passenger_satisfaction ------------------%

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    not holdsAt(driving_style(Vehicle)=uncomfortable, T),
    not holdsAt(noise_level(Vehicle)=high, T),
    not holdsAt(internal_temperature(Vehicle)=very_warm, T),
    not holdsAt(internal_temperature(Vehicle)=very_cold, T).