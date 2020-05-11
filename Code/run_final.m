%% Names:

% Group 1:
name_1 = 'Group 1';
tra_1_test = @send_1;
rec_1_test = @reci_1;
tra_1_fight = @send_1;
rec_1_fight = @reci_1;
tra_1_co_op = @send_1;
rec_1_co_op = @reci_1;

% Group 2:
name_2 = 'Group 2';
tra_2_test = @send_1;
rec_2_test = @reci_1;
tra_2_fight = @send_1;
rec_2_fight = @reci_1;
tra_2_co_op = @send_1;
rec_2_co_op = @reci_1;

% Group 3:
name_3 = 'Group 3';
tra_3_test = @send_1;
rec_3_test = @reci_1;
tra_3_fight = @send_1;
rec_3_fight = @reci_1;
tra_3_co_op = @send_1;
rec_3_co_op = @reci_1;

% Group 4:
name_4 = 'Group 4';
tra_4_test = @send_1;
rec_4_test = @reci_1;
tra_4_fight = @send_1;
rec_4_fight = @reci_1;
tra_4_co_op = @send_1;
rec_4_co_op = @reci_1;

%% Run:

% Tests:
score_1_test = testing_ground_final('test',0,name_1,tra_1_test,rec_1_test);
score_2_test = testing_ground_final('test',0,name_2,tra_2_test,rec_2_test);
score_3_test = testing_ground_final('test',0,name_3,tra_3_test,rec_3_test);
score_4_test = testing_ground_final('test',0,name_4,tra_4_test,rec_4_test);

% Fights:
score_1_2_fight = testing_ground_final('fight',0,name_1,tra_1_test,rec_1_test,name_2,tra_2_test,rec_2_test);
score_1_3_fight = testing_ground_final('fight',0,name_1,tra_1_test,rec_1_test,name_3,tra_3_test,rec_3_test);
score_1_4_fight = testing_ground_final('fight',0,name_1,tra_1_test,rec_1_test,name_4,tra_4_test,rec_4_test);
score_2_3_fight = testing_ground_final('fight',0,name_2,tra_2_test,rec_2_test,name_3,tra_3_test,rec_3_test);
score_2_4_fight = testing_ground_final('fight',0,name_2,tra_2_test,rec_2_test,name_4,tra_4_test,rec_4_test);
score_3_4_fight = testing_ground_final('fight',0,name_3,tra_3_test,rec_3_test,name_4,tra_4_test,rec_4_test);

% Co_op:
score_1_2_co_op = testing_ground_final('co_op',0,name_1,tra_1_test,rec_1_test,name_2,tra_2_test,rec_2_test);
score_1_3_co_op = testing_ground_final('co_op',0,name_1,tra_1_test,rec_1_test,name_3,tra_3_test,rec_3_test);
score_1_4_co_op = testing_ground_final('co_op',0,name_1,tra_1_test,rec_1_test,name_4,tra_4_test,rec_4_test);
score_2_3_co_op = testing_ground_final('co_op',0,name_2,tra_2_test,rec_2_test,name_3,tra_3_test,rec_3_test);
score_2_4_co_op = testing_ground_final('co_op',0,name_2,tra_2_test,rec_2_test,name_4,tra_4_test,rec_4_test);
score_3_4_co_op = testing_ground_final('co_op',0,name_3,tra_3_test,rec_3_test,name_4,tra_4_test,rec_4_test);

% Scores calculation:
score_1 = score_1_test + score_1_2_fight + score_1_3_fight + score_1_4_fight + score_1_2_co_op + score_1_3_co_op + score_1_4_co_op;
score_2 = score_2_test - score_1_2_fight + score_2_3_fight + score_2_4_fight + score_1_2_co_op + score_2_3_co_op + score_2_4_co_op;
score_3 = score_3_test - score_1_3_fight - score_2_3_fight + score_3_4_fight + score_1_3_co_op + score_2_3_co_op + score_3_4_co_op;
score_4 = score_4_test - score_1_4_fight - score_2_4_fight - score_3_4_fight + score_1_4_co_op + score_2_4_co_op + score_3_4_co_op;

% Print scoreboard:
scores = {name_1, score_1; name_2, score_2; name_3, score_3; name_4, score_4};
scoreboard = sortrows(scores,-2)

