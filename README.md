# Understanding peace through the world news 

## Table of contents  
1. [Citing](#Citing)
2. [Abstract](#Abstract) 
3. [Data](#Data)
4. [Machine learning](#Machinelearning)
5. [Explanations](#SHAPmethodology)
6. [PeaceMap](#dashboard)

## Citing
<a name="Citing"/>

If you use our approach or code in this repository, please cite our paper:

Voukelatou, V., Miliou, I., Giannotti, F., & Pappalardo, L. (2022). Understanding peace through the world news.
 <br/>
https://epjdatascience.springeropen.com/articles/10.1140/epjds/s13688-022-00315-z

`@article{voukelatou2022understanding, `<br/>
  `title={Understanding peace through the world news},` <br/>
  `author={Voukelatou, Vasiliki and Miliou, Ioanna and Giannotti, Fosca and Pappalardo, Luca},` <br/>
  `journal={EPJ Data Science},` <br/>
  `volume={11},`<br/>
  `number={1}`<br/>
  `pages={2},`<br/>
 ` year={2022}` <br>
 `publisher={Springer Berlin Heidelberg}` <br>
} `


<a name="Abstract"/>

## Abstract
Peace is a principal dimension of well-being and is the way out of inequity and violence. Thus, its measurement has drawn the attention of researchers, policymakers, and peacekeepers. During the last years, novel digital data streams have drastically changed the research in this field. 

We exploit information extracted from a digital database called Global Data on Events, Location, and Tone ([GDELT](https://www.gdeltproject.org/)) to capture peace through the Global Peace Index ([GPI](https://www.visionofhumanity.org/wp-content/uploads/2021/06/GPI-2021-web-1.pdf)). Applying predictive machine learning models, we demonstrate that news media attention from GDELT can be used as a proxy for measuring GPI at a monthly level. Additionally, we use techniques from explainable AI to obtain the most important variables that drive the predictions.

This analysis highlights each country's profile and provides explanations for the predictions, and particularly for the errors and the events that drive these errors. We believe that digital data exploited by researchers, policymakers, and peacekeepers, with data science tools as powerful as machine learning, could contribute to maximizing the societal benefits and minimizing the risks to peace.

This work has been supported by EU project H2020 [SoBigData++](https://cordis.europa.eu/project/id/871042) #87104 and ERC-2018-ADG G.A. 834756
“[XAI](https://cordis.europa.eu/project/id/834756): Science and technology for the eXplanation of AI decision making”.

<a name="Data"/>

## Data extraction and preprocessing

### GDELT data
For GPI prediction, we derive several variables from the GDELT database. The variables correspond to the total number of events (No. events) of each GDELT category at a country and monthly level. 

On average, the number of variables per country is 87, varying from 25 to 141. We use the [BigQuery](https://www.gdeltproject.org/data.html#googlebigquery) data manipulation language in 
the Google Cloud Platform to extract the GDELT variables. You can find the query for the extraction of GDELT variables below:

```
SELECT ActionGeo_CountryCode,MonthYear,EventBaseCode,
COUNT(EventBaseCode) AS No_events,
FROM 'gdelt-bq.full.events'
WHERE(MonthYear>200802)AND(MonthYear<202010)
AND(ActionGeo_CountryCode<>'null')
GROUP BY ActionGeo_CountryCode,MonthYear,EventBaseCode
ORDER BY ActionGeo_CountryCode,MonthYear,EventBaseCode
```

The extracted data can be found in this repository's folder named `gdelt_data_200803_202009`.

### GPI data
GPI ranks 163 independent states and territories according to their level of peace, and it was created by the Institute for Economics & Peace (IEP). 
GPI data are available from 2008 until 2020 at a yearly level. We download the yearly GPI data from the IEP site. These data can be found in the folder named `gpi_all_countries.csv`. 

We use file `Fips10_4.csv` to match the countries with the [FIPS](https://en.wikipedia.org/wiki/List_of_FIPS_country_codes) country codes used by the GDELT database. In addition, we increase GPI frequency from yearly to monthly data using linear interpolation. Every yearly GPI value is assigned to March of the corresponding year since most of the annual GPI indicators are measured until this month. We upsample the yearly GPI score to monthly GPI score for each country, 
using the code in this repository's file named `Upsampling_GPI_score_for_all_countries.ipynb`.

<a name="Machinelearning"/>

## Machine learning
We merge GDELT and GPI data at a country level, and we prepare the data for machine learning, using the code in the file named `Preparation_gpi_gdelt_files_for_machine_learning.ipynb`. 

We create 163 files with data at a country and monthly level.
In addition, we use Linear Regression, Elastic Net, Decision Tree, Support Vector Regression (SVR), Random Forest, and Extreme Gradient Boosting (XGBoost) to investigate the relationship between the GPI score and the GDELT variables at a country and monthly level. Specifically, we aim to develop GPI estimates 1-month-ahead to 6-months-ahead of the latest ground-truth GPI value and find the model with the highest performance overall. 

For the United Kingdom and the United States studies (Section 5) we need to create the data that we use for future prediction when GPI data is not yet available. Thus, we run again the code `Preparation_gpi_gdelt_files_for_machine_learning.ipynb` to create the most updated data (up to September 2020). You can find the data in file named `all_variables_200803_202009`. 

Below, you can find the different regression models used for the training of our models, i.e.,
1. Linear regression (the R code and the packages used can be found in `Linear_predictions.R`),
2. Elasticnet (the R code and the packages used can be found in `Elasticnet_predictions.R`),
3. Decision Tree (the python code and the packages used can be found in `Decision_tree_predictions.ipynb`),
4. Support Vector Regressor (SVR) (the R code and the packages used can be found in `SVR_predictions.R`),
5. Random Forest (the python code and the packages used can be found in `Random_forest_predictions.ipynb`), and
6. Extreme Gradient Boosting (XGBoost) (the python code and the packages used can be found in `XGboost_predictions.ipynb`).

Figure 1 presents the Pearson Correlation coefficient and Mean Absolute Percentage Error (MAPE) between the real and the predicted 1-, 3-, and 6-months-ahead GPI values at a country level for all predictive models. Overall, XGBoost outperforms all other models. Therefore, we focus the rest of the analysis based on XGBoost model results.

<img width="489" alt="results_models" src="https://user-images.githubusercontent.com/35956507/146415438-7b5e7c27-fc3b-4966-bb0c-941462497ef8.png">

<sup>Figure 1. Pearson Correlation coefficient and Mean Absolute Percentage Error (MAPE) between the real and the predicted 1-, 3-, and 6-months-ahead GPI values at a country level for all predictive models. The boxplots represent the distribution of the Pearson correlation coefficient and MAPE for all country models. The plots' data points correspond to each country model.
</sup>


<a name="SHAPmethodology"/>

## Explanations


We use the [SHAP](https://github.com/slundberg/shap) methodology to identify which external GDELT variables drive the GPI estimations. This can be useful for explaining the models' behavior and diagnosing errors in the predictions. 

We select Saudi Arabia and Yemen as case studies to understand better and interpret the results and errors of the predictive models based on historical data. Additionally, we select the United Kingdom and the United States to estimate their future GPI values to gain initial insights into the country's peace before the official GPI score becomes available. 

Below, you find the corresponding codes:
1. The Saudi Arabia case study (the python code and the packages used can be found in `Shap_XGboost_training_SA.ipynb`),
2. The Yemen case study (the python code and the packages used can be found in `Shap_XGboost_training_YM.ipynb`),
3. The United States case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_US.ipynb`), and
4. The United Kingdom case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_UK.ipynb`).

For example, Figure 2 presents the local SHAP plot for Yemen. The prediction for June 2018 is 3.23, which corresponds to the 1-month-ahead prediction. The base value is the value that would be predicted if the variables for the current output were unavailable. The plot also displays the most important variables that the model uses for the GPI estimation, such as "Discuss by telephone" and "Provide military aid". 

<img width="605" alt="Screen Shot 2021-12-17 at 4 35 42 PM" src="https://user-images.githubusercontent.com/35956507/146569320-4c902590-2494-456d-bf72-087a46e3ecec.png">

<sup>Figure 2. It presents the model output value, i.e., the GPI estimation of June 2018. The red arrows are the variables that push the GPI estimation higher, and the blue ones push the estimation lower.</sup>

<a name="dashboard"/>

## PeaceMap

We created an interactive dashboard for the visualisation of the results. The dashboard serves as a tool to give early warnings to policy-makers.
The link is available online at: <br>
The data and the code used for the preparation of the ETL document, i.e., the CSV document that incldudes all data used for the visualisation 
can be found in the folder named `Dashboard`. <br>
The code for the creation of dashboard can be found in the following GitHub link: https://github.com/danielefadda/gpi_dashboard/tree/demopaper

