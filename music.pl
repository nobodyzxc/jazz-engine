:- use_module(library(lambda)).
:- use_module(library(record)).

% Basics

% https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
% 0 - 127
% 127 = G9
% 60 = C4
% 21 = A0
% ---> C0 = 12
% midi_to_note(MidiNumber, Note) :-
% note_to_midi(Note, MidiNumber) :-

% for library(record): https://www.swi-prolog.org/pldoc/man?section=record
:- record note(
  name:oneof([c,d,e,f,g,a,b])=c,
  accidental:atom=natural,
  octave:integer=4).

mk_note(Name, Note) :-
  make_note([name(Name)], Note).
mk_note(Name, Accidental, Note) :-
  make_note([name(Name), accidental(Accidental)], Note).
mk_note(Name, Accidental, Octave, Note) :-
  make_note([name(Name), accidental(Accidental), octave(Octave)], Note).

% TODO: make predicate like c_sharp by meta programming

pretty_print([]).
pretty_print(Chord) :-
  chord_notes(Chord, Notes),
  pretty_print(Notes).
pretty_print([Note|Tail]) :-
    make_note(Name, Accidental, Octave, Note),
    write(Name), write('_'),
    write(Accidental), write('_'),
    write(Octave),
    write(' '),
    pretty_print(Tail),
    true.

% TODO: refine sharp
sharp(note{name: a, accidental: flat, octave: OctaveDown}, note{name: a, accidental: natural, octave: Octave}) :-
    OctaveDown is Octave-1.
sharp(note{name: a, accidental: natural, octave: Octave}, note{name: a, accidental: sharp, octave: Octave}).
sharp(note{name: a, accidental: sharp, octave: Octave}, note{name: b, accidental: natural, octave: Octave}).
sharp(note{name: b, accidental: flat, octave: Octave}, note{name: b, accidental: natural, octave: Octave}).
sharp(note{name: b, accidental: natural, octave: Octave}, note{name: c, accidental: natural, octave: Octave}).
sharp(note{name: c, accidental: natural, octave: Octave}, note{name: c, accidental: sharp, octave: Octave}).
sharp(note{name: c, accidental: sharp, octave: Octave}, note{name: d, accidental: natural, octave: Octave}).
sharp(note{name: d, accidental: flat, octave: Octave}, note{name: d, accidental: natural, octave: Octave}).
sharp(note{name: d, accidental: natural, octave: Octave}, note{name: d, accidental: sharp, octave: Octave}).
sharp(note{name: d, accidental: sharp, octave: Octave}, note{name: e, accidental: natural, octave: Octave}).
sharp(note{name: e, accidental: flat, octave: Octave}, note{name: e, accidental: natural, octave: Octave}).
sharp(note{name: e, accidental: natural, octave: Octave}, note{name: f, accidental: natural, octave: Octave}).
sharp(note{name: f, accidental: natural, octave: Octave}, note{name: f, accidental: sharp, octave: Octave}).
sharp(note{name: f, accidental: sharp, octave: Octave}, note{name: g, accidental: natural, octave: Octave}).
sharp(note{name: g, accidental: flat, octave: Octave}, note{name: g, accidental: natural, octave: Octave}).
sharp(note{name: g, accidental: natural, octave: Octave}, note{name: g, accidental: sharp, octave: Octave}).
sharp(note{name: g, accidental: sharp, octave: Octave}, note{name: a, accidental: flat, octave: OctaveUp}) :-
    OctaveUp is Octave+1.

flat(X, Y) :- sharp(Y, X).

enharmonic(X, Y) :-
  make_note(Name, Accidental, Octave, X),
  make_note(Name, Accidental, Octave, Y).

% Octave rollover (down)
enharmonic(X, Y) :-
  make_note(a, flat, Octave, X),
  OctaveMinusOne is Octave-1,
  make_note(g, sharp, OctaveMinusOne, Y).

% Same octave
enharmonic(X, Y) :-
    X = note{name: a, accidental: sharp, octave: Octave},
    Y = note{name: b, accidental: flat, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: b, accidental: flat, octave: Octave},
    Y = note{name: a, accidental: sharp, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: b, accidental: sharp, octave: Octave},
    Y = note{name: c, accidental: natural, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: c, accidental: flat, octave: Octave},
    Y = note{name: b, accidental: natural, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: c, accidental: sharp, octave: Octave},
    Y = note{name: d, accidental: flat, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: d, accidental: flat, octave: Octave},
    Y = note{name: c, accidental: sharp, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: d, accidental: sharp, octave: Octave},
    Y = note{name: e, accidental: flat, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: e, accidental: flat, octave: Octave},
    Y = note{name: d, accidental: sharp, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: e, accidental: sharp, octave: Octave},
    Y = note{name: f, accidental: natural, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: f, accidental: flat, octave: Octave},
    Y = note{name: e, accidental: natural, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: f, accidental: sharp, octave: Octave},
    Y = note{name: g, accidental: flat, octave: Octave}.
