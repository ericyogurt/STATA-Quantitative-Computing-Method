//Yang Huan A0224968N E0575602@u.nus.edu
//(a)
use beer.dta, clear //导入文件,默认调用CD路径
gen period = ym(year,month) //生成年月时期 ym表明数据内含年月
format period %tm 
tsset period //声明period是时间变量

//(b)
gen lnbarrels=log(barrels) //生成对数形式
gen qoy=1 if month<=3
replace qoy=2 if month<=6 & month>3
replace qoy=3 if month<=9 & month>6
replace qoy=4 if month<=12 & month>9 //生成季度，备用3虚拟变量

//(c)
tsline lnbarrels, title(ln of beer sales)

//(d)
tab qoy, gen(q_dummy) //声明季度虚拟变量 注意用n-1个就可以
reg lnbarrels q_dummy2-q_dummy4 //回归季度性 变量若有序号规律可缩写联结
est store Seasonaltest //结果存于dta中，方便调用

//(e)
predict res, residual //提取残差
tsline res, title(Residual) //出图 标题

//(f)
reg res L.res //AR(1) 一阶自回归
est store AR1_1

//(g)
reg lnbarrels L.lnbarrels q_dummy2-q_dummy4
est store Regnew

//(h)
predict res_modified, res //滞后变量新残差
tsline res_modified, title(residual_modified) //观察
reg res_modified L.res_modified //继续重复一阶自回归
est store AR1_2 //加入之后变量的模型情况
reg res_modified L.barrels L.res_modified //初步观察新模型序列相关是否存在
//(i)
reg res_modified L.lnbarrels L.res_modified
est store Serial_Corr_Test //检验模型是否平稳，是否序列相关
gen res_modifiedsqr=res_modified^2
reg res_modifiedsqr L.lnbarrels //初步检验异方差
est store heteroscedasticitytest 
reg res_modifiedsqr L.res_modifiedsqr //检验自回归条件异方差
est store Arch1


//输出保存结果
outreg2 [Seasonaltest] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/Seasonaltest.doc", ///
word excel replace
outreg2 [Regnew] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/Regnew.doc", ///
word excel replace
outreg2 [AR1_1 AR1_2] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/AR(1).doc", ///
word excel replace
outreg2 [Serial_Corr_Test] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/Serial_Corr_Test.doc", ///
word excel replace
outreg2 [heteroscedasticitytest] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/hetertest.doc", ///
word excel replace
outreg2 [Arch1] using "/Users/eric/Downloads/BJTU/2020NUSAE/5103/assignments2/Arch1.doc", ///
word excel replace
