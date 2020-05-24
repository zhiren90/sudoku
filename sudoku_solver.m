% -------------------------------------------------------------- 
%|                                                              |
%|                      Sudoku Solver                           |
%|                                                              |
% -------------------------------------------------------------- 
% CREATED BY ZHIREN ZHU. 06/22/15, Sendai.
% A Matlab version to figure out an appropriate algorithm to efficiently
% solve any given Sudoku puzzle. The developed method will then be
% transformed to other languages for faster computation. 
%--------------------------------------------------------------- 
clc; clear all; close all;
%--------------------------------------------------------------- 
% INPUT PUZZLE:
% For now, just type it in here. Alternative option would be to read in
% from a .txt file, but the convenience level is quite similar ...

% Blank template to edit for convenience:
% PUZZLE = [0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0; ...
%           0 0 0, 0 0 0, 0 0 0];

PUZZLE = [0 0 0, 0 0 8, 7 0 4; ...
          0 2 0, 0 0 0, 0 0 0; ...
          1 7 0, 0 4 6, 2 0 0; ...
          9 3 0, 0 0 0, 0 0 0; ...
          0 0 0, 4 6 7, 0 0 0; ...
          0 0 0, 0 0 0, 0 8 1; ...
          0 0 1, 8 7 0, 0 5 2; ...
          0 0 0, 0 0 0, 0 3 0; ...
          3 0 7, 5 0 0, 0 0 0];
      
% PRINT TO CONFIRM:
display('The puzzle to be solved is:');
display(PUZZLE);
display('Please wait. Solving puzzle ...');
      
%--------------------------------------------------------------- 
% PROCESS INPUT:

SOLUTION = PUZZLE; % Copy the original puzzle to the solution matrix

% Count blank spaces, and also availability of number in each row, column,
% and grid ...

% Create three matrices, storing the availability of each number in each
% row, column, and grid. FORMAT: Row = N-th row/col/grid, Col = The number
% of interest. If there is a value, store 1, else 0.
% E.g. ROW(3,8) = 1; --> There is an 8 already in row #3.
% NOTE: Grid will be indexed as shown below:  
%          |1|2|3|
%          |4|5|6|
%          |7|8|9|
% Rows will be indexed from top to bottom. Columns from left to right.
AV_ROW = zeros(9,9);
AV_COL = zeros(9,9);
AV_GRID = zeros(9,9);

nblank = 0;
for irow = 1:9
    for jcol = 1:9
        val = PUZZLE(irow,jcol);
        if (val == 0)
            nblank = nblank + 1;
        end
    end
end

% Create a vector, recording the row, column, and value for blank space
BLANKS = zeros(nblank, 4);

% Run loop again, this time recording the information ...
iblank = 1;
for irow = 1:9
    for jcol = 1:9
        ngrid = ceil(jcol/3)+(ceil(irow/3)-1)*3;
        val = PUZZLE(irow,jcol); 
        if (val == 0)
            BLANKS(iblank,1) = irow;
            BLANKS(iblank,2) = jcol;
            BLANKS(iblank,3) = ngrid;
            % Column 4 will be all zero initially.
            iblank = iblank+1;
        else
            AV_ROW(irow,val) = 1;
            AV_COL(jcol,val) = 1;
            AV_GRID(ngrid,val)=1;
        end
    end
end

%--------------------------------------------------------------- 
% FIND SOLUTION:

% ALGORITHM EXPLANATION:
% June 22, 2015:
% Initial algorithm to use will be rather brute-force. Simply go through
% the blank spaces, and assigned each with the lowest value available. 
% When we hit 9 and still have no solution, go back and increase the value 
% in previous blank space .

% Assign condition variable: solved
solved = 0; % 0 is FALSE. Change to 1 if TRUE, and we will have solution.

space_now = 1; % Start solving from the first blank space

% Count step:
step = 0;

while (solved == 0)
    row = BLANKS(space_now,1);
    col = BLANKS(space_now,2);
    ngrid = BLANKS(space_now,3);
    val = BLANKS(space_now,4);
    
    if (val == 9) % We must alter the previous blank space
        step = step+1;
        BLANKS(space_now,4) = 0; % Clear the value previously set
        AV_ROW(row,val) = 0;
        AV_COL(col,val) = 0;
        AV_GRID(ngrid,val) = 0;
        space_now = space_now - 1; % ... and go back a space
    else
        row_ok = 0;
        col_ok = 0;
        grid_ok = 0;
        
        % Clean up value that may have been left off previously:
        if (val>0)
            AV_ROW(row,val) = 0;
            AV_COL(col,val) = 0;
            AV_GRID(ngrid,val) = 0;
        end
        
        while(row_ok*col_ok*grid_ok == 0 && val<9)
            step = step+1;
            val = val+1; % Increase the value at this space
            row_ok = 1-AV_ROW(row,val);
            col_ok = 1-AV_COL(col,val);
            grid_ok = 1-AV_GRID(ngrid,val);
            % For debug:
            %display(space_now)
            %display(val)
        end
        if(row_ok*col_ok*grid_ok == 0 && val==9)
            % Again, we can't find a solution here, must go back
            % Clear the value previously set ...
            BLANKS(space_now,4) = 0; 
            space_now = space_now - 1;
        end
        if(row_ok*col_ok*grid_ok == 1)
           BLANKS(space_now,4) = val; 
           AV_ROW(row,val) = 1;
           AV_COL(col,val) = 1;
           AV_GRID(ngrid,val) = 1;
           if space_now == nblank
               solved = 1; 
           else
               space_now = space_now+1;
           end
        end
    end
end

%--------------------------------------------------------------- 
% WRITE SOLUTION:

for space = 1:nblank
    row = BLANKS(space,1);
    col = BLANKS(space,2);
    SOLUTION(row,col) = BLANKS(space,4);
end

display('Solution found. It is:');
display(SOLUTION);
display('Total iteration steps:');
display(step);







      