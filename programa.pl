% Parcial Pulp Fiction

personaje(pumkin,     ladron([licorerias, estacionesDeServicio])).
personaje(honeyBunny, ladron([licorerias, estacionesDeServicio])).
personaje(vincent,    mafioso(maton)).
personaje(jules,      mafioso(maton)).
personaje(marsellus,  mafioso(capo)).
personaje(winston,    mafioso(resuelveProblemas)).
personaje(mia,        actriz([foxForceFive])).
personaje(butch,      boxeador).

pareja(marsellus, mia).
pareja(pumkin, honeyBunny).

%trabajaPara(Empleador, Empleado)
trabajaPara(marsellus, vincent).
trabajaPara(marsellus, jules).
trabajaPara(marsellus, winston).

% 1) esPeligroso/1. Nos dice si un personaje es peligroso. 
% Eso ocurre cuando:
% - realiza alguna actividad peligrosa: ser matón, o robar licorerías. 
% - tiene empleados peligrosos

esPeligroso(Personaje) :-
    realizaActividadPeligrosa(Personaje),
    trabajaPara(Personaje, Empleado),
    realizaActividadPeligrosa(Empleado).

realizaActividadPeligrosa(Personaje) :-
    robaLicorerias(Personaje).

realizaActividadPeligrosa(Personaje) :-
    esMaton(Personaje).

robaLicorerias(Personaje) :-
    personaje(Personaje, ladron(Lista)),
    member(licorerias, Lista).

esMaton(Personaje) :- personaje(Personaje, mafioso(maton)).

% 2) 2. duoTemible/2 que relaciona dos personajes cuando 
% son peligrosos y además son pareja o amigos. Considerar 
% que Tarantino también nos dió los siguientes hechos:

amigo(vincent, jules).
amigo(jules, jimmie).
amigo(vincent, elVendedor).

duoTemible(A, B) :- sonDuoTemible(A, B).
duoTemible(A, B) :- sonDuoTemible(B, A).

sonDuoTemible(Personaje, OtroPersonaje) :-
    esPeligroso(Personaje),
    esPeligroso(OtroPersonaje),
    sonParejaOAmigos(Personaje, OtroPersonaje).

sonParejaOAmigos(Personaje, OtroPersonaje) :-
    pareja(Personaje, OtroPersonaje).

sonParejaOAmigos(Personaje, OtroPersonaje) :-
    amigo(Personaje, OtroPersonaje).

% 3.  estaEnProblemas/1: un personaje está en problemas cuando 
% el jefe es peligroso y le encarga que cuide a su pareja
% o bien, tiene que ir a buscar a un boxeador. 
% Además butch siempre está en problemas. 

%encargo(Solicitante, Encargado, Tarea). 
%las tareas pueden ser cuidar(Protegido), ayudar(Ayudado), buscar(Buscado, Lugar)

encargo(marsellus, vincent,   cuidar(mia)).
encargo(vincent,  elVendedor, cuidar(mia)).
encargo(marsellus, winston, ayudar(jules)).
encargo(marsellus, winston, ayudar(vincent)).
encargo(marsellus, vincent, buscar(butch, losAngeles)).

estaEnProblemas(Personaje) :-
    trabajaPara(Jefe, Personaje),
    esPeligroso(Jefe),
    cuidarParejaOBuscarBoxeador(Jefe, Personaje).

estaEnProblemas(butch).

cuidarParejaOBuscarBoxeador(Jefe, Personaje) :-
    encargo(Jefe, Personaje, cuidar(Pareja)),
    pareja(Jefe, Pareja).

cuidarParejaOBuscarBoxeador(Jefe, Personaje) :-
    encargo(Jefe, Personaje, buscar(Boxeador, _)),
    personaje(Boxeador, boxeador).

% 4. sanCayetano/1: es quien a todos los que tiene cerca les da 
% trabajo (algún encargo). Alguien tiene cerca a otro personaje si 
% es su amigo o empleado. 

