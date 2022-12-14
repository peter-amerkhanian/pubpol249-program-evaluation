PP249, Problem Set 2
================
Peter Amerkhanian
9/14/2022

``` r
library(tidyverse)
library(tidyr)
library(knitr)
library(haven)
library(quantreg)
library(lmtest)
library(sandwich)
library(ggplot2)
```

# Question 1

You are given cleaned data from the Tennessee Star Experiment, which
aims to address the impact of class size on student outcomes. This
question walks through the following tasks, either in R or Stata (please
be sure to share your code!):  
1) Load in the dataset, which is stored on bCourses as
“data_tennessee_star_q1.csv”  
2) Conduct summary statistics as requested in Question 1.1  
3) Conduct a regression with robust standard errors, where “math_score”
is the outcome and our only predictor variable is “treat”  
4) Answer the questions below!

``` r
data_tennessee_star_q1 <- read_csv("data_tennessee_star_q1.csv",
                                   show_col_types = FALSE)
```

## Question 1.1

Before we get into the regression, we want to run some summary
statistics. Fill in the table below for the outcome variable,
math_score.

``` r
q1_summary_table <- data_tennessee_star_q1 %>%
  group_by(treat) %>%
  summarise(
    n = n(),
    Minimum = min(math_score),
    Mean = mean(math_score),
    `Standard Deviation` = sd(math_score),
    Maximum = max(math_score)
  ) %>%
  rename(`Treatment Group` = treat)

kable(q1_summary_table)
```

| Treatment Group |    n |   Minimum |       Mean | Standard Deviation | Maximum |
|----------------:|-----:|----------:|-----------:|-------------------:|--------:|
|               0 | 4035 | -3.540999 | -0.0493377 |           1.000835 | 3.01097 |
|               1 | 1733 | -2.813003 |  0.1304650 |           1.059208 | 3.01097 |

## Question 1.2

Conduct the regression with robust standard errors (using math_score as
the outcome and treat as the predictor).

**Answer:**

``` r
model1 <- lm(math_score ~ treat, data=data_tennessee_star_q1)


model1_summary <- coeftest(model1, vcov = vcovHC(model1, type="HC0"))
model1_summary
```

    ## 
    ## t test of coefficients:
    ## 
    ##              Estimate Std. Error t value  Pr(>|t|)    
    ## (Intercept) -0.049338   0.015754 -3.1318  0.001746 ** 
    ## treat        0.179803   0.029920  6.0095 1.975e-09 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
#model1_summary <- summary(model1)
#model1_summary
```

-   What is control group mean?

``` r
cat(
  model1_summary['(Intercept)', 'Estimate']
)
```

    ## -0.04933773

-   What is the treatment group mean?

``` r
cat(
  model1_summary['(Intercept)', 'Estimate'] +
    model1_summary['treat', 'Estimate']
)
```

    ## 0.130465

-   What is the estimated treatment effect?

``` r
cat(
  model1_summary['treat', 'Estimate']
)
```

    ## 0.1798028

-   What is the estimated standard error on the treatment effect?

``` r
cat(
  model1_summary["treat","Std. Error"]
)
```

    ## 0.02991984

-   What is the “t statistic”?

``` r
cat(
  model1_summary["treat","t value"]
)
```

    ## 6.009483

-   Is the impact of treat on math_scores statistically significant?
    Yes, it’s very significant, with a *p* − *v**a**l**u**e* as follows:

``` r
cat(
  model1_summary['treat', 'Pr(>|t|)']
  )
```

    ## 1.975065e-09

## Question 1.3

Conduct a two-sample t-test for the difference in means between the
treatment group and the control group. What is the t statistic? Does
this differ from your answer to Question 1.2? Did you conduct this
testing assuming equal or unequal variances?

**Answer:**  
the R command `t.test()` will default to conducting the two-sample
t-test assuming unequal variances. The results, below, are the same as
the results I obtained in my regression in Question 1.2.

``` r
t.test(math_score ~ treat, data=data_tennessee_star_q1)
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  math_score by treat
    ## t = -6.008, df = 3118.1, p-value = 2.095e-09
    ## alternative hypothesis: true difference in means between group 0 and group 1 is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.2384816 -0.1211239
    ## sample estimates:
    ## mean in group 0 mean in group 1 
    ##     -0.04933773      0.13046503

