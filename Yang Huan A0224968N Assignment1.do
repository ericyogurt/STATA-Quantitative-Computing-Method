//Yang Huan A0224968N E0575602@u.nus.edu
insheet using housing_ass.csv,clear //导入csv文件

//1(c)
histogram resale_price //hist 变量
gen lnresale_price=log(resale_price) //生成log
histogram lnresale_price //hist log变量

//1(e)
encode flat_type, gen(room_number) //字符型str变成数值，提取生成新变量
gen lnfloor_area_sqm=log(floor_area_sqm) //自变量取对数
gen lnresale_price_persqr=lnresale_price-lnfloor_area_sqm //声明模型1 lnp
//跑回归 输出结果
reg lnresale_price_persqr lnfloor_area_sqm room_number //模型一
outreg2 lnresale_price_persqr lnfloor_area_sqm room_number using YangHuanTable1.doc, ///
ctitle (Model 1) bdec(3) rdec(3) word excel replace //系数小数点    R2小数点 
reg lnresale_price_persqr lnfloor_area_sqm //模型二
outreg2 lnresale_price_persqr lnfloor_area_sqm using YangHuanTable1.doc, ///
ctitle (Model 2) bdec(3) rdec(3) word excel append title ("Regression Results") 
reg lnfloor_area_sqm room_number //变量间 回归
correlate lnfloor_area_sqm room_number
pwcorr lnfloor_area_sqm room_number, sig star(0.05) //correlation
esttab using correlation.rtf, replace //本行和下面两行都可以输出回归结果
outreg2 lnfloor_area_sqm room_number using YangHuanCorrelation.doc, ///
ctitle (Model 3) bdec(3) rdec(3) word excel replace //注意覆盖replace逻辑


//2(a)
import excel using us_census.xls, sheet("1970") firstrow clear  //导入xls文件 有两个工作簿情况 通过sheet 选项读取名为“1970”的表格中，通过firstrow 选项把工作表中的第一行当成变量名读入.
save census70, replace //save为dta
import excel using us_census.xls, sheet("1980") firstrow clear //save为dta 覆盖
save census80, replace
use census70, clear
gen year=1970
append using census80 //并入
replace year=1980 if year==.  //覆盖无数据区域为1980
gen educ_cate=educ //声明分类变量
replace educ_cate=1 if educ_cate<12
replace educ_cate=2 if educ_cate==12
replace educ_cate=3 if educ_cate>12&educ_cate<=15
replace educ_cate=4 if educ_cate>=16
sort educ_cate year //排序
tab educ_cate if year==1970
tab educ_cate if year==1980 //比较分类变量 比例是否相等

//2(b)
summarize lwklywge educ age year //变量描述性统计
outreg2 using YangHuanTable2.doc, sum(log) word excel replace //输出描述性统计

//2(c)
tabstat educ if year==1970&(qob==1)
tabstat educ if year==1970&(qob!=1) //观察两条件组均值
gen dummyqob1= qob==1 //虚拟变量 一季度=1
reg educ dummyqob1 if year==1970 //虚拟变量 观察系数正负和P值，看看有没有显著差异

//2(d)
tabstat educ if qob==4
tabstat educ if qob==1 //观察条件组均值
gen dummyqob4= qob==4  //虚拟变量 四季度=1
reg educ dummyqob4 if (qob==1)|(qob==4) //观察系数正负和P值，看看有没有显著差异

//2(e)
gen exp=age-educ-5 //设立新变量 别忘记前面存留未分类数据

//2(f)
gen exp2=exp*exp //设立二次方变量
reg lwklywge educ exp exp2
outreg2 lwklywge educ exp exp2 using YangHuanTable3.doc, ///
ctitle (Model 1) bdec(3) rdec(3) word excel replace 

//2(g)
predict wagehat
display "the impact of one year exp to wage with 10 years exp^2=" _b[exp]+2*_b[exp2]*10


//2(h)
gen yrdummy=1 if census==80 //声明虚拟变量
replace yrdummy=0 if census==70
reg lwklywge educ exp exp2 yrdummy //加入作为控制变量
outreg2 lwklywge educ exp exp2 yrdummy using YangHuanTable3.doc, ///
ctitle (Model 2) bdec(3) rdec(3) word excel