sanCayetano(Persona) :-
    personaje(Persona, _),
    forall(tieneCerca(Persona, OtraPersona), 
    encargo(Persona, OtraPersona, _)).

tieneCerca(Persona, OtraPersona) :- amigo(Persona, OtraPersona).
tieneCerca(Persona, OtraPersona) :- trabajaPara(Persona, OtraPersona).
    
% 5. masAtareado/1. Es el más atareado aquel que tenga más
% encargos que cualquier otro personaje.

masAtareado(Persona) :-
    cantidadEncargos(Persona, CantidadMayor),
    not((cantidadEncargos(_, CantidadMenor), CantidadMenor > CantidadMayor)).

cantidadEncargos(Persona, Cantidad) :-
    encargo(_, Persona, _),
    findall(Encargo, encargo(_, Persona, Encargo), Encargos),
    length(Encargos, Cantidad).
    
/*
6. personajesRespetables/1: genera la lista de todos los personajes 
respetables. Es respetable cuando su actividad tiene un nivel 
de respeto mayor a 9. Se sabe que:
- Las actrices tienen un nivel de respeto de la décima parte de su
cantidad de peliculas.
- Los mafiosos que resuelven problemas tienen un nivel de 10 de
respeto, los matones 1 y los capos 20.
- Al resto no se les debe ningún nivel de respeto. 
*/

personajesRespetables(Personajes) :-
    findall(Persona, distinct(Persona, esRespetable(Persona)), Personajes).

esRespetable(Persona) :-
    personaje(Persona, Actividad),
    nivelRespeto(Actividad, NivelRespeto),
    NivelRespeto > 9.

nivelRespeto(_, actriz(Peliculas), NivelRespeto) :-
    length(Peliculas, CantidadPeliculas),
    NivelRespeto is CantidadPeliculas / 10.

nivelRespeto(mafioso(resuelveProblemas), 10).
nivelRespeto(mafioso(maton), 1).
nivelRespeto(mafioso(capo), 20).

nivelRespeto(_, 0).

% 7. hartoDe/2: un personaje está harto de otro, cuando todas 
% las tareas asignadas al primero requieren interactuar 
% con el segundo (cuidar, buscar o ayudar) o un amigo del segundo

hartoDe(Personaje, OtroPersonaje) :-
    encargo(_, Personaje, _),
    forall(encargo(_, Personaje, Tarea), interactuar(Tarea, OtroPersonaje)).

interactuar(Tarea, Persona) :-
    interactuaCon(Tarea, Persona).

interactuar(Tarea, Persona) :-
    amigo(Persona, AmigoPersona),
    interactuar(Tarea, AmigoPersona).

interactuaCon(cuidar(Otro), Otro).
interactuaCon(ayudar(Otro), Otro).
interactuaCon(buscar(Otro, _), Otro).

% 8. Ah, algo más: nuestros personajes tienen características. 
% Lo cual es bueno, porque nos ayuda a diferenciarlos cuando están de a dos. Por ejemplo:

caracteristicas(vincent,  [negro, muchoPelo, tieneCabeza]).
caracteristicas(jules,    [tieneCabeza, muchoPelo]).
caracteristicas(marvin,   [negro]).

% Desarrollar duoDiferenciable/2, que relaciona a un dúo (dos amigos o una pareja) 
% en el que uno tiene al menos una característica que el otro no. 

duoDiferenciable(Personaje, OtroPersonaje) :-
    sonParejaOAmigos(Personaje, OtroPersonaje),
    caracteristicas(Personaje, Lista1),
    caracteristicas(OtroPersonaje, Lista2),
    not(hayElementosEnComun(Lista1, Lista2)).

hayElementosEnComun([X|_], Lista2) :- member(X, Lista2).
hayElementosEnComun([_|T], Lista2) :- hayElementosEnComun(T, Lista2).