Alternatively, I can conduct the test assuming equal variances by adding
`var.equal = TRUE`, and I will get different levels of significance, in
this case a more pronounced *t* − *s**t**a**t**i**s**t**i**c* and lower
*p* − *v**a**l**u**e*, but the point estimates themselves are still the
same as the regression.

``` r
t.test(math_score ~ treat, data=data_tennessee_star_q1, var.equal = TRUE)
```

    ## 
    ##  Two Sample t-test
    ## 
    ## data:  math_score by treat
    ## t = -6.1454, df = 5766, p-value = 8.51e-10
    ## alternative hypothesis: true difference in means between group 0 and group 1 is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.2371597 -0.1224458
    ## sample estimates:
    ## mean in group 0 mean in group 1 
    ##     -0.04933773      0.13046503

## Question 1.4

Consider the case where we double the sample size. Holding all else
equal, we would see the following:

-   Standard Error: Increase, Decrease, or Stay the Same?  
    Given that the sample size, *n* is in the denominator of the formula
    for standard error, **Standard Error decreases as sample size
    increases.**

-   t-statistic: Increase, Decrease, or Stay the Same?  
    Given the formula for the t statistic below, as sample size
    increases, *S**E*, the denomiator, decreases, and so **the t
    statistic will increase.**

-   p-value: Increase, Decrease, or Stay the Same?  
    The p-value, or, probability of a false positive error, **will
    decrease as sample size increases**.

# Question 2

You are given cleaned data from the Gerber and Green experiment on the
effects of canvassing, direct mail, and phone calls on voter turnout.
This question walks through the following tasks, either in R or Stata
(please be sure to share your code!):

1)  Load in the dataset, which is stored on bCourses as
    “data_gerber_q2.csv”  
2)  Conduct a regression with robust standard errors, where “vote” is
    the outcome and our only predictor variable is “treat”  
3)  Answer the questions below!

``` r
data_gerber_q2 <- read_csv("data_gerber_q2.csv",
                          show_col_types = FALSE)
```

## Question 2.1

Conduct the regression with robust standard errors (using vote as the
outcome and treat as the predictor). Please answer the following:

``` r
model2 <- lm(vote ~ treat, data=data_gerber_q2)
model2_summary <- coeftest(model2, vcov = vcovHC(model2, type="HC0"))
model2_summary
```

    ## 
    ## t test of coefficients:
    ## 
    ##              Estimate Std. Error t value  Pr(>|t|)    
    ## (Intercept) 0.2966383  0.0010445 283.999 < 2.2e-16 ***
    ## treat       0.0813099  0.0026917  30.207 < 2.2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

-   What is control group mean?

``` r
cat(
  model2_summary['(Intercept)', 'Estimate']
  )
```

    ## 0.2966383

-   What is the treatment group mean?

``` r
cat(
  model2_summary['(Intercept)', 'Estimate'] +
      model2_summary['treat', 'Estimate']
  )
```

    ## 0.3779482

-   What is the estimated treatment effect?

``` r
cat(
  model2_summary['treat', 'Estimate']
  )
```

    ## 0.08130991

-   What is the estimated standard error on the treatment effect?

``` r
cat(
  model2_summary['treat', 'Std. Error']
  )
```

    ## 0.002691722

-   What is the “t statistic”?

``` r
cat(
  model2_summary['treat', 't value']
  )
```

    ## 30.2074

-   Is the impact of treat on vote statistically significant?
    **Answer:**  
    Yes, I would go as far to say it’s extremely significant, with a t
    statistic that large and with a *p* − *v**a**l**u**e* as follows:

