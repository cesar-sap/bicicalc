# bicicalc
Bicycle Frame Geometry Calculator for Builders

# Description
This project implements a bicycle frame measurements calculator for bicycle frame builders.

It is oriented to steel tubes and manual brazing.

# Language
For the logic, we use Perl.

For the user interface we may use a Web interface, better option will be determined later.

The logic will be exposed as a module or .emb files in the SPL framework.

# Architecture
1. Data 
    We have input data and derived data. One hash contains Input data, other hash that may contain subhashes will contain calculated data.
    Data hashes are Package vars.

2. Logic
    Will be executed as subs. Ideally functions receive auxiliary dafa and operate using Input hash on Calculation hash. They may return also some the calculated data for that operation. 

3. All subs and data are implemented in the Package BiciCalc.




