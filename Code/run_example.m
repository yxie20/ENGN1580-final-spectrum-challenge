tic
t1 = testing_ground_3('test',0,'BOB',@send_1,@reci_1,'SAM',@send_2,@reci_2);
toc
tic
t2 = testing_ground_3('test',0,'BOB',@send_2,@reci_2,'SAM',@send_1,@reci_1);
toc
tic
f = testing_ground_3('fight',0,'BOB',@send_1,@reci_1,'SAM',@send_2,@reci_2);
toc
tic
c = testing_ground_3('fight',0,'BOB',@send_1,@reci_1,'SAM',@send_2,@reci_2);
toc
score_1 = t1+f+abs(c)
score_2 = t2-f+abs(c)