``` r
cat(
  model2_summary['treat', 'Pr(>|t|)']
  )
```

    ## 4.689892e-200

## Question 2.2

**Answer:**  
The results, below, are the same as the results I obtained in my
regression in Question 2.1, because by setting equal variance to False I
am doing the same operations as in linear regression with robust
standard errors.

``` r
t.test(vote ~ treat, data=data_gerber_q2, var.equal=FALSE)
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  vote by treat
    ## t = -30.207, df = 52613, p-value < 2.2e-16
    ## alternative hypothesis: true difference in means between group 0 and group 1 is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.08658577 -0.07603405
    ## sample estimates:
    ## mean in group 0 mean in group 1 
    ##       0.2966383       0.3779482

## Question 2.3 (Same as Q 1.4)

Consider the case where we double the sample size. Holding all else
equal, we would see the following:

-   Standard Error: Increase, Decrease, or Stay the Same?  
    Given that the sample size, *n* is in the denominator of the formula
    for standard error, **Standard Error decreases as sample size
    increases.**

-   t-statistic: Increase, Decrease, or Stay the Same?  
    Given the formula for the t statistic below, as sample size
    increases, *S**E*, the denomiator, decreases, and so **the t
    statistic will increase.**

-   p-value: Increase, Decrease, or Stay the Same?  
    The p-value, or, probability of a false positive error, **will
    decrease as sample size increases**.

``` r
rm(data_gerber_q2)
rm(data_tennessee_star_q1)
rm(model1)
rm(model2)
```

# Question 3: replicating measures of Black-white inequality as in Bayer and Charles (2018)

The goal of this exercise is to replicate measures of racial gap in log
median income (as defined in Bayer and Charles (2018)) for three
samples: (i) for working men only, (ii) for all men, and (iii) for all
men or women

Please read below:  
1) Instructions for requesting US Census data from IPUMS.org  
2) Instructions for running analysis and plotting figures  
3) Please run “measuring_bw_inequality_cleaning.do” to help you clean
the dataset before you start running quantile regressions to measure the
racial income level gaps at the median.

``` r
full_file <- read_dta("usa_00003/usa_00003.dta")
```

### 1.Begin Data Processing

This do-file creates a dataset on black-white earnings gaps over
1950-2019 at the median (and 90th percentile) controlling for age
groups.

Stata Code:

    *code for limiting years if pulled an extract with too many years
    use "data/raw/usa_00053.dta", clear
    *tab year
    keep inlist(year,1950,1960,1970,1980,1990,2000,2007,2010,2014,2019)
    saveold "data/raw/usa_00053.dta", replace

``` r
years_vec <- c(1950,
               1960,
               1970,
               1980,
               1990,
               2000,
               2007,
               2010,
               2014,
               2019)
df_years_filtered <- full_file %>% filter(year %in% years_vec)
rm(full_file)
```

### 2. Generate and prepare variables for analysis.

Stata Code:

    *use "data/output/census_acs_1950_2019.dta", clear
    *Sampling criteria - limited to ages 25-54
        drop if age < 25 | age > 54

``` r
df_age_filter <- df_years_filtered %>% filter(age >= 25 & age <= 54)
rm(df_years_filtered)
```

Stata Code:

    *Adjust income variables given changing definitions over time 
    *Replace observations with inconsistent wage
        drop if incwage >= 999998

``` r
df_inc_filter <- df_age_filter %>% filter(incwage < 999998)
rm(df_age_filter)
```

Stata Code:

    *replace incbusfm = . if incbusfm == 99999
    replace incbusfm = 0 if incbusfm < 0
    *replace incbus = . if incbus == 999999
    replace incbus = 0 if incbus < 0
    *replace incfarm = . if incfarm == 999999
    replace incfarm = 0 if incfarm < 0
    *replace incbus00 = . if incbus00 == 999999
    replace incbus00 = 0 if incbus00 < 0

``` r
df_inc_replac <- df_inc_filter %>%
  mutate(incbusfm = replace(incbusfm,
                            incbusfm == 99999,
                            NA)) %>%
  mutate(incbusfm = replace(incbusfm,
                            incbusfm <0,
                            0)) %>%
  mutate(incbusfm = replace(incbus,
                            incbus == 99999,
                            NA)) %>%
  mutate(incbusfm = replace(incbus,
                            incbus < 0,
                            0)) %>%
  mutate(incbusfm = replace(incfarm,
                            incfarm == 99999,
                            NA)) %>%
  mutate(incbusfm = replace(incfarm,
                            incfarm <0,
                            0)) %>%
  mutate(incbusfm = replace(incbus00,
                            incbus00 == 99999,
                            NA)) %>%
  mutate(incbusfm = replace(incbus00,
                            incbus00 <0,
                            0))
