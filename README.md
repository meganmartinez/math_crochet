# math_crochet
"Crocheting Surfaces of Revolution" contains Sage code that generates crochet patterns for surfaces by revolution. A surface by revolution is obtained by taking a function in the xy-plane and rotating it around some axis. Our program will always rotate the given function around the x-axis. Thus you should only choose functions that are positive.

For our program, your chosen function, f(x), has the following restrictions on your chosen interval from a to b:
- f(x) should be strictly positive on (a,b)
- f(x) should have a defined derivative on [a,b]

To use this program to create a crochet pattern for a particular surface by revolution, open the "Crocheting Surfaces of Revolution" Sage worksheet in CoCalc. 
- Evaluate the first block of code.
- Below the first block of code are a few examples of using the code. You must define a function f(x), lowerbound a, upperbound b, stitch gauge S, row gauge R, and scale (the measurement of one unit in inches), then evaluate.
- The output will be the set of crochet instructions. After the instructions, you will see the list of coordinates that correspond to each row of the crochet pattern and a plot showing your function with dots where each crochet row is placed.