enharmonic(X, Y) :-
    X = note{name: g, accidental: flat, octave: Octave},
    Y = note{name: f, accidental: sharp, octave: Octave}.

% Octave rollover (up)
enharmonic(X, Y) :-
    X = note{name: g, accidental: sharp, octave: Octave},
    OctavePlusOne is Octave+1,
    Y = note{name: a, accidental: flat, octave: OctavePlusOne}.

% Intervals

% Turn any flats into the enharmonic sharp (or natural).
sharpify_flats(OrigNote, NormNote) :-
    OrigNote = note{name: _, accidental: _, octave: _},
    NormNote = note{name: _, accidental: NormAccidental, octave: _},
    enharmonic(OrigNote, NormNote),
    member(NormAccidental, [natural, sharp]).


% Compute a list of all notes in all octaves and find the distance between the given notes in that list.
% We hard-code one octave becuase we don't want to deal with enharmonics.
mk_note_list_octave(OctaveNumber, OctaveNotes) :-
    OctaveNotes = [
        note{name: a, accidental: natural, octave: OctaveNumber},
        note{name: a, accidental: sharp, octave: OctaveNumber},
        note{name: b, accidental: natural, octave: OctaveNumber},
        note{name: c, accidental: natural, octave: OctaveNumber},
        note{name: c, accidental: sharp, octave: OctaveNumber},
        note{name: d, accidental: natural, octave: OctaveNumber},
        note{name: d, accidental: sharp, octave: OctaveNumber},
        note{name: e, accidental: natural, octave: OctaveNumber},
        note{name: f, accidental: natural, octave: OctaveNumber},
        note{name: f, accidental: sharp, octave: OctaveNumber},
        note{name: g, accidental: natural, octave: OctaveNumber},
        note{name: g, accidental: sharp, octave: OctaveNumber}
    ].

% Append the helper result above for octaves 0-7
mk_note_list(Notes) :-
    mk_note_list_octave(0, Octave0),
    mk_note_list_octave(1, Octave1),
    mk_note_list_octave(2, Octave2),
    mk_note_list_octave(3, Octave3),
    mk_note_list_octave(4, Octave4),
    mk_note_list_octave(5, Octave5),
    mk_note_list_octave(6, Octave6),
    mk_note_list_octave(7, Octave7),
    append([Octave0, Octave1, Octave2, Octave3, Octave4, Octave5, Octave6, Octave7], Notes).

slice(L, From, To, R):-
        length(LFrom, From),
        length([_|LTo], To),
        append(LTo, _, L),
        append(LFrom, R, LTo).

mk_note_list_guitar(Notes) :-
    % Martin DC-45 has 3 octaves and a major 6th of range.
    % 45 notes beginning with E2.
    mk_note_list(AllNotes),

    % Find E2
    nth0(FromIndex, AllNotes, note{name: e, accidental: natural, octave: 2}),
    ToIndex is FromIndex + 46,
    slice(AllNotes, FromIndex, ToIndex, Notes).
is_guitar_playable(Note) :-
    mk_note_list_guitar(Possible),
    member(Note, Possible).


interval(First, Second, Semitones) :-
    mk_note_list(Notes),

    sharpify_flats(First, FirstNorm),
    sharpify_flats(Second, SecondNorm),

    nth0(IndexFirst, Notes, FirstNorm),
    nth0(IndexSecond, Notes, SecondNorm),
    Semitones is IndexSecond - IndexFirst,
    Semitones >= 0,

    !; % Cut because: if already found an interval, eliminate choice point.
       % If not, check the backwards interval.
    interval(Second, First, Semitones).


interval_octave_agnostic(First, Second, Semitones) :-
    % Put both notes in the same octave
    First = note{name: NameFirst, accidental: AccidentalFirst, octave: _},
    Second = note{name: NameSecond, accidental: AccidentalSecond, octave: _},

    NormFirst = note{name: NameFirst, accidental: AccidentalFirst, octave: 4},
    NormSecond = note{name: NameSecond, accidental: AccidentalSecond, octave: 4},

    % Call "interval"
    interval(NormFirst, NormSecond, Semitones).