rm(df_inc_filter)  
```

Stata Code:

    *Adjust income variables given changing definitions over time 
    replace incwage = 1.2 * incwage if ind1950 == 105
    replace incbusfm = 1.4 * incbusfm if ind1950 == 105 & year <= 1960
    replace incbusfm = incbus + 1.4 * incfarm if year >= 1970 & year <= 1990
    replace incbusfm = incbus00 if year >= 2000
    replace incbusfm = 1.4 * incbus00 if year >= 2000 & ind1950 == 105

``` r
df_inc_mut <- df_inc_replac %>%
  mutate(incwage = ifelse(ind1950 == 105, 1.2 * incwage, incwage)) %>%
  mutate(incbusfm = ifelse(ind1950 == 105 &
                             year <= 1960, 1.4 * incbusfm, incbusfm)) %>%
  mutate(incbusfm = ifelse(year >= 1970 &
                             year <= 1990, incbus + 1.4 * incfarm, incbusfm)) %>%
  mutate(incbusfm = ifelse(year >= 2000, incbus00, incbusfm)) %>%
  mutate(incbusfm = ifelse(year >= 2000 &
                             ind1950 == 105, 1.4 * incbus00, incbusfm))
rm(df_inc_replac)
```

Stata Code:

    *Sum up income
    gen inc = incwage + incbusfm 
    replace inc = incwage if inc == .

``` r
df_inc_mut <- df_inc_mut %>% mutate(inc = incwage + incbusfm)
df_inc_mut <- df_inc_mut %>% mutate(inc = ifelse(is.na(inc), incwage, inc))
```

Stata Code:

    *merge in inflation numbers
    merge m:1 year using "data/raw/cpi_acs.dta"
    keep if inlist(year,1950,1960,1970,1980,1990,2000,2007,2010,2014,2019)
    drop _m

``` r
cpi <- read_csv("R_CPI_U_RS.csv", show_col_types = FALSE)
cpi <- cpi %>%
  filter(Year %in% years_vec) %>%
  rename(year = Year) %>%
  rename(CPI_1977 = `R-CPI-U-RS1 Index               (December 1977 = 100)`)

merged <- df_inc_mut %>% inner_join(cpi, by = "year")
rm(cpi)
```

Stata Code:

    * adjust to real 2019 dollars
    gen real_earnings = inc * (376.5/CPI_1977)

``` r
merged_w_sample <- merged %>% mutate(real_earnings = inc * (376.5/CPI_1977))
rm(merged)
```

Stata Code:

    *create samples dummies for 3 different figures
    gen sample1=0
    gen sample2=0
    gen sample3=0
    replace sample1 = 1 if sex==1 & real_earnings>1 /*for working men only*/
    replace sample2 = 1 if sex==1 /*all men*/
    replace sample3 = 1 /*all men and women*/

``` r
merged_w_sample <- merged_w_sample %>%
  mutate(sample1 = ifelse(sex == 1 & real_earnings > 1, 1, 0)) %>%
  mutate(sample2 = ifelse(sex == 1, 1, 0)) %>%
  mutate(sample3 = 1) 
