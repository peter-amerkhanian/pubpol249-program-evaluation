PP249, Problem Set 2
================
Peter Amerkhanian
9/14/2022

# Question 1

You are given cleaned data from the Tennessee Star Experiment, which
aims to address the impact of class size on student outcomes. This
question walks through the following tasks, either in R or Stata (please
be sure to share your code!): 1) Load in the dataset, which is stored on
bCourses as “data_tennessee_star_q1.csv” 2) Conduct summary statistics
as requested in Question 1.1 3) Conduct a regression with robust
standard errors, where “math_score” is the outcome and our only
predictor variable is “treat” 4) Answer the questions below!

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
*Note: R’s `lm()` command will, by default, run a regression with robust
standard errors*

``` r
model1 <- lm(math_score ~ treat, data=data_tennessee_star_q1)
model1_summary <- summary(model1)
model1_summary
```

    ## 
    ## Call:
    ## lm(formula = math_score ~ treat, data = data_tennessee_star_q1)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -3.4917 -0.7296 -0.1086  0.6408  3.0603 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) -0.04934    0.01604  -3.076   0.0021 ** 
    ## treat        0.17980    0.02926   6.145 8.51e-10 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.019 on 5766 degrees of freedom
    ## Multiple R-squared:  0.006507,   Adjusted R-squared:  0.006335 
    ## F-statistic: 37.77 on 1 and 5766 DF,  p-value: 8.51e-10

-   What is control group mean?

``` r
cat(
  model1_summary$coef['(Intercept)', 'Estimate']
)
```

    ## -0.04933773

-   What is the treatment group mean?

``` r
cat(
  model1_summary$coef['(Intercept)', 'Estimate'] +
    model1_summary$coef['treat', 'Estimate']
)
```

    ## 0.130465

-   What is the estimated treatment effect?

``` r
cat(
  model1_summary$coef['treat', 'Estimate']
)
```

    ## 0.1798028

-   What is the estimated standard error on the treatment effect?

``` r
cat(
  model1_summary$coef["treat","Std. Error"]
)
```

    ## 0.02925813

-   What is the “t statistic”?

``` r
cat(
  model1_summary$coef["treat","t value"]
)
```

    ## 6.145395

-   Is the impact of treat on math_scores statistically significant?
    Yes, it’s very significant, with a *p* − *v**a**l**u**e* as follows:

``` r
cat(
  model1_summary$coef['treat', 'Pr(>|t|)']
  )
```

    ## 8.510434e-10

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
    for standard error:  
    $$SE=\frac{\sigma}{\sqrt{n}}$$
      
    **Standard Error decreases as sample size increases:**
    $$\frac{\sigma}{\sqrt{n}} \> \frac{\sigma}{\sqrt{2n}}$$

-   t-statistic: Increase, Decrease, or Stay the Same?  
    The formula for the t statistic is as follows:  
    $$t\_{\hat{\beta}}=\frac{\hat{\beta} - \beta_0} {SE(\hat{\beta})}$$

As sample size increases, *S**E*, the denomiator, decreases, and so
**the t statistic will increase as sample size increases.**

-   p-value: Increase, Decrease, or Stay the Same? The p-value, or,
    probability of a false positive error, will decrease as sample size
    increases.

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
model2_summary <- summary(model2)
model2_summary
```

    ## 
    ## Call:
    ## lm(formula = vote ~ treat, data = data_gerber_q2)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -0.3780 -0.2966 -0.2966  0.6220  0.7034 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.296638   0.001055  281.05   <2e-16 ***
    ## treat       0.081310   0.002587   31.43   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.4616 on 229442 degrees of freedom
    ## Multiple R-squared:  0.004288,   Adjusted R-squared:  0.004284 
    ## F-statistic: 988.1 on 1 and 229442 DF,  p-value: < 2.2e-16

-   What is control group mean?

``` r
cat(
  model2_summary$coef['(Intercept)', 'Estimate']
  )
```

    ## 0.2966383

-   What is the treatment group mean?

``` r
cat(
  model2_summary$coef['(Intercept)', 'Estimate'] +
      model2_summary$coef['treat', 'Estimate']
  )
```

    ## 0.3779482

-   What is the estimated treatment effect?

``` r
cat(
  model2_summary$coef['treat', 'Estimate']
  )
```

    ## 0.08130991

-   What is the estimated standard error on the treatment effect?

``` r
cat(
  model2_summary$coef['treat', 'Std. Error']
  )
```

    ## 0.002586725

-   What is the “t statistic”?

``` r
cat(
  model2_summary$coef['treat', 't value']
  )
```

    ## 31.43354

-   Is the impact of treat on vote statistically significant?
    **Answer:**  
    Yes, I would go as far to say it’s extremely significant, with a t
    statistic that large and with a *p* − *v**a**l**u**e* as follows:

``` r
cat(
  model2_summary$coef['treat', 'Pr(>|t|)']
  )
```

    ## 2.039767e-216