interval_name(0, unison).
interval_name(1, minor_second).
interval_name(2, major_second).
interval_name(3, minor_third).
interval_name(4, major_third).
interval_name(5, perfect_fourth).
interval_name(6, tritone).
interval_name(6, augmented_fourth).
interval_name(6, diminished_fifth).
interval_name(7, perfect_fifth).
interval_name(8, minor_sixth).
interval_name(9, major_sixth).
interval_name(10, minor_seventh).
interval_name(11, major_seventh).
interval_name(12, octave).

% Patterns and Scales

% read as: How many semitones above the tonic is each scale degree? (Indexed by 1)
    % scale degrees: 1  2  3  4  5  6   7
major_scale_pattern([0, 2, 4, 5, 7, 9, 11]).
ionian_scle_pattern([0, 2, 4, 5, 7, 9, 11]).
dorian_scle_pattern([0, 2, 3, 5, 7, 9, 10]).
phrygian_scle_pattern([0, 1, 3, 5, 7, 8, 10]).
lydian_scle_pattern([0, 2, 4, 6, 7, 9, 11]).
mixolydian_scle_pattern([0, 2, 4, 5, 7, 9, 10]).

minor_scale_pattern([0, 2, 3, 5, 7, 8, 10]).
aeolian_scle_pattern([0, 2, 3, 5, 7, 8, 10]).
locrian_scle_pattern([0, 1 3, 5, 6, 8, 10]).

scale_degree(Tonic, Pattern, Degree, Note) :-
    nth1(Degree, Pattern, Interval),
    interval(Tonic, Note, Interval).

major_scale_degree(Tonic, Degree, Note) :-
    major_scale_pattern(Pattern),
    scale_degree(Tonic, Pattern, Degree, Note).

betweenToList(X,X,[X]) :- !.
betweenToList(X,Y,[X|Xs]) :-
    X =< Y,
    Z is X+1,
    betweenToList(Z,Y,Xs).

scale(Tonic, Pattern, Notes) :-
    betweenToList(1,7,Degrees),   % generates list of intervals above tonic, by scale degree
    maplist(\Degree^Note^(
        scale_degree(Tonic, Pattern, Degree, Note)
    ), Degrees, Notes).

major_scale(Tonic, Notes) :-
    major_scale_pattern(Pattern),
    scale(Tonic, Pattern, Notes).

minor_scale(Tonic, Notes) :-
    minor_scale_pattern(Pattern),
    scale(Tonic, Pattern, Notes).


% Chords

%%%%%%%%%%%%%%%%%
%     Traid     %
%%%%%%%%%%%%%%%%%

% Adjustments are based on the given scale pattern, not the major scale pattern.
% Ex a major pattern with a degree of 3 will be a major third.
% To get a minor chord, either change to a minor pattern (with natural adjustments),
% or change the adjustment of the third to flat (keeping the major pattern).
:- record chord(
  root:note = note(c, natural, 4),
  pattern:list = [0, 2, 4, 5, 7, 9, 11],
  degrees:list = [1, 3, 5],
  adjustments:list = [natural, natural, natural]).

chord_of(Chord, Root, ScalePattern, Degrees, Adjustments) :-
  call(ScalePattern, Pattern),
  make_chord(
    [root(Root), pattern(Pattern), degrees(Degrees),
     adjustments(Adjustments)], Chord).

major_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5],
    [natural, natural, natural]).

minor_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5],
    [natural, natural, natural]).

% Equivalent to:
% minor_chord(Root, Chord) :-                                  |-------- flat 3 = minor ------|
%     major_scale_pattern(Pattern),     <--- major             v                              v
%     Chord = chord{root: Root, pattern: Pattern, degrees: [1, 3, 5], adjustments: [natural, flat, natural]}.

% The adjustment pattern here is natural, natural, flat-- even though diminished chords have a flat 3.
% This is because the pattern is minor and the 3rd is already flat, so the adjustment is natural.
diminished_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5],
    [natural, natural, flat]).


augmented_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5],
    [natural, natural, sharp]).

minor_sharp_5_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5],
    [natural, natural, sharp]).

major_flat_5_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5],
    [natural, natural, flat]).

sus2_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 2, 5],
    [natural, natural, natural]).


sus4_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 4, 5],
    [natural, natural, natural]).

%%%%%%%%%%%%%%%%%%%%%%%%%
%     Seventh Chord     %
%%%%%%%%%%%%%%%%%%%%%%%%%

major_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5, 7],
    [natural, natural, natural, natural]).



dominant_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5, 7],
    [natural, natural, natural, flat]).

minor_major_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5, 7],
    [natural, flat, natural, natural]).

minor_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5, 7],
    [natural, flat, natural, flat]).