```

Stata Code:

    * log real earnings
    gen logrealearn = log(real_earnings + 1)

``` r
merged_w_sample <- merged_w_sample %>% mutate(logrealearn = log(real_earnings + 1))
```

    ## Warning in log(real_earnings + 1): NaNs produced

Stata Code:

    * genrate age controls
    *gen ageg1 = age > 24 & age < 30* Baseline age group
    gen ageg2 = age > 29 & age < 35
    gen ageg3 = age > 34 & age < 40
    gen ageg4 = age > 39 & age < 45
    gen ageg5 = age > 44 & age < 50
    gen ageg6 = age > 49 & age < 55
    drop age

``` r
merged_w_sample <- merged_w_sample %>%
  mutate(ageg1 = age > 24 & age < 30) %>%
  mutate(ageg2 = age > 29 & age < 35) %>% 
  mutate(ageg3 = age > 34 & age < 40) %>% 
  mutate(ageg4 = age > 39 & age < 45) %>% 
  mutate(ageg5 = age > 44 & age < 50) %>% 
  mutate(ageg6 = age > 49 & age < 55) 
```

Stata Code:

    * racial dummy variables
    gen black = race == 2 & hispan == 0
    gen white = race == 1 & hispan == 0
    gen other = black == 0 & white == 0

``` r
merged_w_sample <- merged_w_sample %>%
  mutate(black = (race == 2 & hispan == 0)) %>%
  mutate(white = (race == 1 & hispan == 0)) %>% 
  mutate(other = (black == 0 & white == 0))
```

Stata Code:

    * racial category variable
    gen     race_string="Other"
    replace race_string="Black" if race==2
    replace race_string="White" if race==1

``` r
merged_w_sample <- merged_w_sample %>%
  mutate(race_string = "Other") %>% 
  mutate(race_string=ifelse(race == 2, "Black", race_string)) %>% 
  mutate(race_string=ifelse(race == 1, "White", race_string)) 
```

3.  Consolidating Years: Years 2007, 2014 and 2019 as displayed on the
    graph will contain multiple years of data.
4.  Assign years 2005-2006 a value of 2007.

<!-- -->

2.  Assign year 2013 a value of 2014.
3.  Assign year 2018 a value of 2019.
4.  (You need to add this to the cleaning code)

``` r
merged_w_sample <- merged_w_sample %>% filter(year %in% c(1950, 1960, 1970, 1980, 1990, 2000, 2007, 2010, 2014, 2019))
```

### 3. Perform quantile regressions to compute racial earnings level gaps at different percentiles and plot graphs

3.  Plotting Figure

<!-- -->

1.  Perform Quantile Regression on Each Sample i. A quantile regression
    allows us to calculate the earnings gaps between white and Black
    individuals at different spots (quantiles) in the earnings
    distribution. ii. Identify the log point gap at the median. 1. This
    gap is represented by the coefficient on the black dummy variable in
    the quantile regression. iii. Control for six 5-year age categories
    mentioned above to account for cohort size and life-cycle
    effects. iv. Control for “other” races. 1. This allows us to hone in
    on just the Black-White Gap. v. Perform this quantile regression for
    each year in the data, and for each sample definition.

``` r
#rq_model_1 <- merged_w_sample %>%
#  rq(
#    formula ="logrealearn ~ black",
#    data = .,
#    tau = 0.5
#  )
#print(rq_model_1$coefficients['blackTRUE'])
```

2.  Store Quantile Regression Coefficients per Year per Sample as a
    Dataset
3.  For each sample, these datasets show the log point difference
    between: Log earnings for Black individuals at the median of the
    Black earnings distribution vs. white individuals at the median of
    the white earnings distribution

<!-- -->

2.  You can use the parmest command in Stata to save parameters. You
    will initially save one dataset for each year, and you will
    ultimately want to combine this into a single dataset for plotting.

``` r
rq_model_1 <- merged_w_sample %>% filter(sample3 == 1) %>% filter(year == 1950) %>% 
  rq(
    formula ="logrealearn ~ black + ageg1 + ageg2 + ageg3 + ageg4 + ageg5 + other",
    data = .,
    tau = 0.5,
    weights = perwt
  )
