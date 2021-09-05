//Yang Huan A0224968N E0575602@u.nus.edu

//Assignment3

//Q1
//(b)
use angrist90.dta, clear
gen kid3= kidcount>2 //声明虚拟变量
gen p= hour89m>0 //声明二元因变量
reg p kid3 if yearschm!=. //model1
est store model1
reg p kid3 yearschm //model2
est store model2
outreg2 [model1 model2] using "/Users/eric/Desktop/学业/1研一上/5103/Assignments/3/Yang Huan A0224968N Assignment3/Output/model1&2.doc" , word excel replace
//the sign of the correlation between mother’s education and the kid3 is negative.

//(c)
reg yearschm kid3 // 变量间相关性分析
//It shows that our prediction from (b) is correct.

//(d)
gen samesex= sexk==sex2ndk //声明虚拟变量准备做IV
reg kid3 samesex, robust //see if it's OK to proceed as IV
ivregress 2sls p (kid3=samesex), robust //IV method
est store model1_2 //model1_2 with IV
outreg2 [model1 model1_2] using "/Users/eric/Desktop/学业/1研一上/5103/Assignments/3/Yang Huan A0224968N Assignment3/Output/model1&1_2.doc" , word excel replace
//With IV equation model 1_2 , it is meaning that mother have children that first two are same gender can reduce 0.0792 working hours.

//(e)
corr kid3 yearschm
corr samesex kid3
corr samesex yearschm
di -0.0005/0.0638
//So, the bias from IV (-0.078) is smaller than the bias from OLS(-0.12). But we also should pay attention corr(z,x), the bias of IV could be blown up by it.

//(f)
ivregress 2sls p (kid3=samesex) if yearschm!=.
est store IV
//we need at least one outside exogenous variable,so it may be not trusted. 
ivregress 2sls p yearschm (kid3=samesex) if yearschm!=.
est store IV2
hausman IV model1, constant sigmamore
//Model 1 p=0.0595>0.05, cannot reject H0 at 5%, so seems like no endogenous problem. But it is on the edge of level. We need to use more precise model, model2 to test.
hausman IV2 model2, constant sigmamore //hausman 检验是否内生性，原假设无内生，拒绝则有内生
est store Hausman_model2
outreg2 [Hausman_model2] using "/Users/eric/Desktop/学业/1研一上/5103/Assignments/3/Yang Huan A0224968N Assignment3/Output/Hausman_model2.doc" , word excel replace
//But model2 with added edum variable, hausman test p>0.05, that prove that we cannot reject kid3 is exogenous(无法拒绝外生原假设). We use model 2 and believe model2 better because this model is more fitted with higher R-squared.[Kid3 is exogenous]

reg kid3 yearschm samesex
predict v, resid
reg p kid3 yearschm v, r
outreg2 using  "/Users/eric/Desktop/学业/1研一上/5103/Assignments/3/Yang Huan A0224968N Assignment3/Output/edogenoustest_model2.doc" , word excel replace
//using method learnt from class to test model2, the result is same
