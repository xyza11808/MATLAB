%% Include Tokens in Replacement Text  
% Replace variations of the phrase |'walk up'| by capturing the letters
% that follow |'walk'| in a token.   

%%  
str = 'I walk up, they walked up, we are walking up.';
expression = 'walk(\w*) up';
%%
replace = 'ascend$1';
newStr = regexprep(str,expression,replace)   

