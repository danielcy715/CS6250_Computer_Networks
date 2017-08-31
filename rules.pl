ubmit_rule(submit(CR)) :-
    gerrit:max_with_block(-2, 2, 'Code-Review', CR).
