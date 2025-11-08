# dict_solver

This repo is for a basic wordle solver for learning Gleam and Lustre to build websites.

You need 5 characters before it shows any results.

`-` are wildcards for when you don't know the letter. A letter in a slot means that letter is green in that position.
The Invalid Letters input is for letters that are black (aka not in the solution).

Examples for Wordle Letters input:
`___a_`: I only know that there is an 'a' in the second to last position
`sho_t`: I don't know the letter in the second to last position but the rest are green.

This does not deal with yellow letters.