major_7_sharp_5_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5, 7],
    [natural, natural, sharp, natural]).

augmented_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 3, 5, 7],
    [natural, natural, sharp, flat]).

minor_7_flat_5(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5, 7],
    [natural, flat, flat, flat]).

% FIXME: bb7 instead of 6
diminished_7_chord(Root, Chord) :-
  chord_of(Chord, Root,
    minor_scale_pattern, [1, 3, 5, 6],
    [natural, flat, flat, natural]).

nine_sus4_chord(Root, Chord) :-
  chord_of(Chord, Root,
    major_scale_pattern, [1, 4, 5, 2],
    [natural, natural, natural, natural]).
    % Have to use 2 because 9 is out of range-- only 7 scale degrees.

% TODO: meta programming to generate chord constructors,
% TODO: use minor_third and major_third to define chords
% TODO: use midi as absolute note
% TODO: add mode scale (Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian) and mode scale for minor...
% TODO: add progression analysis, like secondary dominant, tritone substitution, ...
%       https://www.thejazzpianosite.com/jazz-piano-lessons/jazz-chord-progressions/how-to-analyse-a-chord-progression-harmonic-analysis/

adjusted_note(Note, natural, AdjustedNote) :- AdjustedNote = Note.
adjusted_note(Note, sharp, AdjustedNote) :- sharp(Note, AdjustedNote).
adjusted_note(Note, flat, AdjustedNote) :- flat(Note, AdjustedNote).

chord_notes(Chord, Notes) :-
    make_chord(
    [root(Root), pattern(Pattern), degrees(Degrees),
     adjustments(Adjustments)], Chord),
    length(Degrees, DegreesLength),

    betweenToList(1,DegreesLength,Indices),
    maplist(\Index^Degree^Adjustment^AdjustedNote^(
        nth1(Degree, Pattern, Interval),
        interval(Root, Note, Interval),

        nth1(Index, Adjustments, Adjustment),
        adjusted_note(Note, Adjustment, AdjustedNote)
    ), Indices, Degrees, Adjustments, Notes).


% Chord Progressions
chord_progression(Tonic, Pattern, Degrees, Chords) :-
    maplist(\Degree^Chord^(
        nth1(Degree, Pattern, Interval),
        interval(Tonic, Note, Interval),
        major_chord(Note, Chord)
    ), Degrees, Chords).


tritone_subsititution(Chord, Subsititued) :-
  chord_root(Chord, Root),
  dominant_7_chord(Root, Chord),
  interval_octave_agnostic(Root, Subsititued, 6).
  %minor_7_chord(SubRoot, Subsititued).

tritone_subsititution(Chord, Subsititued) :-
  tritone_subsititution(Subsititued, Chord).

% TODO: upper structur on chord transformation

% transformation between 7 and diminished_7
% X7b9 = (x+1) dim7
%             ||
% (X+3)7 = (X+4) dim7
% (X+6)7 = (X+7) dim7
% (X+9)7 = (X+10) dim7


% % Guitar

% TODO: add shell voicing and slash/inversion, drop2 chord

% voicing([], _, [], []).
% voicing([_|Tuning], Frets, Quality, Voicing) :-
%     voicing(Tuning, Frets, Quality, Voicing).
% voicing([[String,Open]|Tuning], Frets, Quality, [[String,Fret]|Voicing]) :-
%     between(0,Frets,Fret),
%     Pitch is (Open + Fret) mod 12,
%     member(Pitch, Quality),
%     subtract(Quality, [Pitch], RemainingQuality),
%     voicing(Tuning, Frets, RemainingQuality, Voicing).

% voicing(Quality, Voicing) :-
%   voicing([[0,40], [1,45], [2,50], [3,55], [4,59], [5,64]],
%           8,
%           Quality,
%           Voicing).


% test :-
%     interval(
%         note{name: c, accidental: natural, octave: 4},
%         note{name: d, accidental: flat, octave: 4},
%         Interval
%     ),
%     interval_name(Interval, IntervalName).

% progression
% 1, 4, 1
% 1, 5, 1
% 1, 4, 5, 1
% 2, 5, 1
% 1, 4, 2, 5
% 1, 5, 6, 4
% 1, 5/7, 6, 5
% 4, 3, 4, 5
% 1, 5, 6, 3
% 4, 1, 4, 5
c(N) :- mk_note(c, N).
d(N) :- mk_note(d, N).
e(N) :- mk_note(e, N).
f(N) :- mk_note(f, N).
g(N) :- mk_note(g, N).
a(N) :- mk_note(a, N).
b(N) :- mk_note(b, N).
