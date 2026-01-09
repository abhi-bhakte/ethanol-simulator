function feedback_form


clc
clear all

disp('==============================Thank You For Your Valuable Time==============================');

disp('********************************************************************************************');

disp('Now a series of questions will come in front of you. You''ll  have to answert those according the experience you felt during simulation');

disp('Press Any Key To Continue...');
pause

disp('==========================================Feedback==========================================');

fid_que = fopen('data\text-logs\feedback_ans.txt','wt+');

a01 = input('\n1. Have you learnt previously about CSTR process in your curriculum (Yes/No) : ','s');
a1 = input('\n1a. Rate yourself on process knowledge of CSTR process....... \n  ');

a02 = input('\n2. Have you learnt previously about Distillation Column in your curriculum (Yes/No) : ','s');
a2 = input('\n2a. Rate yourself on knowledge of Distillation Column process...... ');

a3 = input('\n3. Have you ever come across this type of Scenario before? ( Yes/No ) : ','s');

a4 = input('\n4. How much did alarm summary panel help you? [1(Not at all) to 5(Very Much))] : ');

a5 = input('\n5. Did you able to locate locations of disturbed variables from alarm summary? [1(Not at all) to 5(Very Much))] : ');

a6 = input('\n6. Write prefence order depending upon usefulness of following in diagnosis \n 1.Alarm Summary 2.Process Variable Trend 3. Apriori Process Knowledge like ( for example 312 ): ');

a7 = input('\n7. Have you found yourself lost during the simulation with a lot of information?(Yes/No) : ','s');

a8 = input('\n8. Rate the amount of information provided to you? [1(Very meager) to 5(Overwhelming)] : ');

a9 = input('\n9. Relevancy of Information on schematic display? [1(Not at all relevant) to 5(very relevant)] : ');

a10 = input('\n10. Relevancy of Information on alarm summary panel? [1(Not at all relevant) to 5(very relevant)] : ');

a11 = input('\n11. Did use of different colors help you navigate smoothly? [1(Not at all) to 5(Very much)] : ');

a12 = input('\n12. How much confidence do you have about submitting correct diagnosis? [1(0-20%) to 5(80-100%)] : ');

a13 = input('\n13. Give comments on improvement of this setup. You can also share views by which diagnosis can be done more swiftly and correctly? \n Please don''t press Enter Key until you done with writing :  ','s'); 


disp('=====================================Thank You For Spending Your Valuable Time For This Study======================================');


fprintf(fid_que,'\n Have you learnt about CSTR process in your curriculum (Yes/No) \n %s \n ',(a01));
fprintf(fid_que,'\n Rate yourself on process knowledge of CSTR process(Enter a number from 1(Very Less) to 5(Excellent)) \n %s',num2str(a1));
fprintf(fid_que,'\n Have you learnt about Distillation Column in your curriculum (Yes/No) \n %s \n',a02);
fprintf(fid_que,'\n  Rate yourself on knowledge of Distillation Column process(Enter a number from 1(Very Less) to 5(Excellent)) \n %s',num2str(a2));
fprintf(fid_que,'\n Have you ever come across this type of Scenario before? \n %s',a3);
fprintf(fid_que,'\n How much did alarm summary panel help you? [1(Not at all) to 5(Very Much))] \n %s \n',num2str(a4));
fprintf(fid_que,'\n Did you able to locate locations of disturbed variables from alarm summary? [1(Not at all) to 5(Very Much))] \n %s \n',num2str(a5));
fprintf(fid_que,'\n Write prefence order depending upon usefulness of following in diagnosis \n 1.Alarm Summary 2.Process Variable Trend 3. Apriori Process Knowledge like ( for example 312 ) \n %s \n',num2str(a6));
fprintf(fid_que,'\n Have you found yourself lost during the simulation with a lot of information?(Yes/No) \n %s \n',a7);
fprintf(fid_que,'\n Rate the amount of information provided to you? [1(Very meager) to 5(Overwhelming)] \n %s \n',num2str(a8));
fprintf(fid_que,'\n  Relevancy of Information on schematic display? [1(Not at all relevant) to 5(very relevant)] \n %s \n',num2str(a9));
fprintf(fid_que,'\n Relevancy of Information on alarm summary panel? [1(Not at all relevant) to 5(very relevant)] \n %s \n',num2str(a10));
fprintf(fid_que,'\n Did use of different colors help you navigate smoothly? [1(Not at all) to 5(Very much)] \n %s \n',num2str(a11));
fprintf(fid_que,'\n  How much confidence do you have about submitting correct diagnosis? [1(0-20%) to 5(80-100%)] \n %s \n',num2str(a12));
fprintf(fid_que,'\n Give comments on improvement of this setup. You can also share views by which diagnosis can be done more swiftly and correctly? \n Please don''t press Enter Key until you done with writing \n %s \n',num2str(a13));

fclose(fid_que);

end