```

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

``` r
summary(rq_model_1)
```

    ## 
    ## Call: rq(formula = "logrealearn ~ black + ageg1 + ageg2 + ageg3 + ageg4 + ageg5 + other", 
    ##     tau = 0.5, data = ., weights = perwt)
    ## 
    ## tau: [1] 0.5
    ## 
    ## Coefficients:
    ##             Value    Std. Error t value  Pr(>|t|)
    ## (Intercept)  7.24097  1.48881    4.86360  0.00000
    ## blackTRUE   -0.43525  0.14405   -3.02156  0.00252
    ## ageg1TRUE    1.73401  1.49418    1.16051  0.24587
    ## ageg2TRUE    1.94530  1.49348    1.30252  0.19277
    ## ageg3TRUE    1.84522  1.50147    1.22894  0.21912
    ## ageg4TRUE    1.46579  1.51270    0.96898  0.33258
    ## ageg5TRUE    1.29876  1.52230    0.85316  0.39359
    ## otherTRUE   -0.37944  0.50253   -0.75505  0.45024

``` r
years <- merged_w_sample %>% distinct(year) %>% pull(year)

formula1 = "logrealearn ~ black + ageg1 + ageg2 + ageg3 + ageg4 + ageg5 + other"

betas_1 = c()
# Sample 1
for (i in 1:length(years)) {
  rq_model_1 <- merged_w_sample %>% filter(year == years[i]) %>%
    filter(sample1 == 1) %>%
    rq(formula = formula1,
       data = .,
       tau = 0.5,
    weights = perwt)
  betas_1[i] = rq_model_1$coefficients['blackTRUE']
}
```

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

``` r
betas_2 = c()
# Sample 2
for (i in 1:length(years)) {
  rq_model_1 <- merged_w_sample %>% filter(year == years[i]) %>%
    filter(sample2 == 1) %>%
    rq(formula = formula1,
       data = .,
       tau = 0.5,
    weights = perwt)
  betas_2[i] = rq_model_1$coefficients['blackTRUE']
}
```

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

``` r
betas_3 = c()
# Sample 3
for (i in 1:length(years)) {
  rq_model_1 <- merged_w_sample %>% filter(year == years[i]) %>%
    filter(sample3 == 1) %>%
    rq(formula = formula1,
       data = .,
       tau = 0.5,
    weights = perwt)
  betas_3[i] = rq_model_1$coefficients['blackTRUE']
}
```

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

    ## Warning in rq.fit.br(wx, wy, tau = tau, ...): Solution may be nonunique

``` r
final_frame <- data.frame(betas_1, betas_2, betas_3, years_vec)
names(final_frame) <- c("Working Men Only", "All Men", "All Men and Women", "year")
melted <- final_frame %>% gather(key="Sample", value="beta", -year)
kable(head(melted))
```

| year | Sample           |       beta |
|-----:|:-----------------|-----------:|
| 1950 | Working Men Only | -0.5554996 |
| 1960 | Working Men Only | -0.5712536 |
| 1970 | Working Men Only | -0.4353082 |
| 1980 | Working Men Only | -0.3835605 |
| 1990 | Working Men Only | -0.4043169 |
| 2000 | Working Men Only | -0.3677171 |

``` r
ggplot(data = melted, aes(x = year, y = beta, group = Sample)) +
  geom_line(aes(color = Sample)) +
  geom_point(aes(color = Sample)) +
  ylim(-1, 0) +
  ggtitle("Median white-Black Real Earnings Gap (in log points)") +
  ylab("Real Earnings Gap (in log points)") +
  xlab("Year")
```

![](r_notebook_ps2_files/figure-gfm/unnamed-chunk-42-1.png)<!-- -->
