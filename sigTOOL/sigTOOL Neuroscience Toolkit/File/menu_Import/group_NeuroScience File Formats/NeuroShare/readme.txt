At the moment, the program has to be run from within the
'Matlab Wrapper\Required Resources' directory. This will 
have to be changed in the final version. There the m-files
should be in a Matlab path directory together with the
mex and Neuroshare DLL. For that, the path of the DLL call
in the mex DLL has to be changed since it currently uses
the current working directory in Matlab